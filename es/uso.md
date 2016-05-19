#Esta documentación muestra el uso del sistema madmex en una versión stand alone

Es crucial una instalación de docker en su sistema: https://www.docker.com/

##Base de datos

###Levantamiento del servidor de postgres

Ejecutar el siguiente comando después de clonar este repositorio dentro de la carpeta "comandos_base_de_datos_madmex" de manera local:

```
$docker run --name postgres-server-madmex -v $(pwd):/results -p 32852:22 -p 32851:5432 -dt madmex/postgres-server
```

###Creación de la base de datos madmex

-Requerimientos:

	*Dirección IP del host en el que está levantado el servidor de postgres
	*shells de creación de base de datos: ir a la carpeta comandos_base_de_datos_madmex de este repositorio
	*shell madmex_database_install.sh

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

####LEDAPS, sensor tm o etm+
-Requerimientos:
	
	* ancillary data:  http://espa.cr.usgs.gov/downloads/auxiliaries/ledaps_auxiliary/ledaps_aux.1978-2014.tar.gz

-Ejemplo para datos después del año 2012-2013 con el archivo LE70210492015007EDC00.tar.bz:

	*En ruta: /datos_landsat tenemos el LE70210492015007EDC00.tar.bz
	*En ruta: /resultados_ledaps queremos los resultados del preprocesamiento
	*En ruta: /ancillary_data tenemos descomprimido el ancillary data
	*Con nombre de imagen: ledaps/ledaps:latest

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
	*Con nombre de imagen: madmex/ledaps-legacy:latest


```
docker run --rm -v /ancillary_data:/opt/ledaps \
-v /datos_landsat:/data -v /resultados_ledaps:/results \
madmex/ledaps-legacy:latest /opt/ledaps /data/LE70210481999203AGS00.tar.bz /results
```

Los resultados están en el path: /resultados_ledaps

####FMASK

-Requerimientos:

	* Para un archivo de Landsat tm o etm+: shell de fmask.sh
	* Para un archivo de Landsat 8: shell de fmask_ls8.sh

-Ejemplo para LE70210492015007EDC00.tar.bz


Ejecutar el siguiente comando en el directorio que contiene el *.tar.bz

```
$./fmask.sh LE70210492015007EDC00.tar.bz
```

-Ejemplo para archivo de Landsat 8: LC80210482015015LGN00.tar.bz:

Ejecutar el siguiente comando en el directorio que contiene el *.tar.bz

```
$./fmask_ls8.sh LC80210482015015LGN00.tar.bz
```
Los resultados están en el directorio donde se ejecutó el comando.

###Ingestión de imágenes

-Requerimientos:

	* Imagen de docker para procesos: madmex/ws
	* Shell de data_ingestion.sh
	* Clonar repositorio de CONABIO/madmex-v2
	* Archivo de configuración con el nombre "configuration.ini" en el directorio donde se ejecutará el shell:

```
[aux-data]
dem = /LUSTRE/MADMEX/products/dem/inegi-cem_v3/CEM3.0_R15m_dem.tif
aspect = /LUSTRE/MADMEX/products/dem/inegi-cem_v3/CEM3.0_R15m_aspect.tif
slope = /LUSTRE/MADMEX/products/dem/inegi-cem_v3/CEM3.0_R15m_slope.tif
training_raster_landsat = /LUSTRE/MADMEX/products/training/inegi-usv250k_persistentes_mrv-conabio_125m.tif
training_raster_rapideye = /LUSTRE/MADMEX/products/training/malla_morelos_utm14_05km_training_level2.tif
dem_aspect_url = /LUSTRE/MADMEX/products/dem/inegi-cem_v3/CEM3.0_R15m_aspect.tif
dem_slope_url = /LUSTRE/MADMEX/products/dem/inegi-cem_v3/CEM3.0_R15m_slope.tif


[folders]
tmpfolder = /services/localtemp/temp/
eodatafolder = /LUSTRE/MADMEX/eodata/
productfolder = /LUSTRE/MADMEX/products/
resultfolder = /LUSTRE/MADMEX/processes/madmex_processing_results/
eodatastagingfolder = /LUSTRE/MADMEX/staging/eodata/
trainingstagingfolder = /LUSTRE/MADMEX/staging/training/
trainingfolder = /LUSTRE/MADMEX/products/training/

[database]
name = database-madmex
debug=False


[database-madmex]
schema_landmask = vectordata
table_landmask = country_mexico
landsat_footprint_table = vectordata.landsat_footprints_mexico
hostname = 172.17.0.1
port = 32851
dbname = madmex_database
username = madmex_user
password = madmex_user.
tablename = events
eoschema = eodata
datasettable = dataset
productschema = products
producttable = product

[database-classification]
schema_landmask = vectordata
table_landmask = mexcontinental_buffer
landsat_footprint_table = vectordata.landsat_footprints_mexico
landsat_overlap_table = vectordata.landsat_etm_mx_footprints_overlaps
hostname = 172.17.0.1
port = 32851
dbname = madmex_classification
username = postgres
password = postgres.
tablename = events

[columns]
landsat_overlap_table_fp1 = fp_id
landsat_overlap_table_fp2 = fp_id_1
landsat_overlap_table_gid= gid
the_geom = the_geom
gid = gid
id = id
given = given
predicted = predicted
confidence = confidence
reference = reference
classcode = predicted
features = features
ia_id = ia_id
fp_id = fp_id
ac_date = ac_date
image_url = image_url
metadata_url = metadata_url
s_id = s_id
cloud_cover = cloud_cover
l_id = l_id

[sql-statements]
select_image_acquisitions = select id, gridid, acq_date, folder_url, sensor, clouds, product from eodata.find_datasets
remove_outsider = select * from classification.remove_outside_polygons

[development]
project_name = madmex
placeholder = #PREFIX#

[raster-processing]
gdal_cache = 512000000
number_of_threads = 3
nodata = -999

[executables]
cmd_c5 = /usr/local/bin/c5.0
cmd_c5_predict = /usr/local/bin/predict
cmd_ledaps = /services/processes/apps/LEDAPS_preprocessing_tool/ledapsSrc_20111121/bin/do_ledaps.csh
cmd_ledaps_ancpath =  /services/localtemp/ledaps_anc/
cmd_fmask = /services/processes/apps/MATLAB/FMASK/src/run_FMASK.sh
matlab_runtime = /services/processes/apps/MATLAB/MATLAB_Compiler_Runtime/
gdal_merge = /usr/local/bin/gdal_merge.py

[fileextensions]
c5result = .result

[logging]
func_log_string = %(levelname)s - %(asctime)s - %(name)s - %(message)s
func_log_level = INFO

adapter_log_string = %(asctime)s: %(message)s
adapter_log_level = INFO

command_log_level = INFO
web_log_level = INFO

use_logstash = True
logstash_host = madmexservices.conabio.gob.mx
logstash_port = 5959
logstash_log_level = INFO

```
	* Crear carpetas "resources/config" y colocar ahí el archivo de configuración
	* Crear carpeta "eodata" en el directorio en donde está el shell
	* Archivo de variables de entorno que se usarán, se guardan en el archivo llamado "variables.txt" en el directorio en donde está el shell:

```
export MADMEX=/LUSTRE/MADMEX/code/
export MRV_CONFIG=$MADMEX/resources/config/configuration.ini
export PYTHONPATH=$PYTHONPATH:$MADMEX
export MADMEX_DEBUG=True
export MADMEX_TEMP=/services/localtemp/temp`

```

-Ejemplo para el archivo: LC80210482015015LGN00.tar.bz:

	* Dentro del directorio de trabajo tenemos el directorio madmex-v2 el cual fue clonado del repositorio CONABIO/madmex-v2
	* Dentro del directorio de trabajo tenemos el shell de data_ingestion.sh
	* Creamos dentro del directorio de trabajo el directorio resources
	* Dentro de resources creamos el directorio config
	* Colocamos en el directorio config el archivo siguiente con nombre "configuration.ini"
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

