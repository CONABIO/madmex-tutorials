#Rapideye

For the following processes, it is mandatory to clone CONABIO/madmex-v2 repository in your filesystem for having the MAD-MEX code.''

##Ingestion

An image of rapideye comes in a folder with several other archives, for example the metadata in xml format. We need the following requirements for registering this folder in the database:

-Requirements:

* Image for MAD-MEX processes: madmex/ws
* Shell: data_ingestion_folder.sh with execution permissions. Go to rapideye_commands.md in this repository.
* Configuration archive: `configuration.ini`. Go to configurations.md of this repository.
* Create 'resources/config' directories in your filesystem. Copy configuration.ini to this path
* Create directory 'eodata' in your filesystem, here the process of ingest will copy the folder to be ingested.
* Archive containing the environment variables that will be used by the ingest process: 'variables.txt'. The contents of 'variables.txt' are:

```
export MADMEX=/LUSTRE/MADMEX/code/
export MRV_CONFIG=$MADMEX/resources/config/configuration.ini
export PYTHONPATH=$PYTHONPATH:$MADMEX
export MADMEX_DEBUG=True
export MADMEX_TEMP=/services/localtemp/temp

```

-Example for the folder: 1546624_2015-02-08_RE3_3A_302750, which has the archives:

* 1546624_2015-02-08_RE3_3A_302750.tif
* 1546624_2015-02-08_RE3_3A_302750_browse.tif
* 1546624_2015-02-08_RE3_3A_302750_license.txt
* 1546624_2015-02-08_RE3_3A_302750_metadata.xml
* 1546624_2015-02-08_RE3_3A_302750_readme.txt
* 1546624_2015-02-08_RE3_3A_302750_udm.tif

For this example:

* In the path: /madmex-v2 we have cloned the CONABIO/madmex-v2 repository
* Inside the directory: '/data/ingest/rapideye' we have the shell 'data_ingestion_folder.sh' which needs to have execution permissions. Go to rapideye_commands.md of this repository.
* In the path: /resources/config we have the configuration archive 'configuration.ini'
* In the path: '/data/rapideye/example' we have the folder to be ingested: 1546624_2015-02-08_RE3_3A_302750
* In the path: /export we have the archive 'variables.txt'
* We want that the data of the folder example be copied to: /data/eodata and be registered in the database

We execute the following command line:


```
$docker run --rm -v /madmex-v2:/LUSTRE/MADMEX/code \
-v /data/rapideye/ingest/data_ingestion_folder.sh:/results/data_ingestion_folder.sh \
-v /resources/config:/LUSTRE/MADMEX/code/resources/config \
-v /data/rapideye/example:/data/folder \
-v /export/variables.txt:/results/variables.txt \
-v /data/eodata:/LUSTRE/MADMEX/eodata madmex/ws \
/results/data_ingestion_folder.sh /data/folder/1546624_2015-02-08_RE3_3A_302750
```

After executing this line, we will have under /data/eodata the folder of the example copied and one register in the database.

##Preprocessing

-Requirements:



##Classification

The approach in the process of classification of rapideye images uses images that have similar regional and temporal characteristics. We use an ESRI shapefile 'mapgrid' to define several regions that consists of rapideye tiles sharing common regional properties. As each rapideye image in a different time has different reflectances for each phase of vegetation, we use a seasonality window defined by a date and a buffer of days. This buffer also depends on the amount of images that we have for the given date.


-Requirements:

* Image for MAD-MEX processes: madmex/ws
* Shell: rapideye_classification_by_mapgrid.sh with execution permissions. Go to rapideye_commands.md in this repository.
* An ESRI shapefile that defines the regions to be classified registered in the database under the schema vectoradata. We can use the following command to register our ESRI shapefile 'rapideye_mapgrid_region' in the database. If we have this ESRI shapefile under /data/esri_shapefiles/ then:


```
$docker run --rm -v /data/esri_shapefiles/:/results -it madmex/postgres-client \
shp2pgsql -I -s 4326 /results/rapideye_mapgrid_region.shp vectordata.rapideye_mapgrid_region|psql -d madmex_database -U madmex_user -h 192.168.99.100 -p 32851

```

In this command we have assumed that our server of the database has the ip 192.168.99.100 and is providing services in the 32851 port


* Images of each region of the ESRI shapefile registered in the database that fulfill the requisite of the defined buffer

* Register the algorithm and leyend in the database.

* Training data in the filesystem and also needs to be registered in the database.

* Auxiliary data: dem, aspect, slope registered in the configuration.ini file inside the tag aux-data. Go to configurations.md of this repository

* Temporal directory where the processing results are going to be copied.

* Directories: madmex_processing_results, reclassificationcomand, products for copying the classification results

* Archive containing the environment variables that will be used by the classification process: 'variables.txt':

```
export MADMEX=/LUSTRE/MADMEX/code/
export MRV_CONFIG=$MADMEX/resources/config/configuration.ini
export PYTHONPATH=$PYTHONPATH:$MADMEX
export MADMEX_DEBUG=True
export MADMEX_TEMP=/services/localtemp/temp

```

-Example:

For registering the legend in the database:

```
insert into "products"."legend"("id", "name", "description", "sld") values(0, 'dummy_legend', 'empty dummy legend', '<?xml version="1.0" ?>')

```

For registering the algorithm in the database:

```
insert into "products"."algorithm"("id", "name", "description", "command", "supervised") values (1,'REClassificationCommand', 'MAD-MEX Rapideye Landcover Classification Workflow', 'REClassificationCommand', 'true');

```


For registering the training data in the database:

```
insert into "products"."product" ("id", "uuid", "date_from", "date_to", "algorithm", "legend", "provider", "file_url", "proc_date", "ingest_date", "the_geom", "rows", "columns", "bands", "resolution", "projection") values (1, '43ed65a9-8719-4bdc-a375-a987c49de19c', '2016-01-01', '2016-12-31', 1, 0, 'CONABIO', '/LUSTRE/MADMEX/products/inegiusvpersii-v/training_areas_persistentes_32_clases_125m.tif', '2015-09-08 16:42:07', '2015-09-08 11:49:01', '0103000000010000000500000048B437AD505554C03F7E00ADC44A0BC075FE61FE9F9A53C09BF40773C0430BC0BCBE2357C99953C04850CF114DCF1AC0ECBC64616C5554C012F7D91A39D61AC048B437AD505554C03F7E00ADC44A0BC0', 1, 1, 1, 1.0, 'PROJCS["WGS 84 / UTM zone 17N",GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563,AUTHORITY["EPSG","7030"]],AUTHORITY["EPSG","6326"]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433],AUTHORITY["EPSG","4326"]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-81],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],UNIT["metre",1,AUTHORITY["EPSG","9001"]],AUTHORITY["EPSG","32617"]]')

```


* In the path: /madmex-v2 we have cloned the CONABIO/madmex-v2 repository
* In the path: /resources/config we have the configuration archive "configuration.ini"
* In the path: /data/eodata we have the original images copied and registered in the database with the ingest process
* In the path: /data/classification we have the shell rapideye_classification_by_mapgrid.sh with execution permissions.
* In the path: /products/inegiusvpersii-v we have the training data
* In the path: /products/dem/inegi we have the auxiliary data: dem, aspect, slope
* In the path: /temporal we have the directory that will have the processing results copied.
* In the paths: /madmex_processing_results, /reclassificationcommand will have the classification results
* In the path: /export we have the archive "variables.txt"

We want to classify the region marked as "5" of our ESRI shapefile rapideye_mapgrid_region for the date 2015-06-15 with a 17 buffer and an elimination of outliers (1), then we execute the following command:

```
$docker run --rm -v /products:/LUSTRE/MADMEX/products \
-v /data/rapideye/classification/rapideye_classification_by_mapgrid.sh:/results/rapideye_classification_by_mapgrid.sh
-v /products/dem/inegi:/LUSTRE/MADMEX/products/dem \
-v /products/inegiusvpersii-v:/LUSTRE/MADMEX/products/inegiusvpersii-v/ \
-v /data/eodata:/LUSTRE/MADMEX/eodata \
-v /madmex-v2:/LUSTRE/MADMEX/code \
-v /resources/config:/LUSTRE/MADMEX/code/resources/config \
-v /madmex_processing_results:/LUSTRE/MADMEX/processes/madmex_processing_results/ \
-v /reclassificationcommand:/LUSTRE/MADMEX/products/reclassificationcommand/ \
-v /temporal:/services/localtemp/temp \
 -v /export/variables.txt:/results/variables.txt \
 madmex/ws:latest /results/rapideye_classification_by_mapgrid.sh \
 2015-05-15 17 5 \
 /LUSTRE/MADMEX/products/inegiusvpersii-v/training_areas_persistentes_32_clases_125m.tif \
 1 /LUSTRE/MADMEX/processes/madmex_processing_results/ 
```





##Change detection