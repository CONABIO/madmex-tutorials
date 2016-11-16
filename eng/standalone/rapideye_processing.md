#Rapideye

For the following processes, is mandatory to clone CONABIO/madmex-v2 repository in your filesystem for having the MAD-MEX code.


##Ingestion

An image of rapideye comes in a folder with several other archives, for example the metadata in xml format. We need the following requirements for registering this folder in the database:

-Requirements:

* Image for MAD-MEX processes: madmex/ws
* Shell: data_ingestion_folder.sh with execution permissions. Go to rapideye_commands.md in this repository.
* Configuration archive: "configuration.ini". Go to configurations.md of this repository.
* Create "resources/config" directories in your filesystem. Copy configuration.ini to this path
* Create directory "eodata" in your filesystem, here the process of ingest will copy the folder to be ingested.
* Archive containing the environment variables that will be used by the ingest process: "variables.txt". This archive needs to be in the same directory where the shell is:

```
export MADMEX=/LUSTRE/MADMEX/code/
export MRV_CONFIG=$MADMEX/resources/config/configuration.ini
export PYTHONPATH=$PYTHONPATH:$MADMEX
export MADMEX_DEBUG=True
export MADMEX_TEMP=/services/localtemp/temp

```

##Classification

##Change detection