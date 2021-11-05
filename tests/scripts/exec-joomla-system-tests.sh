#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

echo "Running Tests on Joomla $1 with $2"

# Change to joomla root
cd $(dirname $0)/../../../$1

# Backup original configuration
if [[ ! -f configuration.php.bak && -f configuration.php ]]; then
  cp configuration.php configuration.php.bak
fi

# Setup configuration
cp -f $(dirname $0)/../config/cms/acceptance.suite.yml tests/Codeception
cp -f $(dirname $0)/../config/cms/api.suite.yml tests/Codeception
cp -f $(dirname $0)/../config/cms/configuration.php .

# Define the site propperly
sed -i "s/{SITE}/$1/g" tests/Codeception/acceptance.suite.yml
sed -i "s/{SITE}/$1/g" tests/Codeception/api.suite.yml
sed -i "s/{SITE}/$1/g" configuration.php

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

# Build the helpers
libraries/vendor/bin/codecept build

if [ -z $2 ]; then
  rm -f configuration.php
  mysql -u root -proot -h mysql-test -e "drop database if exists joomla_$1"
  mysql -u root -proot -h mysql-test -e "create database joomla_$1"

  # Run the tests
  libraries/vendor/bin/codecept run --env mysql tests/Codeception/acceptance

  sed -i "/\$secret/c\	public \$secret = 'tEstValue';" configuration.php
  libraries/vendor/bin/codecept run --env mysql tests/Codeception/api
else
  libraries/vendor/bin/codecept run --debug --steps --env mysql $2
fi

# Restore original configuration
if [ -f configuration.php.bak ]; then
  mv -f configuration.php.bak configuration.php
fi
