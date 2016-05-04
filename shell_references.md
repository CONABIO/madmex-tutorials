###Documentación técnica para la ejecución de procesos:

*Shells*

*descarga_landsat.sh*

```
gsutil ls gs://earthengine-public/landsat/$1/$2/$3/|grep $4 > lista_landsat_tile_$2$3.txt
mkdir landsat_tile_$2$3
for file in $(cat lista_landsat_tile_$2$3.txt);do
qsub -S /bin/bash -cwd -q cluster_full_cpu /LUSTRE/MADMEX/code/madmex/resources/gridengine/scripts/gsutil_qsub.sh $file landsat_tile_$2$3/
done;
```

*gsutil_qsub.sh*

```
mkdir -p $2

/usr/local/bin/gsutil cp -n $1 $2

```

*preprocessingfromarchive_landsat.sh*

```
#!/bin/bash
source /LUSTRE/MADMEX/code/madmex/resources/gridengine/nodo_conabio.txt
replace=""

cp $1 $MADMEX_TEMP

filename=$(basename $1)

newdir=$(echo $filename | sed -e "s/.tar.bz/$replace/g")

new_filename=$MADMEX_TEMP/$filename

mkdir -p $MADMEX_TEMP/$newdir
cd $MADMEX_TEMP/$newdir

tar xvjf $new_filename

ssh 172.17.0.1 docker run --rm -v /tmp/madmex/$newdir:/data python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img $(ls $MADMEX_TEMP/$newdir|grep L[C-O]8.*_B[1-7,9].TIF)

ssh 172.17.0.1 docker run --rm -v /tmp/madmex/$newdir:/data python-fmask gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img $(ls $MADMEX_TEMP/$newdir|grep L[C-O]8.*_B1[0,1].TIF)

ssh 172.17.0.1 docker run --rm -v /tmp/madmex/$newdir:/data python-fmask fmask_usgsLandsatSaturationMask.py -i ref.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -o saturationmask.img

ssh 172.17.0.1 docker run --rm -v /tmp/madmex/$newdir:/data python-fmask fmask_usgsLandsatTOA.py -i ref.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -o toa.img

ssh 172.17.0.1 docker run --rm -v /tmp/madmex/$newdir:/data python-fmask fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m $(ls $MADMEX_TEMP/$newdir|grep .*_MTL.txt) -s saturationmask.img -o cloud.img

cd $MADMEX_TEMP/$newdir && gdal_translate -of ENVI cloud.img $(echo $newdir)_MTLFmask

mkdir -p $MADMEX_TEMP/$newdir/maskfolder

cd $MADMEX_TEMP/$newdir && cp *_MTL.txt maskfolder && mv *_MTLFmask* maskfolder

/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $MADMEX_TEMP/$newdir

/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $MADMEX_TEMP/$newdir/maskfolder

rm $new_filename
rm -R $MADMEX_TEMP/$newdir/
```


