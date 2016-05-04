###Documentación técnica para la ejecución de procesos:

*Shells*

*descarga_landsat.sh*

```
#$1 es el sensor, $2 es el path, $3 es el row, $4 es el año
gsutil ls gs://earthengine-public/landsat/$1/$2/$3/|grep $4 > lista_landsat_tile_$2$3.txt
mkdir landsat_tile_$2$3
for file in $(cat lista_landsat_tile_$2$3.txt);do
qsub -S /bin/bash -cwd -q cluster_full_cpu /LUSTRE/MADMEX/code/madmex/resources/gridengine/scripts/gsutil_qsub.sh $file landsat_tile_$2$3/
done;
```

*gsutil_qsub.sh*

```
# $1 es la url del archivo de gsutil, $2 es el folder objetivo
mkdir -p $2

/usr/local/bin/gsutil cp -n $1 $2

```

*preprocessingfromarchive_landsat.sh*

```
#!/bin/bash
# $1 es el archivo para preprocesar e ingestar
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

/usr/bin/python $MADMEX/interfaces/cli/executer.py LedapsCommand --path $MADMEX_TEMP/$newdir/
/usr/bin/python $MADMEX/interfaces/cli/executer.py FmaskCommand --path $MADMEX_TEMP/$newdir
/usr/bin/python $MADMEX/interfaces/cli/executer.py IngestionShellCommand --path $MADMEX_TEMP/$newdir

rm $new_filename
rm -R $MADMEX_TEMP/$newdir/
```


