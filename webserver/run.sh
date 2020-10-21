#!/bin/bash
DB=${DB:-mysql}
POSTGRES_DBVERSION=${POSTGRES_DBVERSION:-latest}
MYSQL_DBVERSION=${MYSQL_DBVERSION:-latest}
REBUILD=${REBUILD:-}

while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi
  shift
done

# Create the www directory as the current user. So all subdirs will inherit the permissions.
if [ ! -d $(dirname $0)/www ]; then
  mkdir $(dirname $0)/www
fi

# Start the dev server
DB=$DB REBUILD=$REBUILD MYSQL_DBVERSION=$MYSQL_DBVERSION POSTGRES_DBVERSION=$POSTGRES_DBVERSION docker-compose -f $(dirname $0)/docker-compose.yml up
