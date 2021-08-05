# Ficheros de instalación de escenarios

Esta carpeta contiene los scripts para instalar escenarios

Cada ejercicio `<x>` contiene los siguientes ficheros:

* `./install-<x>.sh`: Fichero bash que despliega el ejercicio en el cluster.
* `./install-<x>.<cluster>.sh`: Fichero que realiza instalaciones específicas para un tipo de cluster `<cluster>` para el ejercicio. Si existe, se ejecuta **antes** que el `install-<x>.sh`.
* `./ex<x>`: Una carpeta con los manifiestos y ficheros YAML del ejercicio.
* `./uninstall-<x>.sh`: Fichero bash que elimina el ejercicio en el cluster

## Creando un nuevo ejercicio

Para dar de alta un ejercicio nuevo, debes añadir:

* Los ficheros `./install-<x>.sh` y `./uninstall-<x>.sh`
* Los ficheros `./install-<x>.<cluster>.sh` si son necesarios
* La carpeta `./ex<x>` con los manifiestos YAML y otros recursos necesarios para el ejercicio


