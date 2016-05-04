#Esta documentación muestra el uso del sistema madmex


##Landsat

###Descarga de imágenes

-Requerimientos:

	* Tener instalado gsutil
	* Path, row de tile de landsat
	* Año a descargar imágenes
	* Instrumento a elegir entre tm, etm+, oli-tirs

-Ejemplo:

	* path: 021, row: 048
	* año: 2015
	* Instrumento: etm+ (L7)

```
$descarga_landsat.sh L7 021 048 2015
```

-En el directorio en el que se ejecutó el comando tendremos la carpeta: landsat_tile_021048

-En esta carpeta se encuentran archivos con extensión *.tar.bz


###Ingestión de imágenes y preprocesamiento

-Requerimientos:

	* contenedor de docker para preprocesamiento

-Ejemplo para un archivo dentro de la carpeta: landsat_tile_021048

```
$preprocessingfromarchive_landsat.sh ./landsat_tile_021048/LE70210482000046EDC00.tar.bz
```

###Clasificación

-Requerimientos:

	* contenedor de docker para
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
$ls_postprocessing_qsub /resultados_clasificacion ./landsat_footprints_mexico.shp code /resultados_postprocesamiento /resultado_postprocesamiento/postprocesamiento.tif
```

###Detección de cambios



##Rapideye

###Descarga de imágenes

###Ingestión de imágenes y preprocesamiento

###Clasificación

###Detección de cambios

