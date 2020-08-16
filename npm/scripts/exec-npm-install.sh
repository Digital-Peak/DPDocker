#!/bin/bash

root=$3
if [ -z $root ]; then
  root=$(realpath $(dirname $0)/../../../)
fi

# Link host directory as npm dir for caching
rm -rf /home/docker/.npm

if [ ! -d /usr/src/Projects/DPDocker/npm/tmp ]; then
  mkdir /usr/src/Projects/DPDocker/npm/tmp
fi

ln -s /usr/src/Projects/DPDocker/composer/tmp /home/docker/.npm

echo "Started to install and build the assets for $root/$1!"

# Loop over manifest files
for fname in $(find $root/$1/$2 -path ./node_modules -prune -o -name "package.json" 2>/dev/null); do
  # Exclude the files in node_modules directories
  if [[ $fname == *"node_modules"* ]]; then
    continue
  fi

  projectDirectory=$(dirname $fname)

  cd $projectDirectory

  echo "Installing $(dirname ${fname#"$root/"})!"

  # Remove the vendors directory
  if [ -d "$projectDirectory/node_modules" ]; then
    sudo rm -rf "$projectDirectory/node_modules"
  fi

  # Install the dependencies
  npm install

  if [ -z $3 ]; then
    echo "Outdated packages"
    npm outdated
  fi

  $(dirname $0)/exec-build.sh $root/$1 all

  echo "Finished installing $(dirname ${fname#"$root/"})!"
done
