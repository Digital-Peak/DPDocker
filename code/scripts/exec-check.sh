#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

cd $(dirname $0)/../config
composer install --quiet

csStandard=$(dirname $0)/../config/cs-ruleset.xml
if [ -f $(dirname $0)/../../../$1/package/rules/phpcs.xml ]; then
  csStandard=$csStandard,$(dirname $0)/../../../$1/package/rules/phpcs.xml
fi

# Clone joomla for tmp
if [ ! -d $(dirname $0)/../config/joomla ]; then
  git clone -b staging --single-branch --depth 1 https://github.com/joomla/joomla-cms.git $(dirname $0)/../config/joomla
fi

$(dirname $0)/../config/vendor/bin/phpcs -p --severity=1 --colors --standard=$csStandard $(dirname $0)/../../../$1/$2
