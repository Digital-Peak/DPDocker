#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

while  ! wget -q --spider http://joomla-web-test; do
	echo "$(date) - waiting for web server"
	sleep 4
done

echo "Running Tests on Joomla $1 with DB $2"

# Change to joomla root
cd $(dirname $0)/../../../$1

# Backup original configuration
if [[ ! -f configuration.php.bak && -f configuration.php ]]; then
	cp configuration.php configuration.php.bak
fi

# Setup configuration
cp -f $(dirname $0)/../config/cms/cypress.config.js .

# Define the site propperly
sed -i "s/{SITE}/$1/g" cypress.config.js

sed -i "s/{DB}/$2-test/g" cypress.config.js

if [[ $2 == 'mysql'* ]]; then
	sed -i "s/{DBTYPE}/MySQLi/g" cypress.config.js
else
	sed -i "s/{DBTYPE}/PostgreSQL\ \(PDO\)/g" cypress.config.js
fi

if [ ! -d libraries/vendor ]; then
	echo "Installing PHP dependencies"
	rm -rf libraries/vendor
	composer install --quiet
fi

if [ ! -d media/vendor ]; then
	echo "Installing the assets (takes a while!)"
	mkdir -p media/vendor
	npm ci &>/dev/null
fi

cypress open --project /e2e --e2e

# Restore original configuration
if [ -f configuration.php.bak ]; then
	mv -f configuration.php.bak configuration.php
fi
