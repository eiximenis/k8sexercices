# Ejercicio 6

**Namespace a usar: `logaiter`**

El equipo de I+D de _Lo Gaiter del Llobregat_ se encuentra con un problema que no saben como afrontar, a ver si les puedes ayudar. Tienen una imagen llamada `quay.io/k8sexercices/fileserver:v1.0` que sirve una API que requiere datos criptográficos y quieren ejecutarla en Kubernetes. Los requerimientos son **que haya en todo momento al menos dos réplicas**.

Pero hay las siguientes casuísticas importantes:

* Para funcionar la imagen debe generar un fichero criptográfico. Esa generación **tarda unos 30 segundos** y durante este periodo de tiempo el contenedor no es capaz de servir peticiones (el host no responde). Para generar dicho fichero criptográfico debe invocarse el comando `dotnet FileServer.dll create` el cual mira si el fichero de claves existe y si no es el caso lo crea (recuerda que puede tardar unos 30 segundos) y luego levanta la API. Si el fichero de claves ya existe **entonces lanza un error y el proceso termina.**.
* El _entrypoint_ de la imagen es `dotnet FileServer.dll` que se limita a levantar la API sin comprobar ni crear el fichero en caso que sea necesario (asume que éste existe). **Si el fichero no existe en el momento en que la API se levanta** esta no es capaz de responder correctamente a ninguna petición (devuelve un código 500) hasta que el contenedor se reinicie.
* El contenedor guarda el fichero generado en su sistema de ficheros en la ubicación indicada por la variable de entorno `DATA_PATH`. El fichero se llama  `keys.txt`.
* Todas las réplicas **deben compartir el fichero generado**. Eso significa que:
    * Solo una de las réplicas debe generar el fichero
    * El resto de réplicas deben esperarse a que el fichero criptográfico generado por la primera réplica exista. Recuerda: si una réplica **se pone en marcha antes de que el fichero exista, dicha réplica entra en un estado inconsistente y es incapaz de resolver cualquier petición, hasta que es reiniciada**.

Los ingenieros de _Lo Gaiter del Llobregat_ lo han intentado con un deployment con dos réplicas llamado  `cryptoserver` y un servicio `cryptoserver`, que engloba los pods del deployment. Actualmente el sistema no está funcionando correctamente, ya que **cada pod ha creado sus propias claves criptográficas (distintas entre sí)**, lo que no es aceptable. Además si por cualquier motivo un _pod_ se cae, el nuevo _pod_ crea sus propias claves criptográficas distintas de las demás.

Para verificar que el sistema funciona correctamente y que todos los pods usan las mismas claves criptográficas debes acceder al endpoint `/keys` de cada uno de los pods y la respuesta debe ser un HTTP 200 con los mismos datos en todos los casos. También existe el endpoint (`/`) que se limita a devolver un mensaje. Como se ha comentado antes endpoints devuelven 500 si el fichero de claves no estaba creado en el momento de levantar la API.

¿Como les puedes ayudar? Ya hay gente del equipo que sospecha que con Kubernetes no es posible hacer eso...