#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

db=${db:-mysql}
pg=${pg:-latest}
my=${my:-latest}
php=${php:-latest}
r=${r:-}

while [ $# -gt 0 ]; do
	if [[ $1 == "-"* ]]; then
		param="${1/-/}"
		declare $param="$2"
	fi
	shift
done

# Create the www directory as the current user. So all subdirs will inherit the permissions.
if [ ! -d $(dirname $0)/www ]; then
	mkdir $(dirname $0)/www
	ssh-keygen -q -t rsa -N '' -f $(dirname $0)/www/key
fi

# Start the dev server
DB=$db REBUILD=$r MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php USER_ID=$(id -u) GROUP_ID=$(id -g) docker-compose -f $(dirname $0)/docker-compose.yml up
