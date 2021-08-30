# Solución al Ejercicio 1

El primer paso de este ejercicio es determinar cual es el pod dentro del _namespace_ `ufo` que nos interesa, ya que hay varios:

```
kubectl get pods -n ufo

NAME          READY   STATUS    RESTARTS   AGE
pod-739273a   1/1     Running   0          38m
pod-837cdf1   1/1     Running   0          38m
pod-8a1a39e   1/1     Running   0          38m
```

Para identificar a qué aplicación pertenece cada _pod_, lo habitual en Kubernetes es usar etiquetas, y esto ha hecho el equipo de _Ufo Co_:

```
kubectl get pods -n ufo --show-labels

NAME          READY   STATUS    RESTARTS   AGE   LABELS
pod-739273a   1/1     Running   0          39m   app.kubernetes.io/managed-by=ufo-team,app.kubernetes.io/part-of=delacruz
pod-837cdf1   1/1     Running   0          39m   app.kubernetes.io/managed-by=ufo-team,app.kubernetes.io/part-of=vexamen
pod-8a1a39e   1/1     Running   0          39m   app.kubernetes.io/managed-by=ufo-team,app.kubernetes.io/part-of=ryucorb
```

Vale, ya hemos identificado el pod, que es `pod-837cdf1`. Nos podemos olvidar del resto.

El siguiente paso es ver qué ocurre. En el namespace `ufo` hay tres servicios:

```
kubectl get svc -n ufo

NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
svc-delacruz   ClusterIP   10.102.148.222   <none>        80/TCP    43m
svc-ryucorb    ClusterIP   10.103.200.57    <none>        80/TCP    43m
svc-vexamen    ClusterIP   10.105.71.46     <none>        80/TCP    43m
```

Si usamos `busybox` para probar el servicio `svc-vexamen` vemos que efectivamente no nos da respuesta:

```
kubectl run bb --image busybox -n ufo -it --rm -- wget -qO- http://svc-vexamen

If you don't see a command prompt, try pressing enter.
wget: can't connect to remote host (10.105.71.46): Connection refused
Session ended, resume using 'kubectl attach bb -c bb -i -t' command when the pod is running
pod "bb" deleted
```

Una consulta a los _endpoints_ del servicio nos deja claro que dicho servicio no tiene ningún _pod_ asociado:

```
kubectl get endpoints -n ufo

NAME           ENDPOINTS       AGE
svc-delacruz   172.17.0.3:80   46m
svc-ryucorb    172.17.0.5:80   46m
svc-vexamen    <none>          46m
```

Eso significa que el selector del servicio está mal, así pues obtenemos el yaml del servicio usando `kubectl get svc svc-vexamen -n ufo -o yaml > 01-svc.yaml` y eliminamos toda la parte superflua. Nos quedará un YAML parecido a:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: svc-vexamen
  namespace: ufo
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app.kubernetes.io/part-of: vexamen-server
```

Si comparas el selector con la etiqueta del pod, verás que el valor de `app.kubernetes.io/part-of` en el pod es `vexamen`, no `vexamen-server`, así que edita eso en el servicio.

Ahora ya puedes borrar y volver a crear el fichero:

```
kubectl delete svc svc-vexamen -n ufo
kubectl create -f 01-svc.yaml
```

Si ahora lo verificas con `kubectl get endpoints -n ufo`, ahora debería salir el endpoint asociado:

```
kubectl get endpoints -n ufo

NAME           ENDPOINTS       AGE
svc-delacruz   172.17.0.3:80   51m
svc-ryucorb    172.17.0.5:80   51m
svc-vexamen    172.17.0.4:80   46s
```

Si pruebas otra vez **verás que te sigue dando error**. Cuando un servicio tiene endpoints y no funciona lo más habitual es un error de puertos. Veamos el puerto que usa el pod:

```
kubectl describe pod -n ufo pod-837cdf1 | grep -i port

    Port:           8080/TCP
    Host Port:      0/TCP
```

¡Ups! Parece que el pod escucha por el 8080 y no por el 80. Editamos el YAML del servicio y lo modificamos para que `spec.ports.targetPort` sea 8080:

```YAML
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080      # Modificamos esa línea
```

Ahora de nuevo aplicamos el fichero YAML y volvemos a probar:

```
kubectl apply -f 01-svc.yaml

Warning: kubectl apply should be used on resource created by either kubectl create --save-config or kubectl apply
service/svc-vexamen configured

kubectl run bb --image busybox -n ufo -it --rm -- wget -qO- http://svc-vexamen
```

¡Fantástico! Recuerda siempre que tengas problemas de conectividad entre servicios y pods, a mirar:

1. Que el servicio tenga endpoints (está el selector bien)
2. Que sean los endpoints que tocan (mira las IPs)
3. Qué el mapeo de puertos sea correcto

[Volver a las soluciones](./readme.md)
[Volver a los ejercicios](../ejercicios.md)