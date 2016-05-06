#Esta documentación muestra el uso del sistema madmex en una versión stand alone

Es crucial una instalación de docker en su sistema: https://www.docker.com/

##Landsat

###Descarga de imágenes

-Requerimientos:

	* Path, row de tile de landsat
	* Año a descargar imágenes
	* Instrumento a elegir entre tm, etm+, oli-tirs
	* shell de descarga

-Ejemplo: descarga todas las imágenes landsat del año 2015

	* path: 021, row: 048
	* año: 2015
	* Instrumento: etm+ (L7)

Para la siguiente línea usar el shell *descarga_landsat.sh* que se encuentra en *shell_references.md* de este repositorio.
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
madmex/ledaps-legacy:latest /opt/ledaps /data/LE70210481999203AGS00.tar.bz /results
```

Los resultados están en el path: /resultados_ledaps

####FMASK

-Ejemplo para LE70210492015007EDC00.tar.bz, el cual debe de estar descomprimido

Ejecutar los siguientes comandos en la carpeta donde se descomprimió

```
$docker run -v $(pwd):/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img L*_B[1,2,3,4,5,7].TIF
$docker run -v $(pwd):/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img L*_B6_VCID_?.TIF
$docker run -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatSaturationMask.py -i ref.img -m *_MTL.txt -o saturationmask.img
$docker run -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatTOA.py -i ref.img -m *_MTL.txt -o toa.img
$docker run -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m *_MTL.txt -s saturationmask.img -o cloud.img
$docker run -v $(pwd):/data madmex/python-fmask gdal_translate -of ENVI cloud.img LE70210492015007EDC00_MTLFmask
```

-Ejemplo para L8: LC80210482015015LGN00.tar.bz, el cual debe de estar descomprimido

Ejecutar los siguientes comandos en la carpeta donde se descomprimió

```
$docker run -v $(pwd):/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img LC8*_B[1-7,9].TIF
$docker run -v $(pwd):/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img LC8*_B1[0,1].TIF
$docker run -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatSaturationMask.py -i ref.img -m *_MTL.txt -o saturationmask.img
$docker run -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatTOA.py -i ref.img -m *_MTL.txt -o toa.img
$docker run -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m *_MTL.txt -s saturationmask.img -o cloud.img
$docker run -v $(pwd):/data madmex/python-fmask gdal_translate -of ENVI cloud.img LE70210492015007EDC00_MTLFmask
```


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

