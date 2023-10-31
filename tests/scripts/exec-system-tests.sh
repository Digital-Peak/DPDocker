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

# Temporary code when for local development
cp -rf $(dirname $0)/../../../DPCeption/src/* vendor/digital-peak/dpception/src

sudo sed -i "s/debug = '1'/debug = 0/g" /var/www/html/joomla/configuration.php
sudo sed -i "s/sef = '1'/sef = 0/g" /var/www/html/joomla/configuration.php
sudo sed -i "s/smtphost = 'mailcatcher'/smtphost = 'mailcatcher-test'/g" /var/www/html/joomla/configuration.php

export CODECEPTION_BROWSER=$3
export CODECEPTION_JOOMLA_VERSION=$2
export CODECEPTION_PHP_VERSION=$4
export CODECEPTION_EXTENSION=$1

# Build the actions class and copy it back
vendor/bin/codecept clean
vendor/bin/codecept build

if [[ -d tests/src/Acceptance/Install && -z "$5" ]]; then
	# Run the install task first
	vendor/bin/codecept run --env desktop tests/src/Acceptance/Install
fi

if [ -d tests/src/Acceptance/Install ]; then
	# Remove the install tests, so they wont be executed again
	rm -rf tests/src/Acceptance/Install
fi

mkdir $(dirname $0)/../tmp/profile
mkdir $(dirname $0)/../tmp/profile/mem
mkdir $(dirname $0)/../tmp/profile/xdebug
export MEMPROF_PROFILE=1
export XDEBUG_CONFIG="output_dir=$(realpath $(dirname $0)/../tmp/profile/xdebug)"

args=

# Check if there are multiple tests to run
if [[ ! -z $5 && $5 == *".php:"* ]]; then
	args="--debug --steps"
fi
php -dextension=memprof.so vendor/codeception/codeception/app.php run $args --env desktop $5

cp /tmp/cachegrind* $(dirname $0)/../tmp/profile/mem
