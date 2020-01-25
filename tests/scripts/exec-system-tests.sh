#!/bin/bash

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

# Run the install task first
vendor/bin/codecept run --env desktop acceptance/install

# Execute the tests
for suite in acceptance/*/; do
  # Install is done already
  if [[ $suite == *"install"* ]]; then
    continue
  fi

  # Run the tests
  vendor/bin/codecept run --env desktop $suite
done
