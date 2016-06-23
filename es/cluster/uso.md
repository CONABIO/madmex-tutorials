#Esta documentación muestra el uso del sistema madmex en una versión cluster

Es crucial una instalación de docker en su sistema: https://www.docker.com/

En esta versión de madmex utilizamos sun grid engine un "open-source grid computing cluster software system para distributed resource management y job distribution". Se encarga del "scheduling", "dispatching" y "managing" de jobs.

Consideraremos cuatro nodos:

- Nodo maestro que tendrá el servicio maestro de sun grid engine en un contenedor de docker.
- Dos nodos de procesamiento que tendrán un contenedor de docker encargado de ejecución de procesos y el cliente del servicio master de sun grid engine.
- Nodo para la base de datos.

Especificaciones para los nodos:

- Nodo maestro:

- Nodos de procesamiento:

- Nodo para la base de datos:

##Base de datos

###Levantamiento del servidor de postgres

Ejecutar el siguiente comando después de clonar este repositorio dentro de la carpeta "es/comandos_base_de_datos_madmex" en el nodo para la base de datos:

```
$docker run --name postgres-server-madmex -v $(pwd):/results -p 32852:22 -p 32851:5432 -dt madmex/postgres-server
```

###Creación de la base de datos madmex

-Requerimientos:

	*Dirección IP del contenedor en el que está levantado el servidor de postgres. Para saber la IP ejecutamos:

```
$docker inspect postgres-server-madmex|grep IPA

```

La dirección IPAddress es la que buscamos.


-Ejemplo: 

	* Suponemos que la dirección IP del contenedor es 172.17.0.2.

Ejecutar el siguiente comando:

```
$docker exec -u=postgres -it postgres-server-madmex /bin/bash /results/madmex_database_install.sh 172.17.0.2 5432
```

## Carpeta compartida por todos los nodos vía nfs:



##Levantamiento del servicio master de sun grid engine

En el nodo maestro ejecutar el siguiente comando:

```
$docker run --name master-sge-container -h $(hostname -f) -v /carpeta_compartida:/LUSTRE/MADMEX -p 6444:6444 \ 
-p 2224:22 -p 8083:80 -p 6445:6445 -dt madmex/sge_dependencies /bin/bash

```

Entrar al contenedor de docker que acabamos de iniciar con el comando anterior ejecutando la siguiente línea:

```
$docker exec -it master-sge-container /bin/bash

```
Dentro del docker ejecutar los siguientes comandos, en estos comandos suponemos que el hostname del nodo maestro es "nodomaestro":

```
$root@nodomaestro:/# service apache2 start

$root@nodomaestro:/# service ssh restart

$root@nodomaestro:/#apt-get install -y gridengine-client gridengine-exec gridengine-master

```

El último comando nos llevará a una serie de configuraciones para el servicio maestro de sun grid engine. Seleccionar los defaults y en la pantalla en la que se pregunte por "SGE master hostname" escribir "nodomaestro".

Reiniciamos servicio maestro de sun grid engine:

```
$root@nodomaestro:/# /etc/init.d/gridengine-master restart

```

Y al ejecutar el siguiente comando no deben salir errores:

```
$root@nodomaestro:/# qhost

```

Configuramos al nodomaestro como submit host:

```
$root@nodomaestro:/# qconf -as nodomaestro
```

Creamos el grupo @allhosts:

```
$root@nodomaestro:/# qconf -ahgrp @allhosts
```
no modificamos nada de este archivo, tecleamos ESC y luego :x!


Creamos la queue miqueue.q:

```
$root@nodomaestro:/# qconf -aq miqueue.q

```

no modificamos nada de este archivo, tecleamos ESC y luego :x!

Añadimos el grupo @allhosts a la queue:

```
$root@nodomaestro:/# qconf -aattr queue hostlist @allhosts miqueue.q

```

Configuramos el número de cores que usarán los nodos de procesamiento, por ejemplo 2:

```
$root@nodomaestro:/# qconf -aattr queue slots "2" miqueue.q
```

Salimos del docker para finalizar la configuración del servicio maestro de sun grid engine:

```
$root@nodomaestro:/# exit

```

Ahora podremos visualizar en un browser la página: nodomaestro:8083/qstat que es un servicio de web para "queue monitoring de sun grid engine"



##Levantamiento de clientes de sun grid engine


La imagen de docker "madmex/ws" tiene las dependencias necesarias para comunicarse con el servicio maestro de gridengine, por lo que en los nodos de procesamiento necesitamos lo siguiente:

- Árbol de directorios:

		/carpeta_compartida/gridengine/nodo.txt

		/carpeta_compartida/docker/logging/

		/carpeta_compartida/code

		/carpeta_compartida/resources/config/configuration.ini

		/configuraciones/config/supervisor/madmex_webservices_supervisord.conf

		/tmp/madmex_temporal


los archivos de configuración "madmex_webservices_supervisord.conf", "nodo.txt", "configuration.ini" están en cluster/configuraciones.md de este repositorio.

*NOTAS:* 

- La carpeta con nombre carpeta_compartida además de contener diferentes archivos y el código del sistema madmex, será aquella en la que se copien las imágenes descargadas y descomprimidas en un árbol de directorios. Por esto, debe tener suficiente capacidad de almacenamiento.
- La carpeta con nombre madmex_temporal contendrá archivos resultado de los procesos usados por el sistema madmex. Por esto, debe tener suficiente capacidad de almacenamiento.
- Debemos modificar el "configuration.ini" en la parte de database-madmex y database-classification en donde dice "hostname" para la ip del host donde está levantado el servidor de la base de datos.
- En la carpeta code tenemos que clonar el repositorio CONABIO/madmex-v2.

Ejecutamos el siguiente comando:

```

$docker run -h $(hostname -f) --name madmex_ws_proc -v /tmp/madmex_temporal:/services/localtemp/temp -p 2225:22 \
-p 8800:8800 -v /carpeta_compartida/:/LUSTRE/MADMEX/ \
-v /configuraciones/config/supervisor/madmex_webservices_supervisord.conf:/etc/supervisor/conf.d/supervisord.conf \
 -d -t madmex/ws /usr/bin/supervisord


```

Entramos al docker:

```
$docker exec -it madmex_ws_proc /bin/bash

```
Configuramos el archivo: /var/lib/gridengine/conabio/common/act_qmaster para que diga el nombre del nodo maestro: "nodomaestro"


En el "nodomaestro" entramos al contenedor en el que corre el servicio maestro para configuración de los clientes (nodos de procesamiento)

```
$docker exec -it master-sge-container /bin/bash

```

Añadimos al nodo de procesamiento "nodoproc1" como submit host:

```
$root@nodomaestro:/# qconf -as nodoproc1

```

Al ejecutar el siguiente comando se desplegará una pantalla en la que en la entrada de hostname escribiremos "nodoproc1" 

```
$root@nodomaestro:/# qconf -ae

```


Añadimos nodoproc1 al grupo @allhosts:

```
$root@nodomaestro:/# qconf -aattr hostgroup hostlist nodoproc1 @allhosts

```

En el nodo "nodoproc1" ejecutamos:

```
#/etc/init.d/gridengine-exec restart

```

Lo anterior se realiza para los otros nodos de procesamiento.

Una vez levantados estos tres requerimientos: base de datos, master service y cliente de sun grid engine podemos realizar los siguientes procesos.

En la siguiente explicación utilizaremos "$" para especificar que ejecutamos el comando en el host y "#" para especificar que se ejecuta en el contenedor respectivo.

Los procesos los lanzaremos en el contenedor del servicio maestro de sun grid engine.

##Landsat

###Descarga de imágenes

En el nodo maestro entramos al docker del servicio maestro de sun grid engine:

```
$docker exec -it master-sge-container /bin/bash

```

-Requerimientos:

	* Path, row de tile de landsat
	* Año a descargar imágenes
	* Instrumento a elegir entre tm, etm+, oli-tirs
	* shell de descarga que debe tener permisos de ejecución, ir a comandos.md de este repositorio

Creamos dentro de la carpeta compartida (que en el contenedor se llama /LUSTRE/MADMEX) el siguiente árbol de directorios:

	/LUSTRE/MADMEX/descarga_landsat

En la carpeta descarga_landsat colocamos el shell de descarga: "descarga_landsat.sh"

-Ejemplo: descarga todas las imágenes landsat del año 2015

	* path: 021, row: 048
	* año: 2015
	* Instrumento: etm+ (L7)

Ejecutamos el siguiente comando:

```
#qsub -q miqueue.q -S /bin/bash -cwd /LUSTRE/MADMEX/descarga_landsat.sh L7 021 048 2015
```

En el directorio /LUSTRE/MADMEX/descarga_landsat/ tendremos la carpeta: *landsat_tile_021048*

En esta carpeta se encuentran archivos con extensión *.tar.bz y también tendremos archivos de logs:

descarga_landsat.sh.e9  descarga_landsat.sh.o9

 que nos ayudan a revisar que el proceso se inició/ejecuta/finaliza de forma correcta.

 De igual forma podemos visualizar: nodomaestro:8083/qstat/qstat.cgi para monitorear el job.

 Si quisiéramos detener el job podemos usar el comando en dentro del contenedor del servicio maestro de sun grid engine:

 ```
#qdel numero_job
 ```

 en donde numero_job es el número del job que quisiéramos borrar/detener.


-Ejemplo descarga de un archivo: 

Podemos listar los archivos disponibles de landsat con el siguiente comando, por ejemplo para Landsat 7 path 021, row 048 entramos al contenedor madmex/ws que corre en los nodos de procesamiento

```
$docker exec -it madmex/ws /bin/bash

```

Y ejecutamos:

```
#gsutil ls gs://earthengine-public/landsat/L7/021/048/
```

para listar todos los archivos disponibles para su descarga del sensor L7 del path 021, row 048.

Por ejemplo, si quisiéramos descargar el archivo gs://earthengine-public/landsat/L7/021/049/LE70210492015007EDC00.tar.bz

Entramos al contenedor del servicio maestro de sun grid engine:

```
$docker exec -it master-sge-container /bin/bash

```

y ejecutamos el siguiente comando en el contenedor:

```
#qsub -q miqueue.q -S /bin/bash -cwd /LUSTRE/MADMEX/descarga_landsat/descarga_tile_landsat.sh L7 021 049 \
LE70210492015007EDC00.tar.bz /LUSTRE/MADMEX/descarga_landsat
```

En el directorio /LUSTRE/MADMEX/descarga_landsat tendremos el archivo descargado.


###Preprocesamiento

####LEDAPS, sensor tm o etm+

-Requerimientos:
	
	* ancillary data:  http://espa.cr.usgs.gov/downloads/auxiliaries/ledaps_auxiliary/ledaps_aux.1978-2014.tar.gz
	* shell de ledaps.sh que debe tener permisos de ejecución, ir a comandos.md de este repositorio

-Ejemplo para datos después del año 2012-2013 con el archivo LE70210492015007EDC00.tar.bz:

	*En ruta: /datos_landsat tenemos el LE70210492015007EDC00.tar.bz
	*En ruta: /resultados_ledaps queremos los resultados del preprocesamiento
	*En ruta: /ancillary_data tenemos descomprimido el ancillary data
	*Usamos la imagen: ledaps/ledaps:latest

Entonces ejecutamos el siguiente comando:


```
docker run --rm -v /ancillary_data:/opt/ledaps \
-v /datos_landsat:/data -v /resultados_ledaps:/results \
madmex/ledaps:latest /results/ledaps.sh /data/LE70210492015007EDC00.tar.bz /opt/ledaps
```

Los resultados están en el path: /resultados_ledaps

-Ejemplo para datos antes del año 2012-2013 con el archivo LE70210481999203AGS00.tar.bz: (advertencia, debemos utilizar para este ejemplo ancillary data antiguo)

	*En ruta: /datos_landsat tenemos el LE70210481999203AGS00.tar.bz
	*En ruta: /resultados_ledaps queremos los resultados del preprocesamiento
	*En ruta: /ancillary_data tenemos descomprimido el ancillary data
	*Usamos la imagen: madmex/ledaps-legacy:latest


```
docker run --rm -v /ancillary_data:/opt/ledaps \
-v /datos_landsat:/data -v /resultados_ledaps:/results \
madmex/ledaps-legacy:latest /opt/ledaps /data/LE70210481999203AGS00.tar.bz /results
```

Los resultados están en el path: /resultados_ledaps

####FMASK

-Requerimientos:

	* Para un archivo de Landsat tm o etm+: shell de fmask.sh que debe tener permisos de ejecución, ir a comandos.md de este repositorio
	* Para un archivo de Landsat 8: shell de fmask_ls8.sh que debe tener permisos de ejecución, ir a comandos.md de este repositorio
	* El sistema en el que se ejecutan los comandos debe tener más de 4096Mb.

-Ejemplo para Landsat 7: LE70210492015007EDC00.tar.bz


Ejecutar el siguiente comando en el directorio que contiene el *.tar.bz

```
$docker run --rm -v $(pwd):/data madmex/python-fmask /data/fmask_ls.sh \
/data/LC80210482015303LGN00.tar.bzLE70210492015007EDC00.tar.bz
```

-Ejemplo para archivo de Landsat 8: LC80210482015015LGN00.tar.bz:

Ejecutar el siguiente comando en el directorio que contiene el *.tar.bz

```
$docker run --rm -v $(pwd):/data madmex/python-fmask /data/fmask_ls8.sh \
/data/LC80210482015303LGN00.tar.bzLC80210482015015LGN00.tar.bz
```

Los resultados están en el directorio donde se ejecutó el comando.

###Ingestión de imágenes

El proceso de ingestión de imágenes se realiza con el shell *data_ingestion.sh* al archivo .tar.bz o con el shell *data_ingestion_folder.sh* al folder descomprimido.

-Requerimientos:

	* Imagen de docker para procesos: madmex/ws
	* Shell de data_ingestion.sh que debe tener permisos de ejecución, ir a comandos.md de este repositorio
	* Clonar repositorio de CONABIO/madmex-v2
	* Archivo de configuración con el nombre "configuration.ini" ir a configuraciones.md de este respositorio
	* Crear carpetas "resources/config" y colocar ahí el archivo de configuración
	* Crear carpeta "eodata", aquí se copiaran las imágenes.
	* Archivo de variables de entorno que se usarán, se guardan en el archivo llamado "variables.txt" \
	 en el directorio en donde está el shell:

```
export MADMEX=/LUSTRE/MADMEX/code/
export MRV_CONFIG=$MADMEX/resources/config/configuration.ini
export PYTHONPATH=$PYTHONPATH:$MADMEX
export MADMEX_DEBUG=True
export MADMEX_TEMP=/services/localtemp/temp

```

-Ejemplo para el archivo: LC80210482015015LGN00.tar.bz. En este ejemplo:

	* Dentro del directorio de trabajo tenemos el shell de data_ingestion.sh, que debe tener permisos de ejecución, ir a comandos.md de este repositorio
	* En ruta: /madmex-v2 tenemos clonado el repositorio de CONABIO/madmex-v2
	* En ruta: /resources/config tenemos el archivo configuration.ini
	* En el directorio de trabajo tenemos el archivo a ingestar: LC80210482015015LGN00.tar.bz
	* En el directorio de trabajo tenemos el archivo de variables.txt
	* En ruta: /datos/eodata queremos que se copien los archivos

Ejecutamos la siguiente línea

```
docker run --rm -v /madmex-v2:/LUSTRE/MADMEX/code \
-v /resources/config:/LUSTRE/MADMEX/code/resources/config \
-v /datos/eodata:/LUSTRE/MADMEX/eodata -v $(pwd):/results madmex/ws \
/results/data_ingestion.sh /results/LC80210482015015LGN00.tar.bz
```

Los resultados están en el directorio de trabajo bajo el directorio eodata y en la base de datos

Si quisiéramos ingestar los resultados del proceso de fmask o de ledaps usar el shell: data_ingestion_folder.sh al folder que se descomprimió con estos procesos. En la base de datos y en el folder eodata, se ingestarán y copiarán tanto las imágenes que se descargaron y descomprimieron del archivo .tar.bz, como los resultados del preprocesamiento.

-Ejemplo para el folder: LC80210482015015LGN00. En este ejemplo:


	* Dentro del directorio de trabajo tenemos el shell de data_ingestion.sh, que debe tener permisos de ejecución, ir a comandos.md de este repositorio
	* En ruta: /madmex-v2 tenemos clonado el repositorio de CONABIO/madmex-v2
	* En ruta: /resources/config tenemos el archivo configuration.ini
	* En el directorio de trabajo tenemos el folder a ingestar: LC80210482015015LGN00
	* En el directorio de trabajo tenemos el archivo de variables.txt
	* En ruta: /datos/eodata queremos que se copien los archivos

Ejecutamos la siguiente línea

```
docker run --rm -v /madmex-v2:/LUSTRE/MADMEX/code \
-v /resources/config:/LUSTRE/MADMEX/code/resources/config \
-v /datos/eodata:/LUSTRE/MADMEX/eodata -v $(pwd):/results madmex/ws \
/results/data_ingestion_folder.sh /results/LC80210482015015LGN00
```


###Preprocesamiento e ingestión TM y ETM+ para datos después del año 2013

-Requerimientos:

	* Shell preprocesamiento_e_ingestion_no_landsat_8.sh que debe tener permisos de ejecución, ir a comandos.md de este repositorio
	* Datos en formato .tar.bz
	* Ancillary data para LEDAPS
	* Archivo de configuración con el nombre "configuration.ini", ir a configuraciones.md de este respositorio.
	* Crear carpetas "resources/config" y colocar ahí el archivo de configuración
	* Clonar repositorio de CONABIO/madmex-v2
	* Crear carpeta "eodata", aquí se copiaran las imágenes.


-Ejemplo para el archivo: LE70210482015055EDC00.tar.bz

	* En el directorio de trabajo tenemos los datos .tar.bz
	* En ruta: /ancillary_data tenemos descomprimido el ancillary data
	* En ruta: /madmex-v2 tenemos clonado el repositorio de CONABIO/madmex-v2
	* En ruta: /resources/config tenemos el archivo configuration.ini
	* En ruta: /datos/eodata queremos que se copien los archivos


Ejecutamos la siguiente línea:

```
$preprocesamiento_e_ingestion_landsat_no_8.sh LE70210482015055EDC00.tar.bz /ancillary_data /madmex-v2 /resources/config /datos/eodata

```

###Clasificación

-Requerimientos:

	* Imagen de docker para procesos
	* Al menos 3 imágenes descargadas de un tile, preprocesadas y registradas en la base de datos.
	* Registrar algoritmo y leyenda en la base de datos.
	* Datos de entrenamiento y registrarlos en la base de datos dentro del esquema products tabla product.
	* Datos auxiliares: dem, aspect, slope en la ruta especificada en el archivo de configuración configuration.ini
		en el tag aux-data
	* Shell clasificacion_landsat.sh que debe tener permisos de ejecución, ir a comandos.md de este repositorio
	* Folder temporal donde se guardarán archivos de procesamiento.
	* Folders madmex_processing_result, lsclassificationcommand, products donde se guardarán resultados de clasificación.
	* Archivo de variables de entorno que se usarán, se guardan en el archivo llamado "variables.txt" \
	 en el directorio en donde está el shell:

```
export MADMEX=/LUSTRE/MADMEX/code/
export MRV_CONFIG=$MADMEX/resources/config/configuration.ini
export PYTHONPATH=$PYTHONPATH:$MADMEX
export MADMEX_DEBUG=True
export MADMEX_TEMP=/services/localtemp/temp

```



-Ejemplo : 

	* En ruta: /madmex-v2 tenemos clonado el repositorio de CONABIO/madmex-v2
	* En ruta: /resources/config tenemos el archivo configuration.ini
	* En ruta: /datos/eodata tenemos los datos originales y resultados del preprocesamiento copiados con el proceso de ingest.
	* En ruta: /products/inegiusvpersii-v tenemos los datos de entrenamiento
	* En ruta: /products/dem/inegi tenemos los datos auxiliares: dem, aspect, slope (de acuerdo al configuration.ini)
	* En ruta: /temporal se tendrá el folder temporal
	* En rutas: /madmex_processing_results, /products y /lsclassificationcommand se tendrán resultados de clasificación
	* En el directorio de trabajo tenemos el archivo de variables.txt
	* Path: 021, row:048
	* Año: 2014
	* Conjunto de entrenamiento: training_areas_persistentes_32_clases_125m.tif
	* Máximo porcentaje de nubes para cada imagen: 10%
	* Eliminación de datos atípicos (1)

Para registrar la leyenda en la base de datos:

```
insert into "products"."legend"("id", "name", "description", "sld") values(0, 'dummy_legend', 'empty dummy legend', '<?xml version="1.0" ?>')

```


Para registrar el algoritmo en la base de datos:

```
insert into "products"."algorithm"("id", "description", "command", "supervised") values (1, 'MAD-MEX Landsat Landcover Classification Workflow', 'LSClassificationCommand', 'true');

```


Para registrar los datos de entrenamiento en la base de datos:

```
insert into "products"."product" ("id", "uuid", "date_from", "date_to", "algorithm", "legend", "provider", "file_url", "proc_date", "ingest_date", "the_geom", "rows", "columns", "bands", "resolution", "projection") values (1, '43ed65a9-8719-4bdc-a375-a987c49de19c', '2016-01-01', '2016-12-31', 1, 0, 'CONABIO', '/LUSTRE/MADMEX/products/inegiusvpersii-v/training_areas_persistentes_32_clases_125m.tif', '2015-09-08 16:42:07', '2015-09-08 11:49:01', '0103000000010000000500000048B437AD505554C03F7E00ADC44A0BC075FE61FE9F9A53C09BF40773C0430BC0BCBE2357C99953C04850CF114DCF1AC0ECBC64616C5554C012F7D91A39D61AC048B437AD505554C03F7E00ADC44A0BC0', 1, 1, 1, 1.0, 'PROJCS["WGS 84 / UTM zone 17N",GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433],AUTHORITY["EPSG","4326"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-81],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],UNIT["metre",1,AUTHORITY["EPSG","9001"]],AUTHORITY["EPSG","32617"]]')

```

Ejecutar el siguiente comando:

```
$docker run --rm -v $(pwd)/products:/LUSTRE/MADMEX/products \
-v /LUSTRE/MADMEX/products/dem:/LUSTRE/MADMEX/products/dem \
-v /LUSTRE/MADMEX/products/inegiusvpersii-v:/LUSTRE/MADMEX/products/inegiusvpersii-v/ \
-v $(pwd)/datos/eodata:/LUSTRE/MADMEX/eodata -v /madmex-v2:/LUSTRE/MADMEX/code \
-v /resources/config:/LUSTRE/MADMEX/code/resources/config \
-v /madmex_processing_results:/LUSTRE/MADMEX/processes/madmex_processing_results/ \
-v $(pwd)/lsclassificationcommand:/LUSTRE/MADMEX/products/lsclassificationcommand/ \
-v /temporal:/services/localtemp/temp -v $(pwd):/results madmex/ws:latest \
/results/clasificacion_landsat.sh 2014-01-01 2014-12-31 10 21048 \
/LUSTRE/MADMEX/products/inegiusvpersii-v/training_areas_persistentes_32_clases_125m.tif 1


```

###Postprocesamiento de clasificación

-Requerimientos:

	*Archivo ESRI de los tiles de la región
	*Nombre de columna del archivo ESRI que contiene los tiles de la región

-Ejemplo:

	* Dirección IP del host en el que está levantado el servidor de postgres es 192.168.99.100
	* En la base de datos dentro del esquema vectordata tenemos registrada la tabla de tiles "landsat_footprints_mexico"
	* El nombre del archivo ESRI será landsat_footprint_mexico


```
$docker run --rm -v $(pwd):/results -it madmex/postgres-client \
pgsql2shp -f /results/landsat_footprint_mexico -h 192.168.99.100 -p 32851 \
-u madmex_user madmex_database vectordata.landsat_footprints_mexico
```

En el directorio de trabajo tendremos el archivo ESRI.


Para el postprocesamiento tenemos:


	*En la carpeta /resultados_clasificacion tenemos los resultados del proceso de clasificación anterior
	*Nuestro archivo ESRI se llama landsat_footprints_mexico.shp
	*En el archivo ESRI tenemos la columna code que contiene los tiles de mexico
	*En la carpeta /resultados_postprocesamiento tendremos los resultados que ayudan al postprocesamiento
	*El archivo postprocesamiento.tif es el resultado del postprocesamiento y se guarda en la carpeta /resultado_postprocesamiento/

```
docker run --rm -v /madmex-v2:/LUSTRE/MADMEX/code \
-v /lsclassificationcommand/2015_2015/training_1:/results_classification
-v /resultados_postprocesamiento:/results_postprocessing
-v /resources/config:/LUSTRE/MADMEX/code/resources/config \
-v $(pwd):/results madmex/ws /results/postprocesamiento_clasificacion_landsat.sh \
/results_classification/ /results/landsat_footprints_mexico.shp code /results_postprocessing/ /results/postprocesamiento.tif




```

###Detección de cambios



##Rapideye

###Descarga de imágenes

###Ingestión de imágenes y preprocesamiento

###Clasificación

###Detección de cambios

