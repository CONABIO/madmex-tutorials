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

##Contenedores de docker

*Imagen de docker para preprocesamiento: lspreproc_05_04_2016.tar*

```
$cat lspreproc_05_04_2016.tar |sudo docker import - ls_preproc_05_04_2016
```


*Imagen de docker para procesos: madmex_ws_05_04_2016.tar*

```
$cat cat madmex_ws_05_04_2016.tar |sudo docker import - madmex_ws_imagen
```

```
$sudo docker run -h  $(hostname)-preproc -v /ledaps_anc/:/opt/ledaps -p 2223:22 --name ls_preproc -d -t ls_preproc_imagen /usr/sbin/sshd -D
```

###Iniciar contenedor para procesos:


```
sudo docker run -h $(hostname -f) -p 2221:22 -p 8800:8800 -d -t --name madmex_ws madmex_ws_imagen /usr/sbin/sshd -D
```

