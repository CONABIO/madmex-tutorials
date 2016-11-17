-- Function: classification.create_landsat_overlap_table(text, text)

-- DROP FUNCTION classification.create_landsat_overlap_table(text, text);

CREATE OR REPLACE FUNCTION classification.create_landsat_overlap_table(footprinttable text, ovresulttable text)
  RETURNS integer AS
$BODY$
declare
  sql text;

begin

        sql := '
                create table ' || replace(quote_ident(ovresulttable),'"','') ||' as         
                select fp1.gid as gid, fp1.fp_id as fp_id, fp2.fp_id as fp_id_1, fp1.code as code, fp2.code as code_1, st_intersection(fp1.the_geom, fp2.the_geom) as the_geom
                from ' || replace(quote_ident(footprinttable),'"','') ||' fp1, ' || replace(quote_ident(footprinttable),'"','') ||' fp2
                where fp1.fp_id != fp2.fp_id and st_intersects(fp1.the_geom, fp2.the_geom)
                ';
                
        execute sql; 
        
        sql := '
                DELETE FROM ' || replace(quote_ident(ovresulttable),'"','') ||' USING ' || replace(quote_ident(ovresulttable),'"','') ||' ov2
                WHERE ' || replace(quote_ident(ovresulttable),'"','') ||'.the_geom = ov2.the_geom AND ' || replace(quote_ident(ovresulttable),'"','') ||'.gid < ov2.gid;
        ';
        
        execute sql; 
        
        return 1;

                
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION classification.create_landsat_overlap_table(text, text)
  OWNER TO madmex_user;
