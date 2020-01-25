#!/bin/bash

cd $(dirname $0)/../config
composer install --quiet

standard=$(dirname $0)/../config/cs-ruleset.xml

if [ -f $(dirname $0)/../../../$1/package/phpcs/rules.xml ]; then
  standard=$standard,$(dirname $0)/../../../$1/package/rules/phpcs.xml
fi

$(dirname $0)/../config/vendor/bin/phploc -vvv --exclude vendor --exclude node_modules --exclude tests --exclude docs --exclude media $(dirname $0)/../../../$1/$2
