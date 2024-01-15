#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

export DPDOCKER_EXTENSION_PATH=$(realpath $(dirname $0)/../../../$1)

status=0

cd $(dirname $0)/../config
composer install --quiet
npm install --silent

if [ ! -d $(dirname $0)/../tmp ]; then
	git clone https://github.com/joomla/joomla-cms.git $(dirname $0)/../tmp
	mkdir $(dirname $0)/../tmp/media
fi

cd $(dirname $0)/../tmp
git reset --hard
git pull
composer install --no-dev
rm -f $(dirname $0)/../tmp/administrator/cache/autoload_psr4.php

echo -e "\nFixing PHP code quality issues with Rector"
# Allow the extension to overwrite the default config file
file=$(dirname $0)/../config/rector.php
if [ -f $(dirname $0)/../../../$1/rector.php ]; then
	file=$(dirname $0)/../../../$1/rector.php
fi
$(dirname $0)/../config/vendor/bin/rector process --config $file $(dirname $0)/../../../$1/$2 || status=$?

echo -e "\nAnalyze PHP code quality issues with PHPStan"
# Allow the extension to overwrite the default config file
file=$(dirname $0)/../config/phpstan.neon
if [ -f $(dirname $0)/../../../$1/phpstan.neon ]; then
	file=$(dirname $0)/../../../$1/phpstan.neon
fi
$(dirname $0)/../config/vendor/bin/phpstan analyse --memory-limit 1G -c $file $(dirname $0)/../../../$1/$2 || status=$?

find $(dirname $0)/../tmp -type l -delete

exit $status
