#Esta documentación muestra el uso del sistema madmex

Es crucial una instalación de docker en su sistema: https://www.docker.com/

##Landsat

###Descarga de imágenes

-Requerimientos:

	* Path, row de tile de landsat
	* Año a descargar imágenes
	* Instrumento a elegir entre tm, etm+, oli-tirs
	* shells de descarga

-Ejemplo: descarga todas las imágenes landsat del año 2015

	* path: 021, row: 048
	* año: 2015
	* Instrumento: etm+ (L7)

```
$docker run --rm -v $(pwd):/results  madmex/ws:latest /bin/sh -c '/results/descarga_landsat.sh L7 021 048 2015'
```

*En el directorio en el que se ejecutó el comando tendremos la carpeta: landsat_tile_021048*

*En esta carpeta se encuentran archivos con extensión *.tar.bz*


-Ejemplo descarga de un archivo: 

	* Archivo a descargar gs://earthengine-public/landsat/L7/021/049/LE70210492015007EDC00.tar.bz

```
$docker run --rm -v $(pwd):/results  madmex/ws:latest gsutil cp gs://earthengine-public/landsat/L7/021/049/LE70210492015007EDC00.tar.bz /results
```

*En el directorio en el que se ejecutó el comando tendremos la carpeta: landsat_un_archivo*

*En esta carpeta se encontrará el archivo con extensión *.tar.bz descargado*

###Preprocesamiento

####LEDAPS
-Requerimientos:
	
	* ancilliary data:  http://espa.cr.usgs.gov/downloads/auxiliaries/ledaps_auxiliary/ledaps_aux.1978-2014.tar.gz

-Ejemplo para datos después del año 2012-2013 con el archivo LE70210492015007EDC00.tar.bz:

	*En ruta: /datos_landsat tenemos el LE70210492015007EDC00.tar.bz
	*En ruta: /resultados_ledaps queremos los resultados del preprocesamiento
	*En ruta: /ancilliary_data tenemos descomprimido el ancilliary data
	*Con nombre de imagen: ledaps/ledaps:latest

Entonces ejecutamos el siguiente comando:


```
docker run --rm -v /ancilliary_data:/opt/ledaps \
-v /datos_landsat:/data -v /resultados_ledaps:/results \
madmex/ledaps:latest /opt/ledaps /data/LE70210492015007EDC00.tar.bz /results
```

Los resultados están en el path: /resultados_ledaps

-Ejemplo para datos antes del año 2012-2013 con el archivo LE70210481999203AGS00.tar.bz:

	*En ruta: /datos_landsat tenemos el LE70210481999203AGS00.tar.bz
	*En ruta: /resultados_ledaps queremos los resultados del preprocesamiento
	*En ruta: /ancilliary_data tenemos descomprimido el ancilliary data
	*Con nombre de imagen: madmex/ledaps-legacy:latest


```
docker run --rm -v /ancilliary_data:/opt/ledaps \
-v /datos_landsat:/data -v /resultados_ledaps:/results \
madmex/lspreproc:latest do_ledaps.csh /data/LE70210481999203AGS00.tar.bz
```

Los resultados están en el path: /resultados_ledaps

####FMASK
-Requerimientos:

	* Seguir instruccioneshttps://github.com/amaurs/docker-python-fmask.git 


###Ingestión de imágenes

-Requerimientos:

	* imagen de docker para procesos

-Ejemplo para un archivo dentro de la carpeta: landsat_tile_021048

```
$data_ingestion.sh ./landsat_tile_021048/LE70210482000046EDC00.tar.bz
```

###Clasificación

-Requerimientos:

	* imagen de docker para procesos
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

