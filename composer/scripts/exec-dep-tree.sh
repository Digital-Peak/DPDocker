#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

root=$3
if [ -z $root ]; then
	root=$(realpath $(dirname $0)/../../..)
fi

# Link host directory as composer dir for caching
rm -rf /home/docker/.composer

if [ ! -d $(dirname $0)/../tmp ]; then
	mkdir $(dirname $0)/../tmp
fi

ln -s $(dirname $0)/../tmp /home/docker/.composer

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
