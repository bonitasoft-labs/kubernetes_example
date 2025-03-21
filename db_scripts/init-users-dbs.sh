#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER bonitauser WITH PASSWORD 'myDbSecret';
	CREATE DATABASE bonita OWNER "bonitauser";
	CREATE USER bizuser WITH PASSWORD 'myBdmSecret';
	CREATE DATABASE bizdata OWNER "bizuser";
EOSQL