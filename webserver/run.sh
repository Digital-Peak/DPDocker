#!/bin/bash

# Create the www directory as the current user so all subdirs will inherit the permissions
if [ ! -d $(dirname $0)/www ]; then
  mkdir $(dirname $0)/www
fi

# TODO
# Delete folder mysql_data if mysql verion changed from 5.x to 8
# Fallback for DBVERSION that is no mysql tag in image https://hub.docker.com/_/mysql
# Add changes to readme

# Start the dev server
DB=$1 REBUILD=$2 DBVERSION=$3 docker-compose -f $(dirname $0)/docker-compose.yml up
