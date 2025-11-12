#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

db=${db:-mysql}
pg=${pg:-latest}
my=${my:-8.3}
php=${php:-latest}
j=${j:-}
t=${t:-}
b=${b:-chrome}

while [ $# -gt 0 ]; do
	 if [[ $1 == "-"* ]]; then
		param="${1/-/}"
		declare $param="$2"
	 fi
	shift
done

if [ -z $j ]; then
	echo "No joomla folder set!"
	exit
fi

export EXTENSION=$e
export TEST=$t
export JOOMLA=$j
export DB=$db
export MYSQL_DBVERSION=$my
export POSTGRES_DBVERSION=$pg
export PHP_VERSION=$php
export BROWSER=$b
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

# Stop the containers
docker compose -f $(dirname $0)/docker-compose.yml stop

xhost +local:docker

# Run the tests
docker compose -f $(dirname $0)/docker-compose.yml up joomla-system-tests

# Stop the containers
docker compose -f $(dirname $0)/docker-compose.yml stop
