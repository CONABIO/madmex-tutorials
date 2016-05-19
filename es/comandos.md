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

*ledaps.sh*

```
#!/bin/bash
#This shell_script must be executable, if not do a chmod
if [ "$#" -ne 3 ]; then
echo "Usage: bash shell_script <path to ancilliary data in docker> <path to source data in docker/L*.tar.bz> <path to destiny results in docker>"
	exit
else
	name=$(basename $2)
	basename=$(echo $name|sed -n 's/\(L*.*\).tar.bz/\1/;p')
	dir=$3/$basename
	mkdir $dir
	cp $2 $dir
	year=$(echo $name|sed -nE 's/L[A-Z][5-7][0-9]{3}[0-9]{3}([0-9]{4}).*.tar.bz/\1/p')

	cp $1/CMGDEM.hdf $dir
	mkdir $dir/EP_TOMS && cp -r $1/EP_TOMS/ozone_$year $dir/EP_TOMS
	mkdir $dir/REANALYSIS && cp -r $1/REANALYSIS/RE_$year $dir/REANALYSIS
	cd $dir && tar xvf $name 
	metadata=$(ls $dir|grep -E ^L[A-Z]?[5-7][0-9]{3}[0-9]{3}.*_MTL.txt)
	metadataxml=$(echo $metadata|sed -nE 's/(L.*).txt/\1.xml/p')
	cd $dir && $BIN/convert_lpgs_to_espa --mtl=$metadata --xml=$metadataxml
	cd $dir && $BIN/do_ledaps.csh $metadataxml
	cd $dir && $BIN/convert_espa_to_gtif --xml=$metadataxml --gtif=lndsr.$basename.tif 
	cd $dir && $BIN/convert_espa_to_hdf --xml=$metadataxml --hdf=lndsr.$basename.hdf --del_src_files
	rm $dir/$name
	rm -r $dir/CMGDEM.hdf
	rm -r $dir/EP_TOMS/
	rm -r $dir/REANALYSIS/
fi
```

*fmask.sh*

```
#!/bin/bash
filename=$(basename $1)
newdir=$(echo $filename | sed -e "s/.tar.bz//g")
path=$(echo $PWD)
new_filename=$path/$filename
mkdir -p $path/$newdir
cd $path/$newdir
tar xvjf $new_filename
gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img L*_B[1,2,3,4,5,7].TIF
gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img L*_B6_VCID_?.TIF
fmask_usgsLandsatSaturationMask.py -i ref.img -m *_MTL.txt -o saturationmask.img
fmask_usgsLandsatTOA.py -i ref.img -m *_MTL.txt -o toa.img
fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m *_MTL.txt -s saturationmask.img -o cloud.img
gdal_translate -of ENVI cloud.img $(echo $newdir)_MTLFmask
```

*fmask_ls8.sh*

```
#!/bin/bash
filename=$(basename $1)
newdir=$(echo $filename | sed -e "s/.tar.bz//g")
path=$(echo $PWD)
new_filename=$path/$filename
mkdir -p $path/$newdir
cd $path/$newdir
tar xvjf $new_filename
gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img L[C-O]8*_B[1-7,9].TIF
gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img L[C-O]8*_B1[0,1].TIF
fmask_usgsLandsatSaturationMask.py -i ref.img -m *_MTL.txt -o saturationmask.img
fmask_usgsLandsatTOA.py -i ref.img -m *_MTL.txt -o toa.img
fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m *_MTL.txt -s saturationmask.img -o cloud.img
gdal_translate -of ENVI cloud.img $(echo $newfilename)_MTLFmask
```

####Ingestión

*data_ingestion.sh*

```
#!/bin/bash
#$1 es la ruta del archivo .tar.bz a ingestar
filename=$(basename $1)
newdir=$(echo $filename | sed -e "s/.tar.bz//g")
folder=/results
new_filename=$folder/$filename
mkdir -p $folder/$newdir
cd $folder/$newdir
tar xvjf $new_filename
source /results/variables.txt
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $folder/$newdir

```

*data_ingestion_folder.sh*

```
#!/bin/bash
#$1 es la ruta del archivo a ingestar

source /results/variables.txt
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $1

```

####Preprocesamiento e ingestión

*preprocessing_and_ingestion_landsat_not_8.sh*

```
#!/bin/bash
#$1 es la ruta a los datos de landsat .tar.bz
#$2 es la ruta al ancillary data de LEDAPS
#$3 es el path al archivo de configuración

name=$(basename $1)
basename=$(echo $name|sed -n 's/\(L*.*\).tar.bz/\1/;p')
path=$(echo $PWD)
dir=$path/$basename
mkdir -p $dir
cp $1 $dir
cd $dir && tar xvf $name
#LEDAPS:
year=$(echo $name|sed -nE 's/L[A-Z][5-7][0-9]{3}[0-9]{3}([0-9]{4}).*/\1/p')

cp $2/CMGDEM.hdf $dir
mkdir $dir/EP_TOMS && cp -r $2/EP_TOMS/ozone_$year $dir/EP_TOMS
mkdir $dir/REANALYSIS && cp -r $2/REANALYSIS/RE_$year $dir/REANALYSIS
metadata=$(ls $dir|grep -E ^L[A-Z]?[5-7][0-9]{3}[0-9]{3}.*_MTL.txt)
metadataxml=$(echo $metadata|sed -nE 's/(L.*).txt/\1.xml/p')
echo "Working directory:"
echo $(pwd)
docker $(docker-machine config default) run --rm -e metadata=$metadata -e metadataxml=$metadataxml -v $(pwd):/opt/ledaps -v $(pwd):/data -v $(pwd)/:/results madmex/ledaps:latest /bin/sh -c '$BIN/convert_lpgs_to_espa --mtl=$metadata --xml=$metadataxml'
docker $(docker-machine config default) run --rm -e metadataxml=$metadataxml -v $(pwd):/opt/ledaps -v $(pwd):/data -v $(pwd)/:/results madmex/ledaps:latest /bin/sh -c '$BIN/do_ledaps.csh $metadataxml'
docker $(docker-machine config default) run --rm -e metadataxml=$metadataxml -e basename=$basename -v $(pwd):/opt/ledaps -v $(pwd):/data -v $(pwd)/:/results madmex/ledaps:latest /bin/sh -c '$BIN/convert_espa_to_gtif --xml=$metadataxml --gtif=lndsr.$basename.tif'
docker $(docker-machine config default) run --rm -e metadataxml=$metadataxml -e basename=$basename -v $(pwd):/opt/ledaps -v $(pwd):/data -v $(pwd)/:/results madmex/ledaps:latest /bin/sh -c '$BIN/convert_espa_to_hdf --xml=$metadataxml --hdf=lndsr.$basename.hdf --del_src_files'
rm $name
rm CMGDEM.hdf
rm -r EP_TOMS
rm -r REANALYSIS



#Fmask:
docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img L*_B[1,2,3,4,5,7].TIF

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img L*_B6_VCID_?.TIF

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatSaturationMask.py -i ref.img -m *_MTL.txt -o saturationmask.img

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatTOA.py -i ref.img -m *_MTL.txt -o toa.img

docker $(docker-machine config default) run --rm -v $(pwd):/data madmex/python-fmask fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m *_MTL.txt -s saturationmask.img -o cloud.img

docker $(docker-machine config default) run -v $(pwd):/data madmex/python-fmask gdal_translate -of ENVI cloud.img $(echo $basename)_MTLFmask

#Ingest

cd $path

echo "export MADMEX=/LUSTRE/MADMEX/code/" >> variables.txt
echo "export MRV_CONFIG=$MADMEX/resources/config/configuration.ini" >> variables.txt
echo "export PYTHONPATH=$PYTHONPATH:$MADMEX" >> variables.txt
echo "export MADMEX_DEBUG=True" >> variables.txt
echo "export MADMEX_TEMP=/services/localtemp/temp" >> variables.txt
mkdir eodata
git clone https://github.com/CONABIO/madmex-v2.git repo_code_madmex-v2
docker run --rm -v $(pwd)/repo_code_madmex-v2:/LUSTRE/MADMEX/code -v $(pwd)/resources/config:/LUSTRE/MADMEX/code/resources/config -v $(pwd)/eodata:/LUSTRE/MADMEX/eodata -v $(pwd):/results madmex/ws /usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory /results/$basename
rm -r repo_code_madmex-v2


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


