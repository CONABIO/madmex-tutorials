CREATE FUNCTION geomwkt(geometry) RETURNS geometry AS
$$
    SELECT st_geomfromewkt($1);
$$
LANGUAGE SQL;

