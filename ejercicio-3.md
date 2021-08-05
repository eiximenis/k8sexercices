# Ejercicio 3 (NO DISPONIBLE TODAVÍA)

**Namespace a usar: `vex`**

El equipo de _Vexamen World Control_ está planificando una nueva versión de su API de control mental. Para ello tienen dos _deployments_ llamados `vexamenv1` y `vexamenv2` con dos versiones distintas de la API.

Han creado también un par de servicios `vexamenv1` y `vexamenv2` para acceder a la API en su versión v1 y v2 respectivamente. La API acepta una llamada al endpoint (`/`) y devuelve la versión correspondiente.

Quieren hacer varias pruebas A/B, de forma que quieren crear un servicio (llamado `vexamenab`) de tal manera que los usuarios que accedan a este servicio reciban una respuesta aleatoria de la API en cualquiera de sus versiones. Por motivos estadísticos les interesa que en un 33% aproximado de las veces responda la v1 y el otro 66% responda la v2.

¿Les puedes ayudar?