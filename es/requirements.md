#Documentación Técnica del Sistema MAD-Mex

##Descripción General

En el marco del programa REDD+ (Reduce Emissions from Deforestation and forest Degradation), México se compromete al desarrollo de un sistema robusto a nivel nacional para el monitoreo de los datos de actividad. Para este fin se propone el uso del Inventatio Nacional Forestal y de Suelos (INFyS) y productos satelitales de percepción remota. La correcta clasificación de la cobertura de suelo así como los cambios en la misma son un insumo de vital importancia en el estudio de los datos de actividad. Dadas las dimensiones del país, es necesario un método automatizado para el procesamiento de semejante cantidad de información.

Es en este contexto que surge el sistema MAD-Mex (Monitoring Activity Data for the Mexican REDD+ program). El propósito es brindar la posibilidad de procesar las grandes cantidades de datos involucrados en un lapso de tiempo razonable.

##Arquitectura del Sistema

El sistema está diseñado para poder ser instalado de dos formas:

* cluster: Los componentes se instalan en un conjunto de computadoras que forman un cluster. Uno de los nodos se encarga de distribuir trabajos a los nodos esclavo. Está es la forma más eficiente de uso cuando se cuentan con los recursos necesarios.

* standalone: El sistema en su totalidad se instala en un solo mainframe, este será encargado de hacer todo el procesamiento. Es poco recomendable cuando existen restricciones de tiempo para la obtención de los productos.

A continuación se muestra un diagrama que representa la arquitectura del sistema en modo de cluster:


![Diagrama de componentes de MAD-Mex](../images/component_diagram.png)

##Requerimientos del Sistema en Modo Cluster

Para el correcto funcionamiento del sistema, un conjunto de requerimientos mínimos es necesario. A continuación se ofrece una breve descripción.

###Hardware Nodo Maestro
- mínimo: 2-4 vCPUs
- mínimo: 4GB RAM
- 50GB Memory
- ssh: 22/tcp

###Hardware Nodo Esclavo
- mínimo: 16 vCPUs
- mínimo: 64GB RAM
- memoria: 50GB
- ssh: 22/tcp


##Contenedores de docker

#Para ledaps de imágenes antes de 2012-2013 realizar:



#Para ledaps de imágenes después de 2012-2013 realizar:

```
$docker load < ledaps_after_2013.tar
```







