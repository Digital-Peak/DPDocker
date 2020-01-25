#!/bin/bash

EXTENSION=$1 VERSION=$2 docker-compose -f $(dirname $0)/docker-compose.yml run --rm build
