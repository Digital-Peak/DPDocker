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

echo "Started to install the PHP dependencies on $root/$1!"

# Loop over composer files
for fname in $(find $root/$1/$2 -path ./vendor -prune -o -name "composer.json"); do
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

  echo "Installing $(dirname ${fname#"$root/"})!"

  # Remove the vendors directory
  if [ -d "$projectDirectory/vendor" ]; then
    sudo rm -rf "$projectDirectory/vendor"
  fi

  # Install the dependencies
  composer install -o --no-dev --prefer-dist --quiet

  if [ -z $3 ]; then
    echo "Outdated packages"
    composer outdated
  fi

  # If we are not generating an extension cleanup the directory
  if [[ "$2" != "docs" && "$2" != "tests" ]]; then
    echo "Cleaning up files in vendor"
    php $(dirname $0)/cleanup-vendors.php $projectDirectory > /dev/null
  fi

  echo "Finished installing $(dirname ${fname#"$root/"})!"
done
