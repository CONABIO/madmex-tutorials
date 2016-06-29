#Documentación técnica para la ejecución de procesos:

##Shells

###Landsat

####Descarga

*descarga_landsat.sh*

```
#!/bin/bash
#$1 es el sensor, $2 es el path, $3 es el row, $4 es el año
gsutil ls gs://earthengine-public/landsat/$1/$2/$3/|grep $4 > lista_landsat_tile_$2$3.txt
mkdir -p /$(pwd)/landsat_tile_$2$3
for file in $(cat lista_landsat_tile_$2$3.txt);do
/usr/local/bin/gsutil cp -n $file /$(pwd)/landsat_tile_$2$3/
done;
```

*descarga_tile_landsat.sh*

```
#!/bin/bash
#entrada: $1 es el sensor, $2 es el path, $3 es el row, $4 es el nombre del .tar.bz
/usr/local/bin/gsutil cp gs://earthengine-public/landsat/$1/$2/$3/$4 $5
```


####Preprocesamiento


*ledaps.sh*

```
#!/bin/bash
#Entrada: $1 is the tar file, $2 es la ruta al ancillary data, $3 es la ruta a la carpeta temporal, $4 es la ruta en la que queremos los resultados
source /LUSTRE/MADMEX/gridengine/nodo.txt
replace=""
filename=$(basename $1)
newdir=$(echo $filename | sed -n 's/\(L*.*\).tar.bz/\1/;p')
dir=$MADMEX_TEMP/$newdir
mkdir -p $dir
cp $1 $dir
#new_filename=$MADMEX_TEMP/$filename
cd $dir && tar xvf $filename
#LEDAPS
year=$(echo $filename|sed -nE 's/L[A-Z][5-7][0-9]{3}[0-9]{3}([0-9]{4}).*/\1/p')
cp $2/CMGDEM.hdf $dir
mkdir $dir/EP_TOMS && cp -r $2/EP_TOMS/ozone_$year $dir/EP_TOMS
mkdir $dir/REANALYSIS && cp -r $2/REANALYSIS/RE_$year $dir/REANALYSIS
metadata=$(ls $dir|grep -E ^L[A-Z]?[5-7][0-9]{3}[0-9]{3}.*_MTL.txt)
metadataxml=$(echo $metadata|sed -nE 's/(L.*).txt/\1.xml/p')
ssh docker@172.17.0.1 docker run -w=/data --rm -e LEDAPS_AUX_DIR=/data -e metadata=$metadata -e metadataxml=$metadataxml -v $3/$newdir:/data  madmex/ledaps:latest /usr/local/espa-tools/bin/convert_lpgs_to_espa --mtl=$metadata --xml=$metadataxml
ssh docker@172.17.0.1 docker run -w=/data --rm -e LEDAPS_AUX_DIR=/data -e metadataxml=$metadataxml -v $3/$newdir:/data  madmex/ledaps:latest /usr/local/espa-tools/bin/do_ledaps.csh $metadataxml
ssh docker@172.17.0.1 docker run -w=/data --rm -e LEDAPS_AUX_DIR=/data -e newdir=$newdir -e metadataxml=$metadataxml -v $3/$newdir:/data  madmex/ledaps:latest /usr/local/espa-tools/bin/convert_espa_to_hdf --xml=$metadataxml --hdf=lndsr.$(echo $newdir).hdf --del_src_files
cd $dir && mv lndsr.$(echo $newdir)_MTL.txt lndsr.$(echo $newdir)_metadata.txt
cd $dir && mv lndcal.$(echo $newdir)_MTL.txt lndcal.$(echo $newdir)_metadata.txt
rm $filename
rm -rf CMGDEM.hdf
rm -rf EP_TOMS
rm -rf REANALYSIS
cp -r $dir $4
rm -r $dir
```

*ledaps_antes_2012.sh*


```
#!/bin/bash
#Entrada: $1 es la ruta al archivo tar, $2 es la ruta al ancillary data, $3 es la ruta a la carpeta temporal, $4 es la ruta a la carpeta compartida en el host en la que queremos los resultados
source /LUSTRE/MADMEX/gridengine/nodo.txt

filename=$(basename $1)
newdir=$(echo $filename | sed -n 's/\(L*.*\).tar.bz/\1/;p')
dir=$MADMEX_TEMP/$newdir
mkdir -p $dir
cp $1 $dir
#new_filename=$MADMEX_TEMP/$filename
cd $dir && tar xvf $filename
#LEDAPS
year=$(echo $filename|sed -nE 's/L[A-Z][5-7][0-9]{3}[0-9]{3}([0-9]{4}).*/\1/p')
cp $2/CMGDEM.hdf $dir
mkdir $dir/EP_TOMS && cp -r $2/EP_TOMS/ozone_$year $dir/EP_TOMS
mkdir $dir/REANALYSIS && cp -r $2/REANALYSIS/RE_$year $dir/REANALYSIS
metadata=$(ls $dir|grep -E ^L[A-Z]?[5-7][0-9]{3}[0-9]{3}.*_MTL.txt)
ssh docker@172.17.0.1  docker run -w=/data --rm -e metadata=$metadata -v $2:/opt/ledaps -v $3/$newdir:/data madmex/ledaps-legacy:latest /usr/local/bin/ledapsSrc/bin/do_ledaps.csh $metadata

rm $filename
rm -rf CMGDEM.hdf
rm -rf EP_TOMS
rm -rf REANALYSIS
cp -r $dir $4
rm -r $dir

```

*fmask.sh*

```
#!/bin/bash
#Entrada: $1 es la ruta con los datos en forma .tar.bz, $2 es la ruta que queremos se copien los archivos, $3 es la ruta a la carpeta temporal
source /LUSTRE/MADMEX/gridengine/nodo.txt
filename=$(basename $1)
newdir=$(echo $filename | sed -e "s/.tar.bz//g")
path=$MADMEX_TEMP
new_filename=$path/$filename
mkdir -p $path/$newdir
cp $1 $path/$newdir
cd $path/$newdir
tar xvjf $filename

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img $(ls $MADMEX_TEMP/$newdir|grep L.*_B[1-7].TIF)

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img $(ls $MADMEX_TEMP/$newdir|grep L.*_B6_VCID_[0-9].TIF)

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask fmask_usgsLandsatSaturationMask.py -i ref.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -o saturationmask.img

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask fmask_usgsLandsatTOA.py -i ref.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -o toa.img

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -s saturationmask.img -o cloud.img

cd $MADMEX_TEMP/$newdir && gdal_translate -of ENVI cloud.img $(echo $newdir)_MTLFmask

mkdir -p $MADMEX_TEMP/$newdir/maskfolder

cd $MADMEX_TEMP/$newdir && cp *_MTL.txt maskfolder && mv *_MTLFmask* maskfolder

cp -r $path/$newdir $2

rm -r $path/$newdir
```

*fmask_ls8.sh*

```
#!/bin/bash
#Entrada: $1 es la ruta con los datos en forma .tar.bz, $2 es la ruta que queremos se copien los archivos, $3 es la ruta a la carpeta temporal
source /LUSTRE/MADMEX/gridengine/nodo.txt
filename=$(basename $1)
newdir=$(echo $filename | sed -e "s/.tar.bz//g")
path=$MADMEX_TEMP
new_filename=$path/$filename
mkdir -p $path/$newdir
cp $1 $path/$newdir
cd $path/$newdir
tar xvjf $filename

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img $(ls $MADMEX_TEMP/$newdir|grep L[C-O]8.*_B[1-7,9].TIF)

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img $(ls $MADMEX_TEMP/$newdir|grep L[C-O]8.*_B1[0,1].TIF)

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask fmask_usgsLandsatSaturationMask.py -i ref.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -o saturationmask.img

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask fmask_usgsLandsatTOA.py -i ref.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -o toa.img

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -s saturationmask.img -o cloud.img

cd $MADMEX_TEMP/$newdir && gdal_translate -of ENVI cloud.img $(echo $newdir)_MTLFmask

mkdir -p $MADMEX_TEMP/$newdir/maskfolder

cd $MADMEX_TEMP/$newdir && cp *_MTL.txt maskfolder && mv *_MTLFmask* maskfolder

cp -r $path/$newdir $2

rm -r $path/$newdir
```

####Ingestión

*data_ingestion.sh*

```
#!/bin/bash
source /LUSTRE/MADMEX/gridengine/nodo.txt
filename=$(basename $1)
newdir=$(echo $filename | sed -e "s/.tar.bz//g")
folder=$MADMEX_TEMP
new_filename=$folder/$filename
mkdir -p $folder/$newdir
cp $1 $folder/$newdir
cd $folder/$newdir
tar xvjf $filename
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $folder/$newdir

rm -r $folder/$newdir

```

*data_ingestion_folder.sh*

```
#!/bin/bash
#$1 es la ruta del archivo a ingestar

source /LUSTRE/MADMEX/gridengine/nodo.txt
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $1

```

####Preprocesamiento e ingestión

*preprocesamiento_e_ingestion_landsat_no_8_datos_despues_2012.sh*

```
#!/bin/bash
#Entrada: $1 es el archivo tar, $2 es la ruta al ancillary data, $3 es la ruta a la carpeta temporal
source /LUSTRE/MADMEX/gridengine/nodo.txt
filename=$(basename $1)
newdir=$(echo $filename | sed -n 's/\(L*.*\).tar.bz/\1/;p')
dir=$MADMEX_TEMP/$newdir
mkdir -p $dir
cp $1 $dir
#new_filename=$MADMEX_TEMP/$filename
cd $dir && tar xvf $filename
#LEDAPS
year=$(echo $filename|sed -nE 's/L[A-Z][5-7][0-9]{3}[0-9]{3}([0-9]{4}).*/\1/p')
cp $2/CMGDEM.hdf $dir
mkdir $dir/EP_TOMS && cp -r $2/EP_TOMS/ozone_$year $dir/EP_TOMS
mkdir $dir/REANALYSIS && cp -r $2/REANALYSIS/RE_$year $dir/REANALYSIS
metadata=$(ls $dir|grep -E ^L[A-Z]?[5-7][0-9]{3}[0-9]{3}.*_MTL.txt)
metadataxml=$(echo $metadata|sed -nE 's/(L.*).txt/\1.xml/p')
ssh docker@172.17.0.1 docker run -w=/data --rm -e LEDAPS_AUX_DIR=/data -e metadata=$metadata -e metadataxml=$metadataxml -v $3/$newdir:/data  madmex/ledaps:latest /usr/local/espa-tools/bin/convert_lpgs_to_espa --mtl=$metadata --xml=$metadataxml
ssh docker@172.17.0.1 docker run -w=/data --rm -e LEDAPS_AUX_DIR=/data -e metadataxml=$metadataxml -v $3/$newdir:/data  madmex/ledaps:latest /usr/local/espa-tools/bin/do_ledaps.csh $metadataxml
ssh docker@172.17.0.1 docker run -w=/data --rm -e LEDAPS_AUX_DIR=/data -e newdir=$newdir -e metadataxml=$metadataxml -v $3/$newdir:/data  madmex/ledaps:latest /usr/local/espa-tools/bin/convert_espa_to_hdf --xml=$metadataxml --hdf=lndsr.$(echo $newdir).hdf --del_src_files
cd $dir && mv lndsr.$(echo $newdir)_MTL.txt lndsr.$(echo $newdir)_metadata.txt
cd $dir && mv lndcal.$(echo $newdir)_MTL.txt lndcal.$(echo $newdir)_metadata.txt
rm $filename
rm -rf CMGDEM.hdf
rm -rf EP_TOMS
rm -rf REANALYSIS

#FMASK

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img $(ls $MADMEX_TEMP/$newdir|grep L.*_B[1-7].TIF)

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img $(ls $MADMEX_TEMP/$newdir|grep L.*_B6_VCID_[0-9].TIF)

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask fmask_usgsLandsatSaturationMask.py -i ref.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -o saturationmask.img

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask fmask_usgsLandsatTOA.py -i ref.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -o toa.img

ssh docker@172.17.0.1 docker run --rm -v $3/$newdir:/data madmex/python-fmask fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -s saturationmask.img -o cloud.img

cd $MADMEX_TEMP/$newdir && gdal_translate -of ENVI cloud.img $(echo $newdir)_MTLFmask

#mkdir -p $MADMEX_TEMP/$newdir/maskfolder

#cd $MADMEX_TEMP/$newdir && cp *_MTL.txt maskfolder && mv *_MTLFmask* maskfolder

#INGEST

/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $MADMEX_TEMP/$newdir

#/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $MADMEX_TEMP/$newdir/maskfolder

rm -r $MADMEX_TEMP/$newdir/

```

*preprocesamiento_e_ingestion_landsat_8.sh*

```
#!/bin/bash
#Entrada: $1 es la ruta con los datos en forma .tar.bz, $2 es la ruta a la carpeta temporal
source /LUSTRE/MADMEX/gridengine/nodo.txt
filename=$(basename $1)
newdir=$(echo $filename | sed -e "s/.tar.bz//g")
path=$MADMEX_TEMP
new_filename=$path/$filename
mkdir -p $path/$newdir
cp $1 $path/$newdir
cd $path/$newdir
tar xvjf $filename

ssh docker@172.17.0.1 docker run --rm -v $2/$newdir:/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img $(ls $MADMEX_TEMP/$newdir|grep L[C-O]8.*_B[1-7,9].TIF)

ssh docker@172.17.0.1 docker run --rm -v $2/$newdir:/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img $(ls $MADMEX_TEMP/$newdir|grep L[C-O]8.*_B1[0,1].TIF)

ssh docker@172.17.0.1 docker run --rm -v $2/$newdir:/data madmex/python-fmask fmask_usgsLandsatSaturationMask.py -i ref.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -o saturationmask.img

ssh docker@172.17.0.1 docker run --rm -v $2/$newdir:/data madmex/python-fmask fmask_usgsLandsatTOA.py -i ref.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -o toa.img

ssh docker@172.17.0.1 docker run --rm -v $2/$newdir:/data madmex/python-fmask fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -s saturationmask.img -o cloud.img

cd $MADMEX_TEMP/$newdir && gdal_translate -of ENVI cloud.img $(echo $newdir)_MTLFmask

#mkdir -p $MADMEX_TEMP/$newdir/maskfolder

#cd $MADMEX_TEMP/$newdir && cp *_MTL.txt maskfolder && mv *_MTLFmask* maskfolder

/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $MADMEX_TEMP/$newdir

#/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $MADMEX_TEMP/$newdir/maskfolder

rm -r $MADMEX_TEMP/$newdir/

```



####Clasificación

*clasificacion_landsat.sh*

```
#!/bin/bash
#Entrada: $1 es la fecha de inicio, $2 es la fecha de fin, $3 es el máximo porcentaje de nubes permitido, $4 es el pathrow, $5 es la ruta al conjunto de entrenamiento, $6 es 1 si se quiere hacer eliminación de datos atípicos, 0 en caso contrario

source /LUSTRE/MADMEX/gridengine/nodo.txt
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py LandsatLccWorkflowV3FilesAfter2012 --start_date_string $1 --end_date_string $2 --max_cloud_percentage $3 --landsat_footprint $4 --training_url $5 --outlier $6
```

*clasificacion_landsat8.sh*

```
#!/bin/bash
#Entrada: $1 es la fecha de inicio, $2 es la fecha de fin, $3 es el máximo porcentaje de nubes permitido, $4 es el pathrow, $5 es la ruta al conjunto de entrenamiento, $6 es 1 si se quiere hacer eliminación de datos atípicos, 0 en caso contrario

source /LUSTRE/MADMEX/gridengine/nodo.txt
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py LandsatLccWorkflowOli --start_date_string $1 --end_date_string $2 --max_cloud_percentage $3 --landsat_footprint $4 --training_url $5 --outlier $6

```


####Postprocesamiento de clasificación

*postprocesamiento_clasificacion_landsat.sh*

```
#!/bin/bash
#$1 es el folder que contiene los resultados de clasificación, $2 es el archivo ESRI que contiene los tiles de la región
#$3 es el nombre de la columna del archivo ESRI $2, $4 es el folder donde estarán los resultados que ayudan al postprocesamiento
#$5 es el nombre del archivo resultado del postprocesamiento
source /results/variables.txt
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py LandsatLccPostWorkflow --lccresultfolder $1 --footprintshape $2 --tileidcolumnname $3 --workingdir $4 --outfile $5
```


