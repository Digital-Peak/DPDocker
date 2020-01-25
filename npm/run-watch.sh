#!/bin/bash

EXTENSION=$1 INCLUDE_VENDOR= docker-compose -f $(dirname $0)/docker-compose.yml run --rm watch
