#!/bin/bash

if [ -z $1 ]; then
  echo "Did you forget to add the name of the extension as a parameter to the command? Only the version number is optional."
  exit 1
fi

EXTENSION=$1 VERSION=$2 docker-compose -f $(dirname $0)/docker-compose.yml run --rm build
