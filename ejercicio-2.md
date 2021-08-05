# Ejercicio 2

**Namespace a usar: `bm-corp`**

Los ingenieros de BM Corp están trabajando en su último proyecto. Se trata de una API que sirve imágenes desde un directorio. El _pod_ que sirve la API se llama `bm-api` y sirve las imágenes desde `/data/images`. **El contenido de dicho directorio no existe en la imagen Docker ya que depende del entorno**. Los ingenieros de BM Corp saben que existe una imagen llamada `quay.io/k8sexercices/bmapi:v1.0` que incluye las imágenes del entorno de desarrollo. Dicha imagen es un proyecto de consola que copia las imágenes a un directorio establecido por la variable de entorno `BM_PIC_SEEDER_PATH`.

Debes asegurarte de que las imágenes estén copiadas en el directorio `/data/images` del contenedor ejecutado por el _pod_ `bm-api`. Hazlo de tal forma, que si por cualquier motivo es necesario recrear el _pod_ las imágenes se vuelvan a copiar de forma automática.

Para comprobar si te funciona, verifica que accediendo al _pod_ `bm-images-api` en la url `/k8s.png` recibes el logo de Kubernetes.