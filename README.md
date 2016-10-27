# madmex-tutorial
Repository to contain information and tutorials about the madmex system.

Este repositorio contiene información acerca de los requerimientos necesarios para la instalación del sistema MAD-MEX. La carpeta "es" tiene la documentación en español sobre cómo instarlar el sistema de dos maneras diferentes: 

1) versión cluster
2) versión standalone

La primera es una instalación en un sistema distribuido. Utiliza Sun Grid Engine, un gestinador del manejo de recursos computacionales o procesos distribuidos en ambientes heterogéneos, de modo que se utilicen dichos recursos de la manera más eficiente posible. En este tipo de estructuras, SGE se encarga principalmente de funciones como la aceptación, programación, envío y ejecución remota y distribuida de un gran número de tareas en el espacio de usuario, ya sean estas secuenciales, paralelas o interactivas. 

La segunda versión disponible es la "standalone". Esta versión es para uso en una sóla máquina en modo "offline", es decir, no requiere necesariamente una conexión permanente a la red para funcionar. 

En la carpeta "comandos_base_de_datos_madmex" encontrarás un shell script o archivo de comandos que al ejecutarse se encargará de la instalación de la base de datos MAD-MEX. Este paso es de vital importancia ya que el funcionamiento del sistema radica en una correcta configuración de su base de datos para poder ejecutar diversas tareas como control de calidad, elaboración de productos de clasificación de cobertura de suelo y detección de cambios.  

Se recomienda antes de realizar cualquier ejecución de comandos de instalación, leer primero los archivos con extendión .md para tener una idea general del proyecto MAD-MEX, sus alcances, antecedentes y trabajo futuro. 


Equipo MAD-MEX.
