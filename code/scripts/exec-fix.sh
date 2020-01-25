#!/bin/bash

cd $(dirname $0)/../config
composer install --quiet

csStandard=$(dirname $0)/../config/cs-ruleset.xml
if [ -f $(dirname $0)/../../../$1/package/rules/phpcs.xml ]; then
  csStandard=$csStandard,$(dirname $0)/../../../$1/package/rules/phpcs.xml
fi

$(dirname $0)/../config/vendor/bin/phpcbf --colors --standard=$csStandard $(dirname $0)/../../../$1/$2
