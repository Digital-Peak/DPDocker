#!/bin/bash

root=$3
if [ -z $root ]; then
  root=$(realpath $(dirname $0)/../../../)
fi

echo "Started to update and build the assets for $root/$1!"

# Loop over manifest files
for fname in $(find $root/$1/$2 -path ./node_modules -prune -o -name "package.json" 2>/dev/null); do
  # Exclude the files in node_modules directories
  if [[ $fname == *"node_modules"* ]]; then
    continue
  fi

  projectDirectory=$(dirname $fname)

  cd $projectDirectory

  echo "Updating $(dirname ${fname#"$root/"})!"

  # Remove the vendors directory
  if [ -d "$projectDirectory/node_modules" ]; then
    sudo rm -rf "$projectDirectory/node_modules"
  fi

  # Update the dependencies
  npm update

  if [ -z $3 ]; then
    echo "Outdated packages"
    npm outdated
  fi

  $(dirname $0)/exec-build.sh /usr/src/Projects/$1 all

  echo "Finished updating $(dirname ${fname#"$root/"})!"
done
