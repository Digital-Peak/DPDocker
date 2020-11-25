#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

if [ ! -d /var/www/html/Projects/$1 ]; then
	exit
fi

# Setup root directory
root=/var/www/html/$1;
if [ ! -d $root ]; then
	ln -s /var/www/html/Projects/$1 $root
fi

dbHost=$2
if [ -z $dbHost ]; then
  dbHost='mysql'
fi

/var/www/html/Projects/DPDocker/webserver/scripts/install-joomla.sh $root $dbHost joomla_$1 "Joomla $1" mailcatcher $3
