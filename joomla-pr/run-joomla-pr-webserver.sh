#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

pr=$1
db=${db:-mysql}
pg=${pg:-latest}
my=${my:-8.3}
php=${php:-latest}
r=${r:-}

while [ $# -gt 1 ]; do
	if [[ $1 == "-"* ]]; then
		param="${1/-/}"
		declare $param="$2"
	fi
	shift
done

# Create the www directory as the current user so all subdirs will inherit the permissions
if [ ! -d $(dirname $0)/www ]; then
	mkdir $(dirname $0)/www
fi

# Start the dev server
PR=$pr DB=$db REBUILD=$r MYSQL_DBVERSION=$my POSTGRES_DBVERSION=$pg PHP_VERSION=$php docker compose -f $(dirname $0)/docker-compose.yml up joomla-pr
