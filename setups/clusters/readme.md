# Ficheros de requisitos de clusters

Este directorio contiene ficheros `check-xxxx.sh` donde `xxxx` es el tipo de clúster a usar. Esos ficheros verifican que el cluster está instalado y lo configuran si es necesario.

**Crear el clúster es algo que debe hacer el usuario**. Los ficheros no crean el clúster en ningún caso.

## Minikube

El fichero verifica que el ejecutable de `minikube` existe y añade los addons necesarios al cluster.