#Documentación técnica para la ejecución de procesos:

##Shells

###Landsat

####Descarga

*descarga_landsat.sh*

```
#!/bin/bash
#$1 es el sensor, $2 es el path, $3 es el row, $4 es el año
gsutil ls gs://earthengine-public/landsat/$1/$2/$3/|grep $4 > lista_landsat_tile_$2$3.txt
mkdir /results/landsat_tile_$2$3
for file in $(cat lista_landsat_tile_$2$3.txt);do
/usr/local/bin/gsutil cp -n $file /results/landsat_tile_$2$3/
done;
```

*descarga_landsat_un_archivo.sh*

```
#!/bin/bash
#$1 es el archivo de landsat a copiar
mkdir /results/landsat_tile

/usr/local/bin/gsutil cp -n $1 /results/landsat_tile/
```

####Ingestión

*data_ingestion.sh*

```
#!/bin/bash
#$1 es la ruta del archivo a ingestar
source /LUSTRE/MADMEX/code/madmex/resources/gridengine/nodo_conabio.txt

/usr/bin/python $MADMEX/interfaces/cli/executer.py IngestionShellCommand --path $1
```

####Clasificación

*ls_classification_qsub.sh*

```
#!/bin/bash
#$1 es la fecha de inicio, $2 es la fecha de fin, $3 es el máximo porcentaje de nubes permitido, $4 es el pathrow,
#$5 es la ruta al conjunto de entrenamiento, $6 es 1 si se quiere hacer eliminación de datos atípicos, 0 en caso contrario
source /LUSTRE/MADMEX/code/madmex/resources/gridengine/nodo_conabio.txt
python $MADMEX/interfaces/cli/madmex_processing.py LandsatLccWorkflowV3 --start_date_string $1 --end_date_string $2 --max_cloud_percentage $3 --landsat_footprint $4 --training_url $5 --outlier $6
```
####Postprocesamiento de clasificación

*ls_postprocessing_qsub.sh*

```
#!/bin/bash
#$1 es el folder que contiene los resultados de clasificación, $2 es el archivo ESRI que contiene los tiles de la región
#$3 es el nombre de la columna del archivo ESRI $2, $4 es el folder donde estarán los resultados que ayudan al postprocesamiento
#$5 es el nombre del archivo resultado del postprocesamiento
source /LUSTRE/MADMEX/code/madmex/resources/gridengine/nodo_conabio.txt
python $MADMEX/interfaces/cli/madmex_processing.py LandsatLccPostWorkflow --lccresultfolder $1 --footprintshape $2 --tileidcolumnname $3 --workingdir $4 --outfile $5
```


