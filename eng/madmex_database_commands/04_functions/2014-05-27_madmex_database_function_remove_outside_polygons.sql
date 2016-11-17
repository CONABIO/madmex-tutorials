-- Function: classification.remove_outside_polygons(text, text, text, text, text, text)

-- DROP FUNCTION classification.remove_outside_polygons(text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION classification.remove_outside_polygons(tablename text, footprintid text, geomcolumn text, footprinttable text, footprintcolumn text, footprintgeom text)
  RETURNS SETOF integer AS
$BODY$
declare

  srid1 integer;
  table1 text;
  sql text;
  objectcount integer;

begin

        table1 := tablename;
        sql = 'select distinct st_srid(' || replace(quote_ident(geomcolumn),'"','') ||') from ' || replace(quote_ident(table1),'"','');
        execute sql into srid1;  
        
        sql := 'delete from ' || replace(quote_ident(table1),'"','') ||
                ' where not st_within(' || replace(quote_ident(geomcolumn),'"','') ||', (select st_transform(' || replace(quote_ident(footprintgeom),'"','') ||',  ' || srid1 || ') from ' || replace(quote_ident(footprinttable),'"','') ||'' || 
                ' where ' || replace(quote_ident(footprintcolumn),'"','') ||'::int = ' || replace(quote_ident(footprintid),'"','') || ') )';
        
        raise notice '     > sql: %', sql;
        execute sql; 
        
	sql := 'select count(*) from  ' || replace(quote_ident(tablename),'"','');
	RAISE NOTICE 'Executing %', sql;
	
	for objectcount in execute sql loop
		return next objectcount;
	end loop; 
                
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION classification.remove_outside_polygons(text, text, text, text, text, text)
  OWNER TO madmex_user;
