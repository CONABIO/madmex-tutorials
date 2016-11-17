CREATE OR REPLACE FUNCTION asewkt(geometry)
  RETURNS text AS
'$libdir/postgis-2.2', 'LWGEOM_asEWKT'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION asewkt(geometry)
  OWNER TO postgres;
