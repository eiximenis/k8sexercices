# Solución al ejercicio 5

Lo importante de este ejercicio es la restricción de **no poder tocar los pods de la API ni de los clientes**. 
Cuando se nos da este caso, la estrategia más habitual es crear dos servicios (uno por cada versión) con el selector correcto. Para ello necesitamos que los pods de las distintas versiones tengan, al menos, una etiqueta distinta:

```
❯ kubectl get pods apiv1 apiv2 -n gag --show-labels
NAME    READY   STATUS    RESTARTS   AGE   LABELS
apiv1   1/1     Running   0          96s   app.kubernetes.io/component=api,app.kubernetes.io/part-of=gag-cs
apiv2   1/1     Running   0          96s   app.kubernetes.io/component=api,app.kubernetes.io/part-of=gag-cs
```

Como puedes ver eso **no se cumple**, por lo tanto no hay manera de crear un servicio que seleccione `apiv1` y otro que seleccione `apiv2`. Cualquier servicio seleccionará ambos pods. De hecho eso es lo que está ocurriendo con ambos servicios, que tienen los mismos endpoints:

```
❯ kubectl get endpoints apiv1 apiv2 -n gag
NAME    ENDPOINTS                         AGE
apiv1   172.17.0.6:8080,172.17.0.7:8080   3m34s
apiv2   172.17.0.6:8080,172.17.0.7:8080   3m34s
```

Está claro que usando dos servicios no vas a avanzar mucho, pero la otra aproximación tradicional que sería usar directamente las IPs internas de los pods de la API en los clientes, **tampoco la puedes usar porque los pods se recrean cada cierto tiempo**, lo que podría modificar esas IPs.

Si miras la definición de ambos pods verás que los campos `spec.hostname` y `spec.subdomain` están establecidos. Eso significa que si existe un servicio cuyo nombre sea el mismo que el valor de `spec.subdomain` y que seleccione ambos pods, se crearán entradas DNS para ellos. Observa que el valor de `spec.hostname` es `vexapi`, así que ese es el nombre del servicio a crear. **Dado que ambos pods tienen las mismas etiquetas**, puedes usar el comando:

```
kubectl expose pod/apiv1 -n gag --port 8080 --cluster-ip None --name vexapi
```

> El servicio puede ser headless (`--cluster-ip None`) ya que no necesitas una IP que algutine ambas versiones de la API

> Puedes borrar los servicios `apiv1` y `apiv2`, que no son necesarios para nada

Observa que el servicio `vexapi` tiene a ambos pods como endpoints, eso es totalmente correcto, ya que solo lo queremos para crear entradas DNS para nuestros pods:

```
❯ k get endpoints vexapi -n gag
NAME     ENDPOINTS                         AGE
vexapi   172.17.0.4:8080,172.17.0.8:8080   6m7s
```

Una vez hecho esto, si miras los dos deployments `clientv1` y `clientv2` verás que usan `envFrom` con dos _ConfigMaps_ como origen: `clientv1config` y `clientv2config`. Edita ambos _ConfigMaps_ y modifica su entrada `API_URL` al valor correcto en cada caso (el valor de `spec.hostname` de cada pod):

- `http://api-v1.vexapi:8080` para el ConfigMap `clientv1config` 
- `http://api-v2.vexapi:8080` para el ConfigMap `clientv2config` 

> Necesitamos acceder usando el puerto `8080` porque al no usar el servicio (accederemos directamente a los pods) no tenemos la posibilidad de redireccionar puertos.

Finalmente escala ambos deployments a 0 y reescalalos a 1 para forzar que se recreen los pods y lean la nueva configuración:

```
kubectl scale deploy clientv1 -n gag --replicas=0
kubectl scale deploy clientv2 -n gag --replicas=0
kubectl scale deploy clientv1 -n gag --replicas=1
kubectl scale deploy clientv2 -n gag --replicas=1
```

¡Listos! ¡Si ahora compruebas los logs verás que cada uno de los clientes accede a su versión correspondiente!

[Volver a los ejercicios](../readme.md)