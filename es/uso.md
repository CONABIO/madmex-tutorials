#Esta documentación muestra el uso del sistema madmex en una versión stand alone

Es crucial una instalación de docker en su sistema: https://www.docker.com/

##Base de datos

###Levantamiento del servidor de postgres

Ejecutar el siguiente comando después de clonar este repositorio dentro de la carpeta "comandos_base_de_datos_madmex" de manera local:

```
$docker run --name postgres-server-madmex -v $(pwd):/commands -p 32852:22 -p 32851:5432 -dt madmex/postgres-server
```

###Creación de la base de datos madmex

-Requerimientos:

	*Dirección IP del host en el que está levantado el servidor de postgres
	*shells de creación de base de datos, ir a la carpeta comandos_base_de_datos_madmex de este repositorio
	*shell madmex_database_install.sh que debe tener permisos de ejecución, ir a comandos.md de este repositorio

-Ejemplo: 

	*Dirección IP del host: 192.168.99.100

```
$docker exec -u=postgres -it postgres-server-madmex /bin/bash /commands/madmex_database_install.sh 192.168.99.100 32851
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

*En el directorio en el que se ejecutó el comando tendremos la carpeta: landsat_tile_021048*

*En esta carpeta se encuentran archivos con extensión *.tar.bz*


-Ejemplo descarga de un archivo: 

Podemos listar los archivos disponibles de landsat con el siguiente comando, por ejemplo para Landsat 7 path 021, row 048:


```
$docker run --rm -v $(pwd):/results  madmex/ws:latest gsutil ls gs://earthengine-public/landsat/L7/021/048/
```

	* Archivo a descargar gs://earthengine-public/landsat/L7/021/049/LE70210492015007EDC00.tar.bz

```
$docker run --rm -v $(pwd):/results  madmex/ws:latest gsutil \ 

cp gs://earthengine-public/landsat/L7/021/049/LE70210492015007EDC00.tar.bz /results
```

*En el directorio en el que se ejecutó el comando tendremos la carpeta: landsat_un_archivo*

*En esta carpeta se encontrará el archivo con extensión *.tar.bz descargado*

###Preprocesamiento

####LEDAPS, sensor tm o etm+
-Requerimientos:
	
	* ancillary data:  http://espa.cr.usgs.gov/downloads/auxiliaries/ledaps_auxiliary/ledaps_aux.1978-2014.tar.gz

-Ejemplo para datos después del año 2012-2013 con el archivo LE70210492015007EDC00.tar.bz:

	*En ruta: /datos_landsat tenemos el LE70210492015007EDC00.tar.bz
	*En ruta: /resultados_ledaps queremos los resultados del preprocesamiento
	*En ruta: /ancillary_data tenemos descomprimido el ancillary data
	*Usamos la imagen: ledaps/ledaps:latest

Entonces ejecutamos el siguiente comando:


```
docker run --rm -v /ancillary_data:/opt/ledaps \
-v /datos_landsat:/data -v /resultados_ledaps:/results \
madmex/ledaps:latest /opt/ledaps /data/LE70210492015007EDC00.tar.bz /results
```

Los resultados están en el path: /resultados_ledaps

-Ejemplo para datos antes del año 2012-2013 con el archivo LE70210481999203AGS00.tar.bz:

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
	* Archivo de configuración con el nombre "configuration.ini" en el directorio donde se ejecutará el shell, \
		ir a configuraciones.md de este respositorio
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

	* Tenemos dentro del directorio de trabajo el directorio madmex-v2 el cual \
		fue clonado del repositorio CONABIO/madmex-v2
	* Dentro del directorio de trabajo tenemos el shell de data_ingestion.sh
	* En el directorio de trabajo creamos el directorio eodata
	* En el directorio de trabajo tenemos el archivo a ingestar: LC80210482015015LGN00.tar.bz
	* En el directorio de trabajo tenemos el archivo de variables.txt


Ejecutamos la siguiente línea

```
docker run --rm -v $(pwd)/madmex-v2:/LUSTRE/MADMEX/code \
-v $(pwd)/resources/config:/LUSTRE/MADMEX/code/resources/config \
-v $(pwd)/eodata:/LUSTRE/MADMEX/eodata -v $(pwd):/results madmex/ws \
/results/data_ingestion.sh /results/LC80210482015015LGN00.tar.bz
```

Los resultados están en el directorio de trabajo bajo el directorio eodata y en la base de datos

Si quisiéramos ingestar los resultados del proceso de fmask o de ledaps usar el shell: data_ingestion_folder.sh al folder que se descomprimió con estos procesos. En la base de datos y en el folder eodata se ingestarán y copiarán tanto las imágenes como los resultados de estos procesos.

###Clasificación

-Requerimientos:

	* imagen de docker para procesos
	* imágenes descargadas de todo un año
	* datos de entrenamiento registrados en la base de datos dentro del esquema products tabla product


-Ejemplo para path,row 021048 con conjunto de entrenamiento datos_entrenamiento.tif y eliminación de datos atípicos (1)


```
$ls_classification_qsub.sh 2015-01-01 2015-12-31 10 21048 ./datos_entrenamiento.tif 1
```

###Postprocesamiento de clasificación

-Requerimientos:

	*Región de tiles clasificados
	*Archivo ESRI de los tiles de la región
	*Nombre de columna del archivo ESRI que contiene los tiles de la región

-Ejemplo:

	*En la carpeta /resultados_clasificacion tenemos los resultados del proceso de clasificación anterior
	*Nuestro archivo ESRI se llama landsat_footprints_mexico.shp
	*En el archivo ESRI tenemos la columna code que contiene los tiles de mexico
	*En la carpeta /resultados_postprocesamiento tendremos los resultados que ayudan al postprocesamiento
	*El archivo postprocesamiento.tif es el resultado del postprocesamiento y se guarda en la carpeta /resultado_postprocesamiento/

```
$ls_postprocessing_qsub.sh /resultados_clasificacion ./landsat_footprints_mexico.shp code /resultados_postprocesamiento /resultado_postprocesamiento/postprocesamiento.tif
```

###Detección de cambios



##Rapideye

###Descarga de imágenes

###Ingestión de imágenes y preprocesamiento

###Clasificación

###Detección de cambios

