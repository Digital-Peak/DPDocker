#!/bin/bash

EXTENSION=$1 INCLUDE_VENDOR=$2 docker-compose -f $(dirname $0)/docker-compose.yml run --rm install
