#Esta documentación muestra el uso del sistema madmex


##Landsat

###Descarga de imágenes

-Requerimientos:

	* instalado gsutil
	* path, row de landsat
	* Año
	* Sensor: elegir entre landsat tm, etm+, oli-tirs

-Ejemplo:

	* path: 021, row: 048
	* año: 2015
	* sensor: oli-tirs (L8)

```
$descarga_landsat.sh L8 021 048 2015
```

-En el directorio en el que se ejecutó el comando tendremos la carpeta: landsat_tile_021048

-En esta carpeta se encuentran archivos con extensión *.tar.bz


###Ingestión de imágenes y preprocesamiento

-Requerimientos:

	* contenedor de docker para preprocesamiento

-Ejemplo para un archivo dentro de la carpeta: landsat_tile_021048

```
$preprocessingfromarchive_landsat.sh ./landsat_tile_021048/LC80210482015239LGN00.tar.bz
```

###Clasificación

-Requerimientos:

	* datos de entrenamiento registrados en la base de datos dentro del esquema products tabla product


-Ejemplo para path,row 021048 con conjunto de entrenamiento datos_entrenamiento.tif y eliminación de datos atípicos (1)


```
$ls_classification_qsub.sh 2015-01-01 2015-12-31 10 21048 ./datos_entrenamiento.tif 1
```

###Detección de cambios



##Rapideye

###Descarga de imágenes

###Ingestión de imágenes y preprocesamiento

###Clasificación

###Detección de cambios

