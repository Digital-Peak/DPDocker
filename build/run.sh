#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

if [ -z $1 ]; then
	echo "Did you forget to add the name of the extension as a parameter to the command? Only the version number is optional."
	exit 1
fi

EXTENSION=$1 VERSION=$2 docker-compose -f $(dirname $0)/docker-compose.yml run --rm build
