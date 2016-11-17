CREATE FUNCTION asewkt(geometry) RETURNS text AS
$$
    SELECT st_asewkt($1);
$$
LANGUAGE SQL;
