# Ejercicio 5

**Namespace a usar: `gag`**

El equipo de _Gag (a Evil Co)_ está un poco desesperado. Tienen dos pods (`apiv1` y `apiv2`) que ejecutan la misma API en distintas versiones. **Esos pods son eliminados y redesplegados cada noche por un servicio externo fuera de su control**. _Gag (a Evil Co)_ no tiene acceso a la definición de esos así que no puede modificarlos.

En su namespace tienen dos _deployments_ desplegados llamados `clientv1` y `clientv2`. Se trata de un cliente para la API correspondiente, y `clientv1` debe llamar al pod que ejecuta la v1, mientras que `clientv2` debe llamar al pod que ejecuta la versión 2. Estos clientes se configuran mediante una variable de entorno llamada `API_URL` que debe tener la forma `http://xxxx`, siendo `xxxx` el nombre DNS de la API. Han intentado configurar un par de servicios (`apiv1` y `apiv2`) pero han sido incapaces de conseguir que cada servicio use la versión de la API correspondiente.

Los clientes van dejando en un log (accesible mediante `kubectl logs`) los resultados de la llamada.

Al igual que ocurre con los pods de la API, los deployments se despliegan desde un proceso automatizado fuera del control de _Gag (a Evil Co)_, así que tampoco se puede tocar su definición YAML.

¿Puedes ayudar al equipo de _Gag (a Evil Co)_ a implementar los requerimientos, sin tocar las definiciones ni de los pods de la API ni de los deployments de los clientes?