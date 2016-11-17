psql -h $1 -p $2 -f /results/01_database/2014-05-27_madmex_database_create_database.sql
psql  -h $1 -d madmex_database -p $2 -f /results/01_database/2014-05-27_madmex_database_install_postgis.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/02_tables/2014-05-27_madmex_database_create.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/02_tables/2013-07-24_madmex_products_scheme_create.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/03_inserts/2014-05-27_madmex_database_insert.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/04_functions/2014-05-27_madmex_database_function_geomfromewkt_2.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/04_functions/2014-05-27_madmex_database_function_asewkt_2.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/04_functions/2014-05-27_madmex_database_function_create_landsat_overlap_table.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/04_functions/2014-05-27_madmex_database_function_find_dataset_pairs.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/04_functions/2014-05-27_madmex_database_function_find_datasets.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/04_functions/2014-05-27_madmex_database_function_find_landsat_datasets.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/04_functions/2014-05-27_madmex_database_function_intersect_landsat_overlapping_classifications.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/04_functions/2014-05-27_madmex_database_function_remove_outside_polygons.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/05_vectors/vectordata.country_mexico.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/05_vectors/vectordata.landsat_footprints_mexico.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/05_vectors/vectordata.mexico_limites.sql
psql -h $1 -U madmex_user -d madmex_database -p $2 -f /results/05_vectors/eodata.image_footprint.sql