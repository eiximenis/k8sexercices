# Solución al ejercicio 3

Lo primero es ver los deployments `vexamenv1` y `vexamenv2` que son los que nos indican en el ejercicio:

```
❯ kubectl get deploy -n vex vexamenv1 vexamenv2
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
vexamenv1   1/1     1            1           5m6s
vexamenv2   1/1     1            1           5m6s
```

Ambos _deployments_ están listos y tienen un _pod_ cada uno. Para poder efectuar la prueba A/B que nos piden la estrategia es crear un servicio que seleccione los pods de ambos deployments. Para ello **los pods deben compartir alguna etiqueta**. Veamos qué etiquetas tienen los pods:

```
❯ kubectl get pods -n vex --show-labels
NAME                         READY   STATUS    RESTARTS   AGE     LABELS
vexamenv1-74d779d467-66kd9   1/1     Running   0          2m52s   app.kubernetes.io/app-version=v1.0,app.kubernetes.io/managed-by=vex-team,app.kubernetes.io/part-of=vexamen,pod-template-hash=74d779d467
vexamenv2-5bc977b795-nk47k   1/1     Running   0          2m35s   app.kubernetes.io/app-version=v2.0,app.kubernetes.io/managed-by=vex-team,app.kubernetes.io/part-of=vexamen,pod-template-hash=5bc977b795
```

Parece que estamos de suerte, las etiquetas `app.kubernetes.io/managed-by` y `app.kubernetes.io/part-of` son compartidas entre los pods de ambos _deployments_. Por lo tanto un servicio que solo use esas dos etiquetas (y se olvide de `app.kubernetes.io/app-version`) seleccionará los pods de ambos deployments:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: vexamenab
  namespace: vex
spec:
  selector:
    app.kubernetes.io/part-of: vexamen
    app.kubernetes.io/managed-by: vex-team
  ports:
  - port: 80
    name: http
    targetPort: http
```

Una vez creado el servicio se puede verificar como el servicio selecciona a los pods de ambos _deployments_:

```
❯ kubectl get endpoints -n vex vexamenab
NAME        ENDPOINTS                         AGE
vexamenab   172.17.0.4:8080,172.17.0.5:8080   19s
``` 

El único problema que tenemos es que con ello no satisfacemos la condición de 66% vs 33%, ya que al haber solo dos pods en los endpoints del servicio, las llamadas se dividirán aproximadamente al 50%. Debemos escalar el deployment `vexamenv2` a dos pods:

```
❯ kubectl scale deploy/vexamenv2 --replicas=2 -n vex
deployment.apps/vexamenv2 scaled
❯ kubectl get endpoints -n vex vexamenab
NAME        ENDPOINTS                                         AGE
vexamenab   172.17.0.3:8080,172.17.0.4:8080,172.17.0.5:8080   2m37s
```

Puedes probar desde un pod de `busybox` que todo funciona:

```
❯ kubectl run bb -n vex --rm --image busybox -it -- /bin/sh
If you don't see a command prompt, try pressing enter.
/ # wget -qO- http://vexamenab
```

¡Perfecto! :)