-- Function: classification.intersect_landsat_overlapping_classifications(text, integer, integer, integer, text, text, text)

-- DROP FUNCTION classification.intersect_landsat_overlapping_classifications(text, integer, integer, integer, text, text, text);

CREATE OR REPLACE FUNCTION classification.intersect_landsat_overlapping_classifications(overlaptable text, overlapid integer, fp1 integer, fp2 integer, classschemaname text, basename text, outschemaname text)
  RETURNS integer AS
$BODY$
declare
  union_cursor refcursor;
  table1 text;
  table2 text; 
  srid1 integer;
  srid2 integer;
  resulttable text;

  sql text;
  start_time timestamp;
  end_time timestamp;
  i integer;
  existcount int;
  elementscount int;
begin

  
    resulttable := outschemaname || '.' || 'classification_overlap_' || fp1 || '_' || fp2;
    
    
    -- check if exists
    sql := 'select count(*) from pg_tables where tablename = ' || '''classification_overlap_' || fp1 || '_' || fp2 || ''' and schemaname = ''' || outschemaname|| ''' ';
    execute sql into existcount;
    
    if existcount = 1 then
        raise notice 'Table % allready exists.', resulttable; 
    else
            raise notice 'Target table %.', resulttable; 

            RAISE NOTICE 'Overlap number: %', i;
            start_time := now();
            RAISE NOTICE '> start time: %', start_time;
            --fp_id = overlap_record.fp_id;
            sql := 'select tablename FROM pg_tables where tablename like ''' || basename ||'%'|| fp1 ||'%'' and schemaname = ''' || classschemaname || ''' ';
            execute sql into table1;
            table1 := classschemaname || '.' || table1;
            raise notice '>  Table1 %',table1;
            sql := 'select tablename FROM pg_tables where tablename like ''' || basename ||'%'|| fp2 ||'%'' and schemaname = ''' || classschemaname || ''' ';
            execute sql into table2;
            table2 := classschemaname || '.' || table2;
            raise notice '>  Table2 %',table2;  
            
            
            if table1 is not null and table2 is not null then
                    raise notice '>  Intersecting dataset1 %',table1;

                    sql = 'select distinct st_srid(the_geom) from ' || replace(quote_ident(table1),'"','');
                    execute sql into srid1;
                    sql = 'select distinct st_srid(the_geom) from ' || replace(quote_ident(table2),'"','');
                    execute sql into srid2;
                    
                    raise notice '>  SRID1 %', srid1; 
                    raise notice '>  SRID2 %', srid2;
                                        
                    raise notice '>  Getting tables overlap geometry';
                    sql := ' create temporary table theoverlap as ' ||
                                ' select st_intersection ' ||
                                '( ' ||
                                '        (select st_setsrid(st_extent(the_geom),(select distinct st_srid(the_geom) from ' || replace(quote_ident(table1),'"','') || ')) as the_geom from ' || replace(quote_ident(table1),'"','') || '), ' ||
                                '        (select st_transform(st_setsrid(st_extent(the_geom),(select distinct st_srid(the_geom) from ' || replace(quote_ident(table2),'"','') || ')),(select distinct st_srid(the_geom) from ' || replace(quote_ident(table1),'"','') || ')) as the_geom from ' || replace(quote_ident(table2),'"','') || ') ' ||
                                ') as the_geom   ' ; 

                    execute sql;                 
                    
                    raise notice '     > Extracting inner polygons from: %', table1;  
                    
                    raise notice '     > Intersecting with overlap: %', table1;                    
                    sql := 'create temporary table intersection_1 as ' ||
                                'select st_intersection(c.the_geom,st_transform(o.the_geom,' || srid1 || ' )) as the_geom, c.predicted, c.confidence ' ||
                                'from ' || replace(quote_ident(table1),'"','') || ' c, theoverlap o ' ||
                                'where st_transform(o.the_geom,' || srid1 || ' ) && c.the_geom'; 
                    raise notice '     > sql: %', sql;
                    execute sql; 
                    
                    sql := 'select count(*) from intersection_1';
                    execute sql into elementscount ;
                    raise notice '     > Number of elements: %', elementscount;                          
                
                
                
                    raise notice '     > Intersecting with overlap: %', table2; 
                    sql := 'create temporary table intersection_2 as ' ||
                                'select st_intersection(c.the_geom,st_transform(o.the_geom,' || srid2 || ' )) as the_geom, c.predicted, c.confidence ' ||
                                'from ' || replace(quote_ident(table2),'"','') || ' c, theoverlap o ' ||
                                'where st_transform(o.the_geom,' || srid2 || ' ) && c.the_geom'; 
                    raise notice '     > sql: %', sql;
                    execute sql; 

                    sql := 'select count(*) from intersection_2';
                    execute sql into elementscount ;
                    raise notice '     > Number of elements: %', elementscount;  
                    
                    sql := 'create index on intersection_1 using GIST (the_geom)';
                    execute sql;
                    sql := 'create index on intersection_2 using GIST (the_geom)';
                    execute sql;

                    sql := 'delete from intersection_1 where GeometryType(the_geom) != ''POLYGON''';
                    execute sql;  
                    sql := 'delete from intersection_2 where GeometryType(the_geom) != ''POLYGON''';
                    execute sql; 
                    
                    sql := 'update intersection_1 set the_geom = st_buffer(the_geom,0)';
                    execute sql;
                    sql := 'update intersection_2 set the_geom = st_buffer(the_geom,0)';
                    execute sql;                    
                    
                    
                    if srid1 = srid2 then
                        sql := 'create table ' || resulttable ||
                                ' as select clipped.predicted,clipped.confidence_1, clipped.predicted_2,clipped.confidence_2, the_geom from ' ||
                                ' (SELECT a.predicted as predicted, a.confidence as confidence_1,b.predicted as predicted_2, b.confidence as confidence_2, (ST_Dump(ST_Intersection(a.the_geom, b.the_geom))).geom As the_geom' ||
                                ' FROM intersection_1 a
                                        INNER JOIN intersection_2 b
                                        ON ST_Intersects(a.the_geom, b.the_geom))  As clipped                
                                ';
                        raise notice '     > sql: %', sql;
                        execute sql;
                    else
                        sql := 'create table ' || resulttable ||
                                ' as select clipped.predicted,clipped.confidence_1, clipped.predicted_2,clipped.confidence_2, the_geom from ' ||
                                ' (SELECT a.predicted as predicted, a.confidence as confidence_1, b.predicted as predicted_2, b.confidence as confidence_2,  ' ||
                                ' (ST_Dump(ST_Intersection(a.the_geom, st_transform(b.the_geom, ' || srid1 || ')))).geom As the_geom' ||
                                ' FROM intersection_1 a
                                        INNER JOIN intersection_2 b
                                        ON ST_Intersects(a.the_geom, st_transform(b.the_geom, ' || srid1 || ')))  As clipped                
                                ';
                        raise notice '     > sql: %', sql;    
                        execute sql;
                    
                    end if;
                    
                    
                    
                    
                    sql := 'drop table intersection_1'; 
                    execute sql;   
                    sql := 'drop table intersection_2';
                    execute sql; 
                    sql := 'drop table theoverlap';
                    execute sql; 
                                                                                
                    sql := 'select count(*) from ' ||resulttable;
                    execute sql into elementscount ;
                    raise notice '     > Number of elements before clean: %', elementscount;
     
                    sql := 'delete from ' ||resulttable||' where GeometryType(the_geom) != ''POLYGON''';
                    execute sql;  
                    
                    sql := 'select count(*) from ' ||resulttable;
                    execute sql into elementscount ;
                    raise notice '     > Number of elements after clean: %', elementscount;
                    
                    sql := 'alter table ' ||resulttable||' add column id serial';
                    execute sql;
                                                    
                end if;
        end if; -- exists
        
        sql := 'update ' || resulttable || ' set predicted = predicted_2 where confidence_2 > confidence_1';
        raise notice '     > sql: %', sql;    
        execute sql;
   
     
    


  
  return 0;    

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION classification.intersect_landsat_overlapping_classifications(text, integer, integer, integer, text, text, text)
  OWNER TO madmex_user;
