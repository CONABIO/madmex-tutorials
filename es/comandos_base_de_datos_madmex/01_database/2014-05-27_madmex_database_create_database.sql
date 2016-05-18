-- Database: madmex_database

-- DROP DATABASE madmex_database;

CREATE USER madmex_user WITH PASSWORD 'madmex_user.';

CREATE ROLE users NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

CREATE DATABASE madmex_database
  WITH OWNER = madmex_user
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       TEMPLATE = template0
       CONNECTION LIMIT = -1;
       
 
