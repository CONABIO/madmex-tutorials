#Technical documentation for execution of processes:

##Shells

###Rapideye

*data_ingestion_folder.sh*
```
#!/bin/bash
#$1 is the path of the folder to be ingested
source /results/variables.txt
/usr/bin/python $MADMEX/interfaces/cli/madmex_processing.py Ingestion --input_directory $1

```

