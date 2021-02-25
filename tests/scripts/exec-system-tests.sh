#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

echo "Running Tests on Joomla $2 with $3"

# Setup download dir with correct permissions
sudo rm -rf /tmp/tests/*
sudo chmod 777 /tmp/tests

# Make sure the dependencies are correct
cd $(dirname $0)/../config/j3
composer install --quiet
cd $(dirname $0)/../config/j4
composer install --quiet

# Change to the tests folder as working directory
rm -rf $(dirname $0)/../tmp
mkdir $(dirname $0)/../tmp
cd $(dirname $0)/../tmp
cp -r $(dirname $0)/../../../$1/tests/* .
cp -r $(dirname $0)/../config/j$2/* .
sed -i "s/{BROWSER}/$3/" acceptance.suite.yml

# Build the actions class and copy it back
vendor/bin/codecept build
mkdir -p $(dirname $0)/../../../$1/tests/_support/_generated
cp -f $(dirname $0)/../tmp/_support/_generated/AcceptanceTesterActions.php $(dirname $0)/../../../$1/tests/_support/_generated/AcceptanceTesterActions.php

# Check if there are multiple tests to run
if [[ ! -z $4 && $4 != *".php:"* ]]; then
  vendor/bin/codecept run --env desktop ${4#"tests/"}
  exit 1
fi

# Check if there is a single test to run
if [ ! -z $4 ]; then
  vendor/bin/codecept run --debug --steps --env desktop ${4#"tests/"}
  exit 1
fi

if [ -d acceptance/install ]; then
  # Run the install task first
  vendor/bin/codecept run --env desktop acceptance/install

  # Remove the install tests, so they wont be executed again
  rm -rf acceptance/install
fi

# Run the tests
vendor/bin/codecept run --env desktop --ext "Codeception\ProgressReporter\ProgressReporter" acceptance
