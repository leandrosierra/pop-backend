#!/bin/sh
set -e

# Apply the PostgreSQL schema + seed (owned by SQL/, idempotent) before starting Tomcat.
# Parse host/port/db from POP_DB_URL = jdbc:postgresql://HOST:PORT/DB[?...]
URL="${POP_DB_URL#jdbc:postgresql://}"
HOSTPORT="${URL%%/*}"
DBREST="${URL#*/}"
DBNAME="${DBREST%%\?*}"
DBHOST="${HOSTPORT%%:*}"
DBPORT="${HOSTPORT#*:}"
[ "$DBPORT" = "$DBHOST" ] && DBPORT=5432

export PGPASSWORD="$POP_DB_PASSWORD"
PSQL="psql -h $DBHOST -p $DBPORT -U $POP_DB_USERNAME -d $DBNAME -v ON_ERROR_STOP=0"

echo "[entrypoint] waiting for postgres $DBHOST:$DBPORT/$DBNAME ..."
i=0
until pg_isready -h "$DBHOST" -p "$DBPORT" -U "$POP_DB_USERNAME" >/dev/null 2>&1; do
  i=$((i+1))
  [ "$i" -ge 30 ] && { echo "[entrypoint] postgres not ready, continuing anyway"; break; }
  sleep 2
done

echo "[entrypoint] applying schema (DB_CREATION.sql)..."
$PSQL -f /docker-init/DB_CREATION.sql 2>&1 | tail -5 || echo "[entrypoint] schema apply warnings (non-fatal)"

echo "[entrypoint] applying seed data (Init_script_pg.sql)..."
$PSQL -f /docker-init/Init_script_pg.sql 2>&1 | tail -5 || echo "[entrypoint] seed apply warnings (non-fatal)"

echo "[entrypoint] starting Tomcat..."
exec catalina.sh run
