# Solución al ejercicio 6

Aquí **la clave principal es ver que, de todas las réplicas hay una especial: la primera que debe crear el fichero de claves**. El resto de réplicas deben usar el fichero creado por la primera de las réplicas. Ello nos indica que hay una cierta identidad entre las réplicas lo que nos da una pista de que en lugar de un _deployment_ deberíamos usar un _StatefulSet_. Puedes borrar el deployment y el servicio `cryptoserver` ya que no sirven para solucionar este problema.

Los requerimientos que debemos cumplir son:

1. El fichero de claves es compartido por todas las réplicas.
    * Eso implica el uso de un solo PV a compartir entre todos los _pods_. Así **no debemos usar `spec.volumeClaimTemplates`** del _StatefulSet_ ya que eso crearía una PVC por cada réplica, lo que impediría que compartieran el PV.
2. Solo la primera réplica debe crear el fichero
    * Para ello debemos modificar el entrypoint, para invocar un código bash que mire si el nombre del pod (que está en la variable `$HOSTNAME`) termina con `-0` y si es el caso invoque a `dotnet FileServer.dll create` y en caso contrario invoque a `dotnet FileServer.dll` (el entrypoint que nos dicen es el por defecto).
3. Evitar que una réplica se ponga en marcha **antes de que exista el fichero**. Para ello debemos usar una Readiness probe que no sea satisfecha hasta que exista el fichero. De este modo el StatefulSet no creará la segunda réplica, hasta que no esté lista la primera y no lo estará hasta que exista el fichero. **Recuerda que por defecto un _StatefulSet_ no crea la siguiente réplica hasta que la anterior está lista**.

Primero puedes crear la PVC:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cryptodata
  namespace: logaiter
spec:
  resources:
    requests:
      storage: 1Gi
  volumeMode: Filesystem
  storageClassName: standard
  accessModes:
    - ReadWriteOnce
```

> La PVC la he definido con el valor de `spec.storageClassName` a `standard` que es la StorageClass de Minikube que soporta autoaprovisionamiento de PVs. En caso de usar otro clúster, usa el valor de la StorageClass deseada o crea manualmente el PV si no quieres/puedes usar autoaprovisionamiento de PVs.

El siguiente paso es crear el _StatefulSet_. El **esqueleto inicial** es como sigue:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: cryptoserver
  namespace: logaiter
spec:
  selector:
    matchLabels:
      app: cryptoserver
  serviceName: cryptoserver
  replicas: 2
  template:
    metadata:
      labels:
        app: cryptoserver
    spec:
     volumes:
       - name: sharedkeys
         persistentVolumeClaim:
           claimName: cryptodata
     containers:
      - name: api
        image: quay.io/k8sexercices/fileserver:v1.0
        env:
        - name: DATA_PATH
          value: /sharedkeys
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: sharedkeys
          mountPath: /sharedkeys
```

Este StatefulSet creará las dos réplicas, y las configura para usar la PVC `cryptodata` así como establece el valor de la variabe `DATA_PATH` al directorio perisistido por la PVC. 

Obviamente este _StatefulSet_ no es correcto, ya que debemos conseguir que **solo la  primera réplica cree las claves**. Para ello, nos aprovechamos del hecho de que usando un _StatefulSet_ sabemos que el nombre de la primera réplica terminará en `-0` y solo en este caso debemos crear el fichero. Para ello en el `command` uso un script de bash que mira si la variable `$HOSTNAME` termina en `-0` o no, para invocar un comando inicial u otro. Para ello nos serviría lo siguiente en `spec.template.spec.containers[0]`:

```yaml
command:
  - bash
  - -c
  - |
    if [[ "$HOSTNAME" == *"-0" ]]
    then
      echo "1st instance. Using dotnet FileServer.dll create as entrypoint"
      dotnet FileServer.dll create
    else
      echo "Not 1st instance. Using dotnet FileServer.dll as entrypoint"
      dotnet FileServer.dll
    fi  
```

Y finalmente tenemos el tema de la la readiness probe (para evitar que se cree la siguiente réplica hasta que la anterior esté lista): puedes ver que se trata de una probe que usa el comando `stat` de Linux. Este comando devuelve error si se invoca sobre un fichero que no existe, lo que nos sirve perfectamente para nuestros usos: Hasta que no exista el fichero la readiness no pasará y el _StatefulSet_ no podrá crear la siguiente réplica. Para ello añade el siguiente código en `spec.template.spec.containers[0]`:

```yaml
readinessProbe:
  periodSeconds: 15
  initialDelaySeconds: 5
  exec:
    command:
    - stat
    - /sharedkeys/keys.txt
```

Si usas esa configuración verás que al crear el _statefulset_ se crea el pod `cryptoserver-0` y en sus logs son parecidos a:

```
1st instance. Using dotnet FileServer.dll create as entrypoint
Creating keys file /sharedkeys/keys.txt
Generated key 1: value is 2635
Generated key 2: value is 13534
Generated key 3: value is 9909
Generated key 4: value is 12264
Generated key 5: value is 8898
Starting API Host.
```

Al cabo de unos segundos, cuando el fichero esté creado, la _readiness probe_ passará y el _StatefulSet_ creará el segundo pod (`cryptoserver-1`) el cual tendrá unos logs parecidos a:

```
Not 1st instance. Using dotnet FileServer.dll as entrypoint
Starting API Host.
```

El siguiente punto es verificar que ambos pods comparten las claves criptográficas. Usa `kubectl port-forward -n logaiter cryptoserver-0 8080:80` y luego, en otro terminal lanza `curl http://localhost:8080`. Repite la operación, pero usando `cryptoserver-1` y verifica que el resultado es el mismo.

## Refinando detalles

La solución parece funcionar perfectamente **pero hay un punto débil**: Si, por cualquier motivo la instancia `-0` debe ser recreada entonces dará error. Lo puedes verificar borrando el pod `cryptoserver-0` a mano, lo que forzará al _StatefulSet_ a recrearlo. Y verás que da un error:

```
❯ kubectl delete pod -n logaiter cryptoserver-0
❯ k get pods -n logaiter -w
NAME                      READY   STATUS        RESTARTS   AGE
cryptoserver-0            1/1     Terminating   0          8m42s
cryptoserver-1            1/1     Running       0          7m58s
cryptoserver-0            0/1     Terminating   0          8m57s
cryptoserver-0            0/1     Terminating   0          8m58s
cryptoserver-0            0/1     Terminating   0          8m58s
cryptoserver-0            0/1     Pending       0          0s
cryptoserver-0            0/1     Pending       0          0s
cryptoserver-0            0/1     ContainerCreating   0          0s
cryptoserver-0            0/1     Error               0          2s
cryptoserver-0            0/1     Error               1          3s
cryptoserver-0            0/1     CrashLoopBackOff    1          4s
cryptoserver-0            0/1     Error               2          16s
```

Si miras los logs verás lo siguiente:

```
1st instance. Using dotnet FileServer.dll create as entrypoint
Unhandled exception. System.InvalidOperationException: Keys file /sharedkeys/keys.txt already exists and create param was passed. Please use only dotnet FileServer.dll without create param if file already exists.
   at FileServer.Program.CreateFile() in /src/FileServer/Program.cs:line 60
   at FileServer.Program.Main(String[] args) in /src/FileServer/Program.cs:line 22
   at FileServer.Program.<Main>(String[] args)
bash: line 7:     8 Aborted                 (core dumped) dotnet FileServer.dll create
```

¿Qué es lo que está ocurriendo? Pues, que **la instancia `-0` siempre usa `dotnet FileServer.dll create` como entrypoint, pero recuerda que si el fichero existía, entonces el contenedor lanzaba un error** y eso es, justamente, lo que nos está ocurriendo: el fichero ya existe en el PV y al intentar recrearlo otra vez obtenemos el error. Para ello debemos refinar el entrypoint del contenedor para que verifique si existe el fichero:

```yaml
command:
  - bash
  - -c
  - |
    if [[ "$HOSTNAME" == *"-0" ]]
    then
      if [[ -f "$DATA_PATH/keys.txt" ]]
      then
        echo "File $DATA_PATH/keys.txt found. Using dotnet FileServer.dll as entrypoint"
        dotnet FileServer.dll
      else
        echo "File $DATA_PATH/keys.txt *NOT* found. Using dotnet FileServer.dll create as entrypoint"
        dotnet FileServer.dll create
      fi
    else
      echo "Not 1st instance. Using dotnet FileServer.dll as entrypoint"
      dotnet FileServer.dll
    fi  
```

Si ahora recreas el _StatefulSet_ verás que los logs de `cryptoserver-0` son parecidos a:

```
❯ k logs cryptoserver-0 -n logaiter
File /sharedkeys/keys.txt found. Using dotnet FileServer.dll as entrypoint
Starting API Host.
```

¡Felicidades! Has ayudado al equipo de I+D de _Lo Gaiter del Llobregat_ y ¡les has demostrado que con Kubernetes sí podían hacerlo!

> El YAML final lo puedes encontrarn en [/setups/ex6/_solved/ss.yaml](../setups/ex6/_solved/ss.yaml)

[Volver a las soluciones](./readme.md)
[Volver a los ejercicios](../ejercicios.md)