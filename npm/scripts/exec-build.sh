#!/bin/bash

# Make sure the dependencies are correct
cd $(dirname $0)

if [ ! -d node_modules ]; then
  npm install
fi

# Execute build
node build.js $1 $2
