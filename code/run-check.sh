#!/bin/bash

EXTENSION=$1 FILE=$2 docker-compose -f $(dirname $0)/docker-compose.yml run --rm check
