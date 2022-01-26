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
my=${my:-5.6}
php=${php:-latest}
j=${j:-}
t=${t:-}
d=${d:--debug}
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

# Clear mysql data when running all tests
if [ -z $t ]; then
	# Remove the containers
	docker container rm -f $(docker container ls -q --filter name=tests_*) > /dev/null 2>&1

	# Cleanup data dirs
	sudo rm -rf $(dirname $0)/mysql_data
	sudo rm -rf $(dirname $0)/postgres_data

	# We start mysql early to rebuild the database
	EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER= DEBUG=$d docker-compose -f $(dirname $0)/docker-compose.yml up -d mysql-test
	EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER= DEBUG=$d docker-compose -f $(dirname $0)/docker-compose.yml up -d postgres-test
	sleep 5
fi

# Run containers in detached mode so when the system tests command ends, we can stop them afterwards
EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b DEBUG=$d docker-compose -f $(dirname $0)/docker-compose.yml up -d phpmyadmin-test
EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b DEBUG=$d docker-compose -f $(dirname $0)/docker-compose.yml up -d mailcatcher-test
EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b DEBUG=$d docker-compose -f $(dirname $0)/docker-compose.yml up -d joomla-web-test
EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b DEBUG=$d docker-compose -f $(dirname $0)/docker-compose.yml up -d selenium-test

# Waiting for web server
while ! curl http://localhost:8080 > /dev/null 2>&1; do
	echo "$(date) - waiting for web server"
	sleep 4
done

# Waiting for selenium server
while ! curl http://localhost:4444 > /dev/null 2>&1; do
	echo "$(date) - waiting for selenium server"
	sleep 4
done

# Run VNC viewer
if [[ $(command -v vinagre) ]]; then
	vinagre localhost > /dev/null 2>&1 &
fi

# Run the tests
EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b DEBUG=$d docker-compose -f $(dirname $0)/docker-compose.yml run joomla-system-tests

# Stop the containers
if [ -z $t ]; then
	docker container stop $(docker container ls -q --filter name=tests_*) > /dev/null 2>&1
fi
