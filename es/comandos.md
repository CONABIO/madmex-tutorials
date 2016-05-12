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

####Preprocesamiento

*fmask.sh*

```
#!/bin/bash

filename=$(basename $1)

newdir=$(echo $filename | sed -e "s/.tar.bz/$replace/g")

MADMEX_TEMP=$(echo $PWD)
echo $MADMEX_TEMP
new_filename=$MADMEX_TEMP/$filename

mkdir -p $MADMEX_TEMP/$newdir
cd $MADMEX_TEMP/$newdir

tar xvjf $new_filename

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img L*_B[1,2,3,4,5,7].TIF

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img L*_B6_VCID_?.TIF

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatSaturationMask.py -i ref.img -m *_MTL.txt -o saturationmask.img

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatTOA.py -i ref.img -m *_MTL.txt -o toa.img

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m *_MTL.txt -s saturationmask.img -o cloud.img

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask gdal_translate -of ENVI cloud.img $(echo $newfilename)_MTLFmask
```

*fmask_ls8.sh*

```
#!/bin/bash

filename=$(basename $1)

newdir=$(echo $filename | sed -e "s/.tar.bz/$replace/g")

MADMEX_TEMP=$(echo $PWD)
echo $MADMEX_TEMP
new_filename=$MADMEX_TEMP/$filename

mkdir -p $MADMEX_TEMP/$newdir
cd $MADMEX_TEMP/$newdir

tar xvjf $new_filename

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img L[C-O]8*_B[1-7,9].TIF
docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img L[C-O]8*_B1[0,1].TIF

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatSaturationMask.py -i ref.img -m *_MTL.txt -o saturationmask.img

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatTOA.py -i ref.img -m *_MTL.txt -o toa.img

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m *_MTL.txt -s saturationmask.img -o cloud.img

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask gdal_translate -of ENVI cloud.img $(echo $newfilename)_MTLFmask
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


