#!/bin/bash

# Build the images
docker build $(dirname $0)/cli -t dpdocker-cli
docker build $(dirname $0)/web -t dpdocker-web
