#Technical documentation for execution of processes:

##Shells

###Rapideye

*data_ingestion.sh*

```
#!/bin/bash
#$1 is the path to the archive .tar.bz to be ingested
filename=$(basename $1)
newdir=$(echo $filename | sed -n 's/\(L*.*\).tar.bz/\1/;p')
folder=/results
new_filename=$folder/$filename
mkdir -p $folder/$newdir
cp $1 $folder/$newdir
cd $folder/$newdir
tar xvjf $filename
source /results/variables.txt
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $folder/$newdir

```

*data_ingestion_folder.sh*
```
#!/bin/bash
#$1 is the path of the folder to be ingested
source /results/variables.txt
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $1

```

