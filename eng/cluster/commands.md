#Technical documentation for processes execution:

##Shells

###Landsat

####Download

*landsat_downloads.sh*

```
#!/bin/bash
#Inputs: $1 sensor, $2 path, $3 row, $4 year
gsutil ls gs://earthengine-public/landsat/$1/$2/$3/|grep $4 > lista_landsat_tile_$2$3.txt
mkdir -p /$(pwd)/landsat_tile_$2$3
for file in $(cat lista_landsat_tile_$2$3.txt);do
/usr/local/bin/gsutil cp -n $file /$(pwd)/landsat_tile_$2$3/
done;
```

*landsat_downloads_tile.sh*

```
#!/bin/bash
#input: $1 sensor, $2 path, $3 row, $4 .tar.bz name
/usr/local/bin/gsutil cp gs://earthengine-public/landsat/$1/$2/$3/$4 $5
```


####Preprocessing


*ledaps.sh*

```
#!/bin/bash
#Input: $1 is the tar file, $2 path to ancillary data, $3 path to temporal directory, $4 path for output results
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
year=$(echo $filename|sed -nE 's/L[A-Z][4-7][0-9]{3}[0-9]{3}([0-9]{4}).*/\1/p')
cp $2/CMGDEM.hdf $dir
cp $2/L5_TM/gold.dat $dir
cp $2/L5_TM/gnew.dat $dir
cp $2/L5_TM/gold_2003.dat $dirmkdir $dir/EP_TOMS && cp -r $2/EP_TOMS/ozone_$year $dir/EP_TOMS
mkdir $dir/REANALYSIS && cp -r $2/REANALYSIS/RE_$year $dir/REANALYSIS
metadata=$(ls $dir|grep -E ^L[A-Z]?[4-7][0-9]{3}[0-9]{3}.*_MTL.txt)
metadataxml=$(echo $metadata|sed -nE 's/(L.*).txt/\1.xml/p')
ssh docker@172.17.0.1 docker run -w=/data --rm -e LEDAPS_AUX_DIR=/data -e metadata=$metadata -e metadataxml=$metadataxml -v $3/$newdir:/data  madmex/ledaps:latest /usr/local/espa-tools/bin/convert_lpgs_to_espa --mtl=$metadata --xml=$metadataxml
ssh docker@172.17.0.1 docker run -w=/data --rm -e LEDAPS_AUX_DIR=/data -e metadataxml=$metadataxml -v $3/$newdir:/data  madmex/ledaps:latest /usr/local/espa-tools/bin/do_ledaps.csh $metadataxml
ssh docker@172.17.0.1 docker run -w=/data --rm -e LEDAPS_AUX_DIR=/data -e newdir=$newdir -e metadataxml=$metadataxml -v $3/$newdir:/data  madmex/ledaps:latest /usr/local/espa-tools/bin/convert_espa_to_hdf --xml=$metadataxml --hdf=lndsr.$(echo $newdir).hdf --del_src_files
cd $dir && mv lndsr.$(echo $newdir)_MTL.txt lndsr.$(echo $newdir)_metadata.txt
cd $dir && mv lndcal.$(echo $newdir)_MTL.txt lndcal.$(echo $newdir)_metadata.txt
cp lndsr.$(echo $newdir).hdf lndcal.$(echo $newdir).hdf
cp lndsr.$(echo $newdir)_hdf.xml lndcal.$(echo $newdir)_hdf.xml
rm $filename
rm -rf CMGDEM.hdf
rm -rf EP_TOMS
rm -rf REANALYSIS
cp -r $dir $4
rm -r $dir
```

*ledaps_before_2012.sh*


```
#!/bin/bash
#Input: $1 path to tar file, $2 path to ancillary data, $3 path to temporal directory, $4 path to shared folder on the host for output results.
source /LUSTRE/MADMEX/gridengine/nodo.txt

filename=$(basename $1)
newdir=$(echo $filename | sed -n 's/\(L*.*\).tar.bz/\1/;p')
dir=$MADMEX_TEMP/$newdir
mkdir -p $dir
cp $1 $dir
#new_filename=$MADMEX_TEMP/$filename
cd $dir && tar xvf $filename
#LEDAPS
year=$(echo $filename|sed -nE 's/L[A-Z][4-7][0-9]{3}[0-9]{3}([0-9]{4}).*/\1/p')
cp $2/CMGDEM.hdf $dir
cp $2/L5_TM/gold.dat $dir
cp $2/L5_TM/gnew.dat $dir
cp $2/L5_TM/gold_2003.dat $dir
mkdir $dir/EP_TOMS && cp -r $2/EP_TOMS/ozone_$year $dir/EP_TOMS
mkdir $dir/REANALYSIS && cp -r $2/REANALYSIS/RE_$year $dir/REANALYSIS
metadata=$(ls $dir|grep -E ^L[A-Z]?[4-7][0-9]{3}[0-9]{3}.*_MTL.txt)
ssh docker@172.17.0.1  docker run -w=/data --rm -e metadata=$metadata -v $2:/opt/ledaps -v $3/$newdir:/data madmex/ledaps-legacy:latest /usr/local/bin/ledapsSrc/bin/do_ledaps.csh $metadata

rm $filename
rm -rf CMGDEM.hdf
rm -rf EP_TOMS
rm -rf REANALYSIS
cp -r $dir $4
rm -r $dir

```
*ledaps_landsat8.sh*
```
#!/bin/bash
#one: $1 is the path in the host for the tar file
#two: $2 is the path in the host for ancillary data
#three,four: $3, $4 is the username and password for the http://e4ftl01.cr.usgs.gov server
#five, six: $5, $6 is the username and password for the ladssci.nascom.nasa.gov server
#seven : $7 is the path in the host for the temporal folder
source /LUSTRE/MADMEX/gridengine/nodo.txt
name=$(basename $1)
newdir=$(echo $name | sed -n 's/\(L*.*\).tar.bz/\1/;p')
dir=$MADMEX_TEMP/$newdir
mkdir -p $dir
cp $1 $dir
cd $dir

#Prepraring files for LEDAPS:
year=$(echo $name|sed -nE 's/L[A-Z]?[5-8][0-9]{3}[0-9]{3}([0-9]{4}).*.tar.bz/\1/p')
day_of_year=$(echo $name|sed -nE 's/L[A-Z]?[5-8][0-9]{3}[0-9]{3}[0-9]{4}([0-9]{1,3}).*.tar.bz/\1/p')
year_month_day=$(date -d "$year-01-01 +$day_of_year days -1 day" "+%Y.%m.%d")
if [ ! -e $2/LADS/$year/L8ANC$year$day_of_year.hdf_fused ];
then
  #download cmg products
  echo "download cmg products" >> $dir/log.txt
  root=http://e4ftl01.cr.usgs.gov
  mod09=MOLT/MOD09CMG.006
  myd09=MOLA/MYD09CMG.006
  #date_acquired=$(cat $metadata|grep 'DATE_ACQUIRED'|cut -d'=' -f2|sed -n -e "s/-/./g" -e "s/ //p")
  date_acquired=$year_month_day
  echo $date_acquired >> $dir/log.txt
  echo "$root/$mod09/$date_acquired" >> $dir/log.txt
  if [ $(wget -L --user=$3 --password=$4 -qO - $root/$mod09/$date_acquired/|grep "MOD.*.hdf\""|wc -l) -gt 1 ]; then echo "Too many files for MOD09CMG"; else
    wget -L --user=$3 --password=$4 -P $dir -A hdf,xml,jpg -nd -r -l1 --no-parent "$root/$mod09/$date_acquired/"
  fi
  if [ $(wget -L --user=$3 --password=$4 -qO - $root/$myd09/$date_acquired/|grep "MYD.*.hdf\""|wc -l) -gt 1 ]; then echo "Too many files for MYD09CMG"; else
    wget -L --user=$3 --password=$4 -P $dir -A hdf,xml,jpg -nd -r -l1 --no-parent "$root/$myd09/$date_acquired/"
  fi
  #download cma products
  echo "download cma products" >> $dir/log.txt
  root=ftp://$5:$6@ladssci.nascom.nasa.gov
  mod09cma=6/MOD09CMA
  myd09cma=6/MYD09CMA
  if [ $(wget -qO - $root/$mod09cma/$year/$day_of_year/|grep "MOD09CMA.*.hdf\""|wc -l) -gt 1 ]; then echo "Too many files for MOD09CMA"; else
    wget -A hdf -P $dir -nd -r -l1 --no-parent "$root/$mod09cma/$year/$day_of_year/"
  fi
  if [ $(wget -qO - $root/$mod09cma/$year/$day_of_year/|grep "MOD09CMA.*.hdf\""|wc -l) -gt 1 ]; then echo "Too many files for MYD09CMA"; else
    wget -A hdf -P $dir -nd -r -l1 --no-parent "$root/$myd09cma/$year/$day_of_year/"
  fi
  #combine aux data
  terra_cmg=$(ls .|grep MOD09CMG.*.hdf$)
  echo $terra_cmg >> $dir/log.txt
  terra_cma=$(ls .|grep MOD09CMA.*.hdf$)
  echo $terra_cma >> $dir/log.txt
  aqua_cma=$(ls .|grep MYD09CMA.*.hdf$)
  aqua_cmg=$(ls .|grep MYD09CMG.*.hdf$)
  echo $aqua_cma >> $dir/log.txt
  echo $aqua_cmg >> $dir/log.txt
  ssh 172.17.0.1 docker run --rm -v $7/$newdir:/data -w=/data -e terra_cmg=$terra_cmg -e terra_cma=$terra_cma -e aqua_cma=$aqua_cma -e aqua_cmg=$aqua_cmg madmex/ledaps-landsat8  /usr/local/espa-tools/bin/combine_l8_aux_data --terra_cmg=$terra_cmg --terra_cma=$terra_cma --aqua_cmg=$aqua_cmg --aqua_cma=$aqua_cma --output_dir=/data
  #copy the combine aux data for future processes
  anc=$(ls .|grep ANC)
  mkdir -p $2/LADS/$year
  cp $anc $2/LADS/$year
  #move the combine aux data
  mkdir -p LADS/$year
  mv $anc LADS/$year
  #else
else
  echo "found fused file, not downloading" >> $dir/log.txt
  mkdir -p LADS/$year
  anc=$(ls $2/LADS/$year|grep ".*$year$day_of_year")
  cp $2/LADS/$year/$anc LADS/$year/
fi

#surface reflectances:
echo "Beginning untar"
#untar file
tar xvf $name
echo "finish untar"
metadata=$(ls .|grep -E ^L[A-Z]?[5-8][0-9]{3}[0-9]{3}.*_MTL.txt)
metadataxml=$(echo $metadata|sed -nE 's/(L.*).txt/\1.xml/p')
echo $metadata >> $dir/log.txt
echo $metadataxml >> $dir/log.txt
echo "finish identification of metadata"
ssh 172.17.0.1 docker run --rm -v $7/$newdir:/data -w=/data -e metadata=$metadata -e metadataxml=$metadataxml madmex/ledaps-landsat8 /usr/local/espa-tools/bin/convert_lpgs_to_espa --mtl=$metadata --xml=$metadataxml
#check if the next line is important for the analysis
#line: $BIN/create_land_water_mask --xml=$metadataxml
cp -r $2/LDCMLUT .
cp $2/ratiomapndwiexp.hdf .
cp $2/CMGDEM.hdf .
echo "Surface reflectance process" >> $dir/log.txt
ssh 172.17.0.1 docker run --rm -v $7/$newdir:/data -w=/data -e LEDAPS_AUX_DIR=/data -e anc=$anc -e metadataxml=$metadataxml madmex/ledaps-landsat8 /usr/local/espa-tools/bin/lasrc --xml=$metadataxml --aux=$anc --verbose --write_toa
ssh 172.17.0.1 docker run --rm -v $7/$newdir:/data -w=/data -e newdir=$newdir -e metadataxml=$metadataxml madmex/ledaps-landsat8 /usr/local/espa-tools/bin/convert_espa_to_hdf --xml=$metadataxml --hdf=lndsr.$(echo $newdir).hdf --del_src_files
echo "finish surface reflectance" >> $dir/log.txt
mv lndsr.$(echo $newdir)_MTL.txt lndsr.$(echo $newdir)_metadata.txt
#mv lndcal.$(echo $newdir)_MTL.txt lndcal.$(echo $newdir)_metadata.txt
cp lndsr.$(echo $newdir).hdf lndcal.$(echo $newdir).hdf
cp lndsr.$(echo $newdir)_hdf.xml lndcal.$(echo $newdir)_hdf.xml

```
*fmask.sh*

```
#!/bin/bash
#Input: $1 path to .tar.bz files , $2 path that we want the files to be copied, $3 path to temporal directory
source /LUSTRE/MADMEX/gridengine/nodo.txt
filename=$(basename $1)
newdir=$(echo $filename | sed -n 's/\(L*.*\).tar.bz/\1/;p')
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
#Input: $1 path to .tar.bz files, $2 path that we want the files to be copied, $3 path to temporal directory
source /LUSTRE/MADMEX/gridengine/nodo.txt
filename=$(basename $1)
newdir=$(echo $filename | sed -n 's/\(L*.*\).tar.bz/\1/;p')
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

####Ingestion

*data_ingestion.sh*

```
#!/bin/bash
source /LUSTRE/MADMEX/gridengine/nodo.txt
filename=$(basename $1)
newdir=$(echo $filename | sed -n 's/\(L*.*\).tar.bz/\1/;p')
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
#$1 path to the file to ingest

source /LUSTRE/MADMEX/gridengine/nodo.txt
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $1

```

####Preprocessing and ingestion

*preprocessing_and_ingestion_landsat8_data_after_2012.sh*

```
#!/bin/bash
#Input: $1 path to tar file, $2 path to ancillary data, $3 path to temporal directory
source /LUSTRE/MADMEX/gridengine/nodo.txt
filename=$(basename $1)
newdir=$(echo $filename | sed -n 's/\(L*.*\).tar.bz/\1/;p')
dir=$MADMEX_TEMP/$newdir
mkdir -p $dir
cp $1 $dir
#new_filename=$MADMEX_TEMP/$filename
cd $dir && tar xvf $filename
#LEDAPS
year=$(echo $filename|sed -nE 's/L[A-Z][4-7][0-9]{3}[0-9]{3}([0-9]{4}).*/\1/p')
cp $2/CMGDEM.hdf $dir
cp $2/L5_TM/gold.dat $dir
cp $2/L5_TM/gnew.dat $dir
cp $2/L5_TM/gold_2003.dat $dirmkdir $dir/EP_TOMS && cp -r $2/EP_TOMS/ozone_$year $dir/EP_TOMS
mkdir $dir/REANALYSIS && cp -r $2/REANALYSIS/RE_$year $dir/REANALYSIS
metadata=$(ls $dir|grep -E ^L[A-Z]?[4-7][0-9]{3}[0-9]{3}.*_MTL.txt)
metadataxml=$(echo $metadata|sed -nE 's/(L.*).txt/\1.xml/p')
ssh docker@172.17.0.1 docker run -w=/data --rm -e LEDAPS_AUX_DIR=/data -e metadata=$metadata -e metadataxml=$metadataxml -v $3/$newdir:/data  madmex/ledaps:latest /usr/local/espa-tools/bin/convert_lpgs_to_espa --mtl=$metadata --xml=$metadataxml
ssh docker@172.17.0.1 docker run -w=/data --rm -e LEDAPS_AUX_DIR=/data -e metadataxml=$metadataxml -v $3/$newdir:/data  madmex/ledaps:latest /usr/local/espa-tools/bin/do_ledaps.csh $metadataxml
ssh docker@172.17.0.1 docker run -w=/data --rm -e LEDAPS_AUX_DIR=/data -e newdir=$newdir -e metadataxml=$metadataxml -v $3/$newdir:/data  madmex/ledaps:latest /usr/local/espa-tools/bin/convert_espa_to_hdf --xml=$metadataxml --hdf=lndsr.$(echo $newdir).hdf --del_src_files
cd $dir && mv lndsr.$(echo $newdir)_MTL.txt lndsr.$(echo $newdir)_metadata.txt
cd $dir && mv lndcal.$(echo $newdir)_MTL.txt lndcal.$(echo $newdir)_metadata.txt
cp lndsr.$(echo $newdir).hdf lndcal.$(echo $newdir).hdf
cp lndsr.$(echo $newdir)_hdf.xml lndcal.$(echo $newdir)_hdf.xml
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

*fmask_and_ingestion_landsat8.sh*

```
#!/bin/bash
#Entrada: $1 path to .tar.bz files, $2 path to temporal directory
source /LUSTRE/MADMEX/gridengine/nodo.txt
filename=$(basename $1)
newdir=$(echo $filename | sed -n 's/\(L*.*\).tar.bz/\1/;p')
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

*preprocessing_and_ingestion_landsat8.sh*

```
#!/bin/bash
#one: $1 is the path in the host for the tar file
#two: $2 is the path in the host for ancillary data
#three,four: $3, $4 is the username and password for the http://e4ftl01.cr.usgs.gov server
#five, six: $5, $6 is the username and password for the ladssci.nascom.nasa.gov server
#seven : $7 is the path in the host for the temporal folder
source /LUSTRE/MADMEX/gridengine/nodo.txt
name=$(basename $1)
newdir=$(echo $name | sed -n 's/\(L*.*\).tar.bz/\1/;p')
dir=$MADMEX_TEMP/$newdir
mkdir -p $dir
cp $1 $dir
cd $dir

#Prepraring files for LEDAPS:
year=$(echo $name|sed -nE 's/L[A-Z]?[5-8][0-9]{3}[0-9]{3}([0-9]{4}).*.tar.bz/\1/p')
day_of_year=$(echo $name|sed -nE 's/L[A-Z]?[5-8][0-9]{3}[0-9]{3}[0-9]{4}([0-9]{1,3}).*.tar.bz/\1/p')
year_month_day=$(date -d "$year-01-01 +$day_of_year days -1 day" "+%Y.%m.%d")
if [ ! -e $2/LADS/$year/L8ANC$year$day_of_year.hdf_fused ];
then
  #download cmg products
  echo "download cmg products" >> $dir/log.txt
  root=http://e4ftl01.cr.usgs.gov
  mod09=MOLT/MOD09CMG.006
  myd09=MOLA/MYD09CMG.006
  #date_acquired=$(cat $metadata|grep 'DATE_ACQUIRED'|cut -d'=' -f2|sed -n -e "s/-/./g" -e "s/ //p")
  date_acquired=$year_month_day
  echo $date_acquired >> $dir/log.txt
  echo "$root/$mod09/$date_acquired" >> $dir/log.txt
  if [ $(wget -L --user=$3 --password=$4 -qO - $root/$mod09/$date_acquired/|grep "MOD.*.hdf\""|wc -l) -gt 1 ]; then echo "Too many files for MOD09CMG"; else
    wget -L --user=$3 --password=$4 -P $dir -A hdf,xml,jpg -nd -r -l1 --no-parent "$root/$mod09/$date_acquired/"
  fi
  if [ $(wget -L --user=$3 --password=$4 -qO - $root/$myd09/$date_acquired/|grep "MYD.*.hdf\""|wc -l) -gt 1 ]; then echo "Too many files for MYD09CMG"; else
    wget -L --user=$3 --password=$4 -P $dir -A hdf,xml,jpg -nd -r -l1 --no-parent "$root/$myd09/$date_acquired/"
  fi
  #download cma products
  echo "download cma products" >> $dir/log.txt
  root=ftp://$5:$6@ladssci.nascom.nasa.gov
  mod09cma=6/MOD09CMA
  myd09cma=6/MYD09CMA
  if [ $(wget -qO - $root/$mod09cma/$year/$day_of_year/|grep "MOD09CMA.*.hdf\""|wc -l) -gt 1 ]; then echo "Too many files for MOD09CMA"; else
    wget -A hdf -P $dir -nd -r -l1 --no-parent "$root/$mod09cma/$year/$day_of_year/"
  fi
  if [ $(wget -qO - $root/$mod09cma/$year/$day_of_year/|grep "MOD09CMA.*.hdf\""|wc -l) -gt 1 ]; then echo "Too many files for MYD09CMA"; else
    wget -A hdf -P $dir -nd -r -l1 --no-parent "$root/$myd09cma/$year/$day_of_year/"
  fi
  #combine aux data
  terra_cmg=$(ls .|grep MOD09CMG.*.hdf$)
  echo $terra_cmg >> $dir/log.txt
  terra_cma=$(ls .|grep MOD09CMA.*.hdf$)
  echo $terra_cma >> $dir/log.txt
  aqua_cma=$(ls .|grep MYD09CMA.*.hdf$)
  aqua_cmg=$(ls .|grep MYD09CMG.*.hdf$)
  echo $aqua_cma >> $dir/log.txt
  echo $aqua_cmg >> $dir/log.txt
  ssh 172.17.0.1 docker run --rm -v $7/$newdir:/data -w=/data -e terra_cmg=$terra_cmg -e terra_cma=$terra_cma -e aqua_cma=$aqua_cma -e aqua_cmg=$aqua_cmg madmex/ledaps-landsat8  /usr/local/espa-tools/bin/combine_l8_aux_data --terra_cmg=$terra_cmg --terra_cma=$terra_cma --aqua_cmg=$aqua_cmg --aqua_cma=$aqua_cma --output_dir=/data
  #copy the combine aux data for future processes
  anc=$(ls .|grep ANC)
  mkdir -p $2/LADS/$year
  cp $anc $2/LADS/$year
  #move the combine aux data
  mkdir -p LADS/$year
  mv $anc LADS/$year
  #else
else
  echo "found fused file, not downloading" >> $dir/log.txt
  mkdir -p LADS/$year
  anc=$(ls $2/LADS/$year|grep ".*$year$day_of_year")
  cp $2/LADS/$year/$anc LADS/$year/
fi

#surface reflectances:
echo "Beginning untar"
#untar file
tar xvf $name
echo "finish untar"
metadata=$(ls .|grep -E ^L[A-Z]?[5-8][0-9]{3}[0-9]{3}.*_MTL.txt)
metadataxml=$(echo $metadata|sed -nE 's/(L.*).txt/\1.xml/p')
echo $metadata >> $dir/log.txt
echo $metadataxml >> $dir/log.txt
echo "finish identification of metadata"
ssh 172.17.0.1 docker run --rm -v $7/$newdir:/data -w=/data -e metadata=$metadata -e metadataxml=$metadataxml madmex/ledaps-landsat8 /usr/local/espa-tools/bin/convert_lpgs_to_espa --mtl=$metadata --xml=$metadataxml
#check if the next line is important for the analysis
#line: $BIN/create_land_water_mask --xml=$metadataxml
cp -r $2/LDCMLUT .
cp $2/ratiomapndwiexp.hdf .
cp $2/CMGDEM.hdf .
echo "Surface reflectance process" >> $dir/log.txt
ssh 172.17.0.1 docker run --rm -v $7/$newdir:/data -w=/data -e LEDAPS_AUX_DIR=/data -e anc=$anc -e metadataxml=$metadataxml madmex/ledaps-landsat8 /usr/local/espa-tools/bin/lasrc --xml=$metadataxml --aux=$anc --verbose --write_toa
ssh 172.17.0.1 docker run --rm -v $7/$newdir:/data -w=/data -e newdir=$newdir -e metadataxml=$metadataxml madmex/ledaps-landsat8 /usr/local/espa-tools/bin/convert_espa_to_hdf --xml=$metadataxml --hdf=lndsr.$(echo $newdir).hdf --del_src_files
echo "finish surface reflectance" >> $dir/log.txt
mv lndsr.$(echo $newdir)_MTL.txt lndsr.$(echo $newdir)_metadata.txt
#mv lndcal.$(echo $newdir)_MTL.txt lndcal.$(echo $newdir)_metadata.txt
cp lndsr.$(echo $newdir).hdf lndcal.$(echo $newdir).hdf
cp lndsr.$(echo $newdir)_hdf.xml lndcal.$(echo $newdir)_hdf.xml


#FMASK:
ssh 172.17.0.1 docker run --rm -v $7/$newdir:/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img $(ls $MADMEX_TEMP/$newdir|grep L[C-O]8.*_B[1-7,9].TIF)

ssh 172.17.0.1 docker run --rm -v $7/$newdir:/data madmex/python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img $(ls $MADMEX_TEMP/$newdir|grep L[C-O]8.*_B1[0,1].TIF)

ssh 172.17.0.1 docker run --rm -v $7/$newdir:/data madmex/python-fmask fmask_usgsLandsatSaturationMask.py -i ref.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -o saturationmask.img

ssh 172.17.0.1 docker run --rm -v $7/$newdir:/data madmex/python-fmask fmask_usgsLandsatTOA.py -i ref.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -o toa.img

ssh 172.17.0.1 docker run --rm -v $7/$newdir:/data madmex/python-fmask fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -s saturationmask.img -o cloud.img

cd $MADMEX_TEMP/$newdir && gdal_translate -of ENVI cloud.img $(echo $newdir)_MTLFmask

#INGEST:

#Check if the processes generate at least the number of files expected in order to register the appropiate path in the DB,
#if not echo a message of error

mkdir raw_data

mv L*_B[1-9].TIF raw_data
mv L*_B1[0-1].TIF raw_data
mv L*_BQA.TIF raw_data
cp *_MTL.txt raw_data

raw_data_number=$(ls raw_data|wc -l)

if [ $raw_data_number -ge 12 ]; then /usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $MADMEX_TEMP/$newdir/raw_data; else echo "error in tar: raw data";fi

mkdir srfolder

mv lndsr.*hdf* srfolder/
cp *_MTL.txt srfolder
mv L*_sr_* srfolder/

ledaps_sr_number=$(ls srfolder|wc -l)

if [ $ledaps_sr_number -ge 10 ]; then /usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $MADMEX_TEMP/$newdir/srfolder; else echo "error in surfaces reflectances process";fi

mkdir toafolder

mv lndcal.*hdf* toafolder/
cp *_MTL.txt toafolder
mv L*_toa_* toafolder/

ledaps_toa_number=$(ls toafolder|wc -l)

if [ $ledaps_toa_number -eq 13 ]; then /usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $MADMEX_TEMP/$newdir/toafolder; else echo "error in toa process";fi

mkdir fmaskfolder

cp *_MTL.txt fmaskfolder

mv *_MTLFmask* fmaskfolder

fmask_number=$(ls fmaskfolder|wc -l)

if [ $ledaps_toa_number -ge 3 ]; then /usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $MADMEX_TEMP/$newdir/fmaskfolder; else echo "error in fmask process";fi


#/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $MADMEX_TEMP/$newdir

rm -r $MADMEX_TEMP/$newdir/

```


####Classification

*classification_landsat.sh*

```
#!/bin/bash
#Input: $1 start date, $2 end date, $3 maximum percentage of clouds allowed, $4 pathrow, $5 path to the training set $6 1 if you want to delete atypical data, 0 otherwise

source /LUSTRE/MADMEX/gridengine/nodo.txt
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py LandsatLccWorkflowV3FilesAfter2012 --start_date_string $1 --end_date_string $2 --max_cloud_percentage $3 --landsat_footprint $4 --training_url $5 --outlier $6
```

*classification_landsat8.sh*

```
#!/bin/bash
#Input: $1 start date, $2 end date, $3 maximum percentage of clouds allowed, $4 pathrow, $5 path to the training set, $6 1 if you want to delete atypical data, 0 otherwise

source /LUSTRE/MADMEX/gridengine/nodo.txt
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py LandsatLccWorkflowOli --start_date_string $1 --end_date_string $2 --max_cloud_percentage $3 --landsat_footprint $4 --training_url $5 --outlier $6

```


####Classification postprocessing

*classification_postprocessing_landsat.sh*

```
#!/bin/bash
#Input: $1 folder that contains the classification results, $2 ESRI file that contains the region's tiles, $3 name of the ESRI file column, $4 folder where will be the results that help the postprocessing, $5 file postprocessing result
source /LUSTRE/MADMEX/gridengine/nodo.txt
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py LandsatLccPostWorkflow --lccresultfolder $1 --footprintshape $2 --tileidcolumnname $3 --workingdir $4 --outfile $5
```


