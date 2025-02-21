#!/bin/sh

set -e
# Wait for the PostgreSQL server to be available
./wait-for.sh postgres:5432 -- echo "PostgreSQL is up - executing command"

# echo "run db migrations"
# /app/migrate -path /app/migration -database "$DB_SOURCE" -verbose up

echo "start simplebank api"
exec "$@"
