CREATE TYPE image_pair AS (
 ia_id_1     integer,                  
 fp_id_1     integer,                  
 ac_date_1   timestamp with time zone, 
 image_url_1 character varying ,       
 ia_id_2     integer,                  
 fp_id_2     integer ,                 
 ac_date_2   timestamp with time zone, 
 image_url_2 character varying,        
 daydiff     double precision         
);

-- Function: eodata.find_dataset_pairs(text, text, integer, integer, integer, integer)

-- DROP FUNCTION eodata.find_dataset_pairs(text, text, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION eodata.find_dataset_pairs(year1 text, year2 text, cloud integer, sensorid integer, productid integer, maxdaydiff integer)
  RETURNS SETOF image_pair AS
$BODY$
declare
	result record; 
        d1 date;
        d2 date;
        d12 date;
        d22 date;
        
begin

d1 := TO_DATE( year1 || '0101' , 'YYYYMMDD');
d12 := TO_DATE( year1 || '1231' , 'YYYYMMDD');
d2 := TO_DATE( year2 || '0101' , 'YYYYMMDD');
d22 := TO_DATE( year2 || '1231' , 'YYYYMMDD');

raise notice '%',d1 ;
if (sensorid = 4 or sensorid = 5) then
        for result in 
                select 
                        
                        ia.id, ia.gridid, ia.acq_date, ia.folder_url, ib.id, ib.gridid, ib.acq_date,ib.folder_url,   
                        abs(EXTRACT(DOY from ia.acq_date)-EXTRACT(DOY from ib.acq_date))
                from    eodata.find_landsat_datasets(d1,d12,cloud,productid) ia, 
                        eodata.find_landsat_datasets(d2,d22,cloud,productid) ib
                where 
                        ia.id != ib.id and ia.product = productid and ia.gridid = ib.gridid and ia.product = ib.product and abs(EXTRACT(DOY from ia.acq_date)-EXTRACT(DOY from ib.acq_date)) < maxdaydiff
           
                loop
                return next result;
        end loop;
else
        for result in 
                select 
                        ia.id, ia.gridid, ia.acq_date, ia.folder_url, ib.id, ib.gridid, ib.acq_date,ib.folder_url,   
                        abs(EXTRACT(DOY from ia.acq_date)-EXTRACT(DOY from ib.acq_date))
                from    eodata.find_datasets(d1,d12,cloud,sensorid,productid) ia, 
                        eodata.find_datasets(d2,d22,cloud,sensorid,productid) ib
                where 
                        /*ia.id != ib.id and*/ ia.product = productid and ia.gridid = ib.gridid and ia.product = ib.product and abs(EXTRACT(DOY from ia.acq_date)-EXTRACT(DOY from ib.acq_date)) < maxdaydiff
           
                loop
                return next result;
        end loop;
end if;


return;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION eodata.find_dataset_pairs(text, text, integer, integer, integer, integer)
  OWNER TO madmex_user;
