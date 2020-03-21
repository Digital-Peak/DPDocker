#!/bin/bash

root=$3
if [ -z $root ]; then
  root=$(realpath $(dirname $0)/../../..)
fi

# Link host directory as composer dir for caching
rm -rf /home/docker/.composer

if [ ! -d /usr/src/Projects/DPDocker/composer/tmp ]; then
  mkdir /usr/src/Projects/DPDocker/composer/tmp
fi

ln -s /usr/src/Projects/DPDocker/composer/tmp /home/docker/.composer

echo "Started to show the PHP dependency tree on $root/$1!"

# Loop over composer files
for fname in $(find $root/$1/$2 -path ./vendor -prune -o -name "composer.json" 2>/dev/null); do
  # Exclude the files in vendor directories
  if [[ $fname == *"vendor"* ]]; then
    continue
  fi

  # Exclude tests and docs files when not explicit requested
  if [[ -z "$2" && ( $fname == *"docs"* || $fname == *"tests"* ) ]]; then
    continue
  fi

  projectDirectory=$(dirname $fname)

  cd $projectDirectory

  echo "Showing tree for $(dirname ${fname#"$root/"})!"

  composer show --tree
done
