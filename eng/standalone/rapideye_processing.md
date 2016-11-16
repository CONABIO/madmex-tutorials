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
* Archive containing the environment variables that will be used by the ingest process: "variables.txt". This archive needs to be in the same directory where the shell is. The contents of "variables.txt" are:

```
export MADMEX=/LUSTRE/MADMEX/code/
export MRV_CONFIG=$MADMEX/resources/config/configuration.ini
export PYTHONPATH=$PYTHONPATH:$MADMEX
export MADMEX_DEBUG=True
export MADMEX_TEMP=/services/localtemp/temp

```

-Example for the folder: 2044024_2015-01-02_RE1_3A_301519, which has this archives:

* 2044024_2015-01-02_RE1_3A_301519.tif
* 2044024_2015-01-02_RE1_3A_301519.tif.aux.xml
* 2044024_2015-01-02_RE1_3A_301519.tif.ovr
* 2044024_2015-01-02_RE1_3A_301519_browse.tif
* 2044024_2015-01-02_RE1_3A_301519_license.txt
* 2044024_2015-01-02_RE1_3A_301519_metadata.xml
* 2044024_2015-01-02_RE1_3A_301519_readme.txt
* 2044024_2015-01-02_RE1_3A_301519_udm.tif
* Thumbs.db

For this example:

* Inside the directory: "/data/rapideye" we have the shell "data_ingestion_folder.sh" which needs to have execution permissions. Go to rapideye_commands.md of this repository.
* In the path: /madmex-v2 we have cloned the CONABIO/madmex-v2 repository
* In the path: /resources/config we have the configuration archive "configuration.ini"
* In the path: "/data/rapideye/example" we have the folder to be ingested: 2044024_2015-01-02_RE1_3A_301519
* In the path: /export we have the archive "variables.txt"
* We want that the data of the folder example be copied to: /datos/eodata and be registered in the database

We execute the following command line:


```
docker run --rm -v /madmex-v2:/LUSTRE/MADMEX/code \
-v /resources/config:/LUSTRE/MADMEX/code/resources/config \
-v /datos/eodata:/LUSTRE/MADMEX/eodata -v /export/variables.txt:/results/variables.txt -v /data/rapideye/example:/results madmex/ws \
/results/data_ingestion.sh /results/LC80210482015015LGN00.tar.bz
```












##Classification

##Change detection