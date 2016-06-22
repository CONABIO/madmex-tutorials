Archivo de configuración: "configuration.ini":


```
[aux-data]
dem = /LUSTRE/MADMEX/products/dem/inegi-cem_v3/CEM3.0_R15m_dem.tif
aspect = /LUSTRE/MADMEX/products/dem/inegi-cem_v3/CEM3.0_R15m_aspect.tif
slope = /LUSTRE/MADMEX/products/dem/inegi-cem_v3/CEM3.0_R15m_slope.tif
training_raster_landsat = /LUSTRE/MADMEX/products/training/inegi-usv250k_persistentes_mrv-conabio_125m.tif
training_raster_rapideye = /LUSTRE/MADMEX/products/training/malla_morelos_utm14_05km_training_level2.tif
dem_aspect_url = /LUSTRE/MADMEX/products/dem/inegi-cem_v3/CEM3.0_R15m_aspect.tif
dem_slope_url = /LUSTRE/MADMEX/products/dem/inegi-cem_v3/CEM3.0_R15m_slope.tif


[folders]
tmpfolder = /services/localtemp/temp/
eodatafolder = /LUSTRE/MADMEX/eodata/
productfolder = /LUSTRE/MADMEX/products/
resultfolder = /LUSTRE/MADMEX/processes/madmex_processing_results/
eodatastagingfolder = /LUSTRE/MADMEX/staging/eodata/
trainingstagingfolder = /LUSTRE/MADMEX/staging/training/
trainingfolder = /LUSTRE/MADMEX/products/training/

[database]
name = database-madmex
debug=False


[database-madmex]
schema_landmask = vectordata
table_landmask = country_mexico
landsat_footprint_table = vectordata.landsat_footprints_mexico
hostname =172.16.9.147
port = 32851
dbname = madmex_database
username = madmex_user
password = madmex_user.
tablename = events
eoschema = eodata
datasettable = dataset
productschema = products
producttable = product

[database-classification]
schema_landmask = vectordata
table_landmask = mexcontinental_buffer
landsat_footprint_table = vectordata.landsat_footprints_mexico
landsat_overlap_table = vectordata.landsat_etm_mx_footprints_overlaps
hostname =172.16.9.147
port = 32851
dbname = madmex_classification
username = postgres
password = postgres.
tablename = events

[columns]
landsat_overlap_table_fp1 = fp_id
landsat_overlap_table_fp2 = fp_id_1
landsat_overlap_table_gid= gid
the_geom = the_geom
gid = gid
id = id
given = given
predicted = predicted
confidence = confidence
reference = reference
classcode = predicted
features = features
ia_id = ia_id
fp_id = fp_id
ac_date = ac_date
image_url = image_url
metadata_url = metadata_url
s_id = s_id
cloud_cover = cloud_cover
l_id = l_id

[sql-statements]
select_image_acquisitions = select id, gridid, acq_date, folder_url, sensor, clouds, product from eodata.find_datasets
remove_outsider = select * from classification.remove_outside_polygons

[development]
project_name = madmex
placeholder = #PREFIX#

[raster-processing]
gdal_cache = 512000000
number_of_threads = 3
nodata = -999

[executables]
cmd_c5 = /usr/local/bin/c5.0
cmd_c5_predict = /usr/local/bin/predict
cmd_ledaps = /services/processes/apps/LEDAPS_preprocessing_tool/ledapsSrc_20111121/bin/do_ledaps.csh
cmd_ledaps_ancpath =  /services/localtemp/ledaps_anc/
cmd_fmask = /services/processes/apps/MATLAB/FMASK/src/run_FMASK.sh
matlab_runtime = /services/processes/apps/MATLAB/MATLAB_Compiler_Runtime/
gdal_merge = /usr/local/bin/gdal_merge.py

[fileextensions]
c5result = .result

[logging]
func_log_string = %(levelname)s - %(asctime)s - %(name)s - %(message)s
func_log_level = INFO

adapter_log_string = %(asctime)s: %(message)s
adapter_log_level = INFO

command_log_level = INFO
web_log_level = INFO

use_logstash = True
logstash_host = madmexservices.conabio.gob.mx
logstash_port = 5959
logstash_log_level = INFO
```

Archivo nodo.txt:

```
export MADMEX=/LUSTRE/MADMEX/code/madmex
export MRV_CONFIG=/LUSTRE/MADMEX/resources/config/configuration.ini
export PYTHONPATH=$PYTHONPATH:$MADMEX
export MADMEX_DEBUG=True
export MADMEX_TEMP=/services/localtemp/temp
```

Archivo supervisord.conf:

```
[supervisord]
nodaemon=true


[program:sshd]
command=/usr/sbin/sshd -D
stderr_logfile = /LUSTRE/MADMEX/docker/logging/madmex_ws_ssh_stderr.log
stdout_logfile = /LUSTRE/MADMEX/docker/logging/madmex_ws_ssh_stdout.log

[program:gridengine]
#user=sgeadmin
command=/bin/bash -c "service gridengine-exec restart"
stderr_logfile = /LUSTRE/MADMEX/docker/logging/madmex_ws_sge_stderr.log
stdout_logfile = /LUSTRE/MADMEX/docker/logging/madmex_ws_sge_stdout.log


#[program:madmex_webservice]
#user=madmex_admin
command=/bin/bash -c "source /LUSTRE/MADMEX/gridengine/nodo.txt && exec python /LUSTRE/MADMEX/code/madmex/interfaces/cli/start_madmex_ws.py 0.0.0.0 8800"
stderr_logfile = /LUSTRE/MADMEX/docker/logging/madmex_ws_stderr.log
stdout_logfile = /LUSTRE/MADMEX/docker/logging/madmex_ws_stdout.log

```
