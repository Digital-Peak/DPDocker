#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

while  ! curl http://web-test  > /dev/null 2>&1; do
	echo "$(date) - waiting for web server"
	sleep 4
done

echo "Running Tests on Joomla $2 and PHP $4 with $3"

# Setup download dir with correct permissions
sudo rm -rf /tmp/tests/*
sudo chmod 777 /tmp/tests

# Make sure the dependencies are correct
cd $(dirname $0)/../config/extension
composer install --quiet

# Change to the tests folder as working directory
rm -rf $(dirname $0)/../tmp
mkdir $(dirname $0)/../tmp
cd $(dirname $0)/../tmp
cp -r $(dirname $0)/../../../$1/tests .
cp -r $(dirname $0)/../config/extension/* .

sudo sed -i "s/debug = '1'/debug = 0/g" /var/www/html/joomla/configuration.php
sudo sed -i "s/sef = '1'/sef = 0/g" /var/www/html/joomla/configuration.php
sudo sed -i "s/smtphost = 'mailcatcher'/smtphost = 'mailcatcher-test'/g" /var/www/html/joomla/configuration.php

# Joomla 3 needs error reporting simple
if [ $2 == 3 ]; then
	sudo sed -i "s/error_reporting = 'development'/error_reporting = 'simple'/g" /var/www/html/joomla/configuration.php
fi

export CODECEPTION_BROWSER=$3
export CODECEPTION_JOOMLA_VERSION=$2
export CODECEPTION_PHP_VERSION=$4
export CODECEPTION_EXTENSION=$1

# Build the actions class and copy it back
vendor/bin/codecept clean
vendor/bin/codecept build

# Copy generated action tester file back to the extension
mkdir -p $(dirname $0)/../../../$1/tests/src/Support/_generated
cp -f $(dirname $0)/../tmp/tests/src/Support/_generated/AcceptanceTesterActions.php $(dirname $0)/../../../$1/tests/src/Support/_generated/AcceptanceTesterActions.php

if [[ -d tests/src/Acceptance/Install && -z "$5" ]]; then
	# Run the install task first
	vendor/bin/codecept run --env desktop tests/src/Acceptance/Install
fi

if [ -d tests/src/Acceptance/Install ]; then
	# Remove the install tests, so they wont be executed again
	rm -rf tests/src/Acceptance/Install
fi

# Check if there are multiple tests to run
if [[ ! -z $5 && $5 == *".php:"* ]]; then
	vendor/bin/codecept run --debug --steps --env desktop $5
	exit 0
fi

# Run the tests
vendor/bin/codecept run --env desktop $5
