#!/bin/bash

# Remove the installed modules
sudo rm -rf $(dirname $0)/../../$1/package/node_modules

# Install the dependencies and rebuild all assets
EXTENSION=$1 INCLUDE_VENDOR=$2 docker-compose -f $(dirname $0)/docker-compose.yml run --rm install
EXTENSION=$1 INCLUDE_VENDOR= docker-compose -f $(dirname $0)/docker-compose.yml run --rm outdated
EXTENSION=$1 INCLUDE_VENDOR=1 docker-compose -f $(dirname $0)/docker-compose.yml run --rm build
