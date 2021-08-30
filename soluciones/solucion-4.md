# Solución al Ejercicio 4

Efectivamente podemos ver que el pod `test-lg` está en estado _pending_. Para descubrir la razón usamos `kubectl describe pod test-lg -n logaiter` y nos fijamos en la sección de `Events`:

```
Events:
  Type     Reason            Age    From  Message
  ----     ------            ----   ----  -------
  Warning  FailedScheduling  2m57s        0/1 nodes are available: 1 node(s) didn't match node selector.
  Warning  FailedScheduling  2m57s        0/1 nodes are available: 1 node(s) didn't match node selector.
```

El error es bastante claro: se usa un _node selector_ que no es cumplido por ningún nodo. Vamos a ver cual es este nodeselector, recuperando el yaml del pod:

```
$ kubectl get pod test-lg -n logaiter -o yaml | grep -i -A2 nodeselector
        f:nodeSelector:
          .: {}
          f:logaiter/node-enabled: {}
--
  nodeSelector:
    logaiter/node-enabled: "true"
  preemptionPolicy: PreemptLowerPriority
```

Dado que **no podemos modificar el pod (por requerimiento)**, la solución pasa **por etiquetar los nodos (o al menos uno)**:

```
$ kubectl label node/minikube  logaiter/node-enabled=true
node/minikube labeled
```

> Por supuesto, usa el nombre de nodo (o de nodos) correspondientes a tu cluster

Después de eso, el pod debería estar corriendo:

```
$ kubectl get pods -n logaiter
NAME      READY   STATUS    RESTARTS   AGE
test-lg   1/1     Running   0          7m23s
```

¡Ojalá todo fuera tan sencillo! :)

[Volver a las soluciones](./readme.md)
[Volver a los ejercicios](../ejercicios.md)