#!/bin/bash

# Create the www directory as the current user so all subdirs will inherit the permissions
if [ ! -d $(dirname $0)/www ]; then
  mkdir $(dirname $0)/www
fi

# Start the dev server
PR=$1 DB=$2 REBUILD=$3 docker-compose -f $(dirname $0)/docker-compose.yml up joomla-pr
