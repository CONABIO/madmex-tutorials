#Esta documentación muestra el uso del sistema madmex en una versión stand alone

Es crucial una instalación de docker en su sistema: https://www.docker.com/

##Base de datos

###Levantamiento del servidor de postgres

Ejecutar el siguiente comando después de clonar este repositorio dentro de la carpeta "es/comandos_base_de_datos_madmex" de manera local:

```
$docker run --name postgres-server-madmex -v $(pwd):/results -p 32852:22 -p 32851:5432 -dt madmex/postgres-server
```

###Creación de la base de datos madmex

-Requerimientos:

	*Dirección IP del host en el que está levantado el servidor de postgres
	*shells de creación de base de datos, ir a la carpeta comandos_base_de_datos_madmex de este repositorio
	*shell madmex_database_install.sh que debe tener permisos de ejecución, ir a comandos.md de este repositorio

-Ejemplo: 

	*Dirección IP del host: 192.168.99.100

```
$docker exec -u=postgres -it postgres-server-madmex /bin/bash /results/madmex_database_install.sh 192.168.99.100 32851
```

##Landsat

###Descarga de imágenes

-Requerimientos:

	* Path, row de tile de landsat
	* Año a descargar imágenes
	* Instrumento a elegir entre tm, etm+, oli-tirs
	* shell de descarga que debe tener permisos de ejecución, ir a comandos.md de este repositorio

-Ejemplo: descarga todas las imágenes landsat del año 2015

	* path: 021, row: 048
	* año: 2015
	* Instrumento: etm+ (L7)

Para la siguiente línea usar el shell *descarga_landsat.sh*

```
$docker run --rm -v $(pwd):/results  madmex/ws:latest /bin/sh -c '/results/descarga_landsat.sh L7 021 048 2015'
```

En el directorio en el que se ejecutó el comando tendremos la carpeta: *landsat_tile_021048*

En esta carpeta se encuentran archivos con extensión *.tar.bz


-Ejemplo descarga de un archivo: 

Podemos listar los archivos disponibles de landsat con el siguiente comando, por ejemplo para Landsat 7 path 021, row 048:


```
$docker run --rm -v $(pwd):/results  madmex/ws:latest gsutil ls gs://earthengine-public/landsat/L7/021/048/
```

Archivo a descargar gs://earthengine-public/landsat/L7/021/049/LE70210492015007EDC00.tar.bz

```
$docker run --rm -v $(pwd):/results  madmex/ws:latest gsutil \ 

cp gs://earthengine-public/landsat/L7/021/049/LE70210492015007EDC00.tar.bz /results
```

En el directorio en el que se ejecutó el comando tendremos el archivo descargado


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

