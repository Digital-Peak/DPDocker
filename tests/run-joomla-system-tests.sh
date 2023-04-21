#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

if [[ ! $(command -v curl) ]]; then
	echo "Error: curl is not installed, can't run the tests!"
	exit 1
fi

db=${db:-mysql}
pg=${pg:-latest}
my=${my:-latest}
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

# Remove the containers
docker container rm -f $(docker container ls -q --filter name=tests_*) > /dev/null 2>&1

# Cleanup data dirs
sudo rm -rf $(dirname $0)/mysql_data
sudo rm -rf $(dirname $0)/postgres_data

sudo xhost +

# We start mysql early to rebuild the database
EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER= docker-compose -f $(dirname $0)/docker-compose.yml up -d mysql-test
EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER= docker-compose -f $(dirname $0)/docker-compose.yml up -d postgres-test
sleep 15

# Run containers in detached mode so when the system tests command ends, we can stop them afterwards
EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b docker-compose -f $(dirname $0)/docker-compose.yml up -d phpmyadmin-test
EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b docker-compose -f $(dirname $0)/docker-compose.yml up -d pgadmin-test
EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b docker-compose -f $(dirname $0)/docker-compose.yml up -d mailcatcher-test
EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b docker-compose -f $(dirname $0)/docker-compose.yml up -d joomla-web-test

# Waiting for web server
while ! curl http://localhost:8080 > /dev/null 2>&1; do
	echo "$(date) - waiting for web server"
	sleep 4
done

# Run the tests
EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b docker-compose -f $(dirname $0)/docker-compose.yml run --service-ports joomla-system-tests

# Stop the containers
docker container stop $(docker container ls -q --filter name=tests_*) > /dev/null 2>&1
