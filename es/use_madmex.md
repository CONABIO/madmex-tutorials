#Esta documentación muestra el uso del sistema madmex

Es crucial una instalación de docker en su sistema: https://www.docker.com/ y descargar los contenedores para los procesos de: 

##Landsat

###Descarga de imágenes

-Requerimientos:

	* imagen de docker para procesos, ir a requirements.md -> imágenes de docker
	* Path, row de tile de landsat
	* Año a descargar imágenes
	* Instrumento a elegir entre tm, etm+, oli-tirs

-Ejemplo:

	* path: 021, row: 048
	* año: 2015
	* Instrumento: etm+ (L7)

```
$docker run --rm -v $(pwd):/results  madmex_ws_imagen /bin/sh -c '/results/descarga_landsat.sh L7 021 048 2015'
```

*En el directorio en el que se ejecutó el comando tendremos la carpeta: landsat_tile_021048*

*En esta carpeta se encuentran archivos con extensión *.tar.bz*


-Ejemplo descarga de un archivo: gs://earthengine-public/landsat/L7/021/048/LE70210482012015ASN00.tar.bz


```
$docker run --rm -v $(pwd):/results  madmex_ws_imagen /bin/sh -c '/results/descarga_landsat_un_archivo.sh gs://earthengine-public/landsat/L7/021/048/LE70210482012015ASN00.tar.bz'
```

*En el directorio en el que se ejecutó el comando tendremos la carpeta: landsat_un_archivo*

*En esta carpeta se encontrará el archivo con extensión *.tar.bz descargado*

###Preprocesamiento

####LEDAPS
-Requerimientos:
	
	* imagen de docker para preprocesamiento de ledaps, ir a requirements.md -> imágenes de docker
	* ancilliary data:  http://espa.cr.usgs.gov/downloads/auxiliaries/ledaps_auxiliary/ledaps_aux.1978-2014.tar.gz

-Ejemplo con el archivo LE70210482012015ASN00.tar.bz en la ruta /datos_landsat, directorio de resultados del preprocesamiento: /resultados_ledaps y ruta en la que se encuentra descomprimido el ancilliary data: /ancilliary_data, 

```
docker run --rm -v /ancilliary_data:/opt/ledaps \
-v /datos_landsat:/data -v /resultados_ledaps:/results \
ledaps/ledaps:v1 /opt/ledaps /data/LE70210482012015ASN00.tar.bz /resultados_ledaps
```

####FMASK
-Requerimientos:

	* Clonar el repositorio: https://github.com/amaurs/docker-python-fmask.git y seguir instrucciones


###Ingestión de imágenes

-Requerimientos:

	* imagen de docker para procesos

-Ejemplo para un archivo dentro de la carpeta: landsat_tile_021048

```
$data_ingestion.sh ./landsat_tile_021048/LE70210482000046EDC00.tar.bz
```

###Clasificación

-Requerimientos:

	* imagen de docker para procesos, ir a requirements.md -> imágenes de docker
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

