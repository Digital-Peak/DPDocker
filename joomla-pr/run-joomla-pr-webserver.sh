#!/bin/bash

# Create the www directory as the current user so all subdirs will inherit the permissions
if [ ! -d $(dirname $0)/www ]; then
  mkdir $(dirname $0)/www
fi

# Start the dev server
TEST=$1 REBUILD=$2 EXTENSION= docker-compose -f $(dirname $0)/docker-compose.yml up joomla-pr
