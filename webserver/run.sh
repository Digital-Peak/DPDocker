#!/bin/bash

# Create the www directory as the current user so all subdirs will inherit the permissions
if [ ! -d $(dirname $0)/www ]; then
  mkdir $(dirname $0)/www
fi

# Start the dev server
export DOCKERHOST=$(ifconfig | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -v 127.0.0.1 | awk '{ print $2 }' | cut -f2 -d: | head -n1)
REBUILD=$1 docker-compose -f $(dirname $0)/docker-compose.yml up
