#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

# Setup download dir with correct permissions
sudo rm -rf /tmp/tests/*
sudo chmod 777 /tmp/tests

# Make sure the dependencies are correct
cd $(dirname $0)/../config
composer install --quiet

# Change to the tests folder as working directory
rm -rf $(dirname $0)/../tmp
mkdir $(dirname $0)/../tmp
cd $(dirname $0)/../tmp
cp -r $(dirname $0)/../../../$1/tests/* .
cp -r $(dirname $0)/../config/* .

# Build the actions class and copy it back
vendor/bin/codecept build
cp -f $(dirname $0)/../tmp/_support/_generated/AcceptanceTesterActions.php $(dirname $0)/../../../$1/tests/_support/_generated/AcceptanceTesterActions.php

# Build the command
if [ ! -z "$2" ]; then
  vendor/bin/codecept run --debug --steps --env desktop ${2#"tests/"}
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
