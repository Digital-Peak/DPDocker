#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

db=${db:-mysql}
pg=${pg:-latest}
my=${my:-latest}
php=${php:-latest}
e=${e:-}
t=${t:-}
j=${j:-5}
b=${b:-chrome}

while [ $# -gt 0 ]; do
	 if [[ $1 == "-"* ]]; then
		param="${1/-/}"
		declare $param="$2"
	 fi
	shift
done

if [ -z $e ]; then
	echo "No extension found!"
	exit
fi

if [ ! -d $(dirname $0)/www ]; then
	mkdir $(dirname $0)/www
	ssh-keygen -q -t rsa -N '' -f $(dirname $0)/www/key
fi

# Stop the containers
if [ -z $t ]; then
	docker-compose -f $(dirname $0)/docker-compose.yml stop
fi

# Start web server already so it gets the updated variables
EXTENSION=$e TEST=$t JOOMLA=$j DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose -f $(dirname $0)/docker-compose.yml up -d web-test

# Run VNC viewer
if [[ $(command -v vinagre) ]]; then
	# Waiting for selenium server
	while ! curl http://localhost:4444 > /dev/null 2>&1; do
		echo "$(date) - waiting for selenium server"
		sleep 4
	done
	vinagre localhost > /dev/null 2>&1 &
fi

# Run the tests
EXTENSION=$e TEST=$t JOOMLA=$j DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose -f $(dirname $0)/docker-compose.yml run system-tests

# Stop the containers
if [ -z $t ]; then
	docker-compose -f $(dirname $0)/docker-compose.yml stop
fi
