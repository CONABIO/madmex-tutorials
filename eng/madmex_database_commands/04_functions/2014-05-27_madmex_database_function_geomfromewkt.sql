-- Function: geomfromewkt(text)

-- DROP FUNCTION geomfromewkt(text);

CREATE OR REPLACE FUNCTION geomfromewkt(text)
  RETURNS geometry AS
'$libdir/postgis-2.1', 'parse_WKT_lwgeom'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;