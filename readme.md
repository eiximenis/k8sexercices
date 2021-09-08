# Ejercicios de práctica para Kubernetes :)

Ese repositorio te presenta un [conjunto de retos (en forma de escenarios)](./ejercicios.md) para ayudarte a verificar tus conocimientos de Kubernetes.

## ¿Me sirve eso para aprender Kubernetes?

No. Esos ejercicios **no están pensados para que aprendas Kubernetes**. Esos ejercicios están pensados para gente que lleva un cierto tiempo trabajando con Kubernetes y quiere algunos retos para poner a prueba sus conocimientos.

Por supuesto que puedes aprender algo viendo los ejercicios y las soluciones, pero siempre partiendo de la base de que conoces Kubernetes y te sientes (relativamente xD) cómodo trabajando con él. 

## Algunos me parecen muy fáciles otros muy difíciles

Bueno, **no están ordenados bajo ningún criterio**. Es posible que, por ejemplo, el primer ejercicio te parezca muy complejo y el segundo trivial. Cada ejercicio trata aspectos distintos, no están ordenados por dificultad ni por nada. 

## ¿Me sirve para preparar el CKAD?

Los retos están presentados en forma de escenarios, independientes entre ellos, de forma parecida al examen, pero toda similitud termina aquí. Por un lado **esos ejercicios tienen un nivel de dificultad superior** al examen. El número de temas tratados es superior y la dificultad para dar con la respuesta correcta es también superior. **Si eres capaz de solucionar esos ejercicios tienes los conocimientos necesarios para enfrentarte al CKAD**, pero los ejercicios y escenarios a resolver son, obviamente, totalmente distintos. Además el reto del CKAD no es tanto los conocimientos _per se_ como saber gestionar el tiempo que hay para resolverlo y tener claro qué escenarios solucionar primero.

Por otro lado, yo no te puedo proporcionar la "experiencia" del examen. ¡Ya me gustaría! Me refiero a que no tengo un shell interactivo con un cluster creado para ti y todo eso. Por lo tanto, la "experiencia de uso" de ese repositorio no se parece en nada a la experiencia de uso del examen real. Si quieres una experiencia de examen realista, tienes [killer.sh](https://killer.sh).

En este repositorio me limito a presentarte varios escenarios, **no se supone que debes ser capaz de resolverlos todos en un tiempo determinado**, no he creado los escenarios pensando en un tiempo límite para ser resueltos.

Por supuesto, si te estás preparando para el CKAD prueba de "auto-imponerte" las mismas restricciones que tendrás en el examen:

1. Resuelve todos los ejercicios desde una única consola de bash (usa WSL2 si estás en Windows). Sí, eso implica usar Vi o Nano como editores.
2. Usa una única pestaña de Chrome adicional, para navegar por la documentación de Kubernetes.
3. Cronometra tu tiempo (aunque como te digo, no le des mucho valor al resultado)

## ¿Como empezar?

### Preparando el cluster

Necesitas un clúster de Kubernetes. **Los ejercicios se han preparado para [MiniKube](https://minikube.sigs.k8s.io/docs/)** aunque la gran mayoría deberían funcionar para cualquier clúster. 

Si ya tienes un minikube puedes usarlo, en caso contrario puedes creando uno con el comando `minikube start`. Eso además te configura `kubectl` para usar minikube.

Luego ejecuta el fichero `setup-cluster.sh` para cargar los escenarios en el cluster.

> Si usas Windows, te recomiendo usar WSL2. Para ello configura Docker Desktop para usar WSL2 e instala minikube desde WSL2 usando el driver de Docker.

**Nota**: Puedes instalar ejercicios en concreto usando el parámetro `-e` de `setup-cluster.sh` (p. ej. `./setup-cluster.sh -e 1,4`)

> El fichero `./setup-cluster.sh` soporta el parámetro `-c` para indicar que tipo de cluster quieres usar. Los valores soportados son `minikube` (por defecto) y `rancher-desktop` (si usas [Rancher Desktop](https://rancherdesktop.io/))

> Espero agregar ficheros Powershell core además de los bash en un futuro.

Finalmente lee cada uno de los ejercicios (ficheros `ejercicio-x.md` (siendo x el número de ejercicio)).

### Realizando los ejercicios

Puedes hacer [los ejercicios](./ejercicios.md) en el orden que quieras. De hecho **NO ASUMAS QUE ESTÁN ORDENADOS**. Cada ejercicio es "independiente" y no están ordenados ni por dificultad, ni por nada.

### Limpieza del cluster

Simplemente ejecuta el fichero `uninstall.sh` para limpiar los escenarios. **Nota**: Pueden quedar trazas de lo que hayas realizado tu durante la resolución de los ejercicios.

Los ejercicios se instalan todos en sus namespaces. Esa es una lista de los namespaces usados:

- ufo    
- bm-corp
- logaiter
- gag
- vex

Pero, como ya sabes, hay algunos objetos que se instalan a nivel de clúster.

## ¿Y las soluciones?

[Las soluciones](./soluciones/readme.md) están en la carpeta `/soluciones`. **Por supuesto es posible que haya otras soluciones**. Los problemas se pueden solucionar de varias maneras, y eso mismo ocurre en el CKAD. Lo importante es que des con una solución que cumpla los requisitos planteados. **¡Hasta es posible que tu solución sea mejor que la propuesta!** :)

### Verificar una solución (TODAVÍA NO ESTÁ IMPLEMENTADO, SORRY)

Para verificar si has resuelto una solución, puedes hacerlo a mano, pero también puedes usar el script `check-exercice.sh` pasándole los ejercicios a verificar con el parámetro `-e`, como p.ej. `check-exercicie.sh -e 1,4` para que te verifique los ejercicios 1 y 4. Por supuesto la verificación se basa **en la solución propuesta**, así que es posible que, en algunos casos, te diga que falla y realmente lo hayas solucionado bien. Si te encuentras en esos casos, abre una Issue, para discutir tu solución e ir adaptando los ficheros de verificación :)

## ¡Me encanta eso, ¿cómo puedo colaborar?

¡De un millón de maneras!

1. Proponiendo escenarios nuevas usando issues
2. Añadiendo soporte a otros clústeres.
3. Añadiendo escenarios nuevos
4. ¡Como quieras! :)

**Recuerda: eso es WIP**