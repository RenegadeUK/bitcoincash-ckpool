#!/bin/bash
set -e

DB_EXISTS=$(psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -tAc "SELECT 1 FROM pg_database WHERE datname='dbshadow'")

if [ "$DB_EXISTS" != "1" ]; then
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -c "CREATE DATABASE dbshadow OWNER \"$POSTGRES_USER\";"
fi

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" -c "GRANT ALL PRIVILEGES ON DATABASE dbshadow TO \"$POSTGRES_USER\";"
