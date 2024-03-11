#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

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

# Stop the containers
docker-compose -f $(dirname $0)/docker-compose.yml stop

sudo xhost +

# Run the tests
EXTENSION= TEST=$t JOOMLA=$j REBUILD= DB=$db MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php BROWSER=$b USER_ID= GROUP_ID= docker-compose -f $(dirname $0)/docker-compose.yml up joomla-system-tests

# Stop the containers
docker-compose -f $(dirname $0)/docker-compose.yml stop
