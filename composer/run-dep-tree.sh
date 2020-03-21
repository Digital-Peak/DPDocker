#!/bin/bash

EXTENSION=$1 EXTENSION_FOLDER=$2 docker-compose -f $(dirname $0)/docker-compose.yml run --rm dep-tree
