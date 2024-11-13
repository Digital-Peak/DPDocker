#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

status=0

cd $(dirname $0)/../config
composer install --quiet
npm install --silent

echo -e "\nChecking for PHP code style issues"
# Allow the extension to overwrite the default config file
file=$(dirname $0)/../config/.php-cs-fixer.php
if [ -f $(dirname $0)/../../../$1/.php-cs-fixer.php ]; then
	file=$(dirname $0)/../../../$1/.php-cs-fixer.php
fi
$(dirname $0)/../config/vendor/bin/php-cs-fixer fix --allow-risky=yes --dry-run --path-mode=intersection -v --config $file $(dirname $0)/../../../$1/$2 || status=$?

echo -e "\nChecking for Javascript code style issues"
# Allow the extension to overwrite the default config file
file=$(dirname $0)/../config/eslint.config.mjs
if [ -f $(dirname $0)/../../../$1/eslint.config.mjs ]; then
	file=$(dirname $0)/../../../$1/eslint.config.mjs
fi
# Eslint needs to config and pattern below the current path
# https://github.com/eslint/eslint/discussions/18806
cd $(dirname $0)/../../../
$(dirname $0)/../config/node_modules/.bin/eslint --config $file $(dirname $0)/../../../$1/$2 || status=$?
cd $(dirname $0)/../config

echo -e "\nChecking for CSS code style issues"
# Allow the extension to overwrite the default config file
file=$(dirname $0)/../config/.stylelintrc.json
if [ -f $(dirname $0)/../../../$1/.stylelintrc.json ]; then
	file=$(dirname $0)/../../../$1/.stylelintrc.json
fi
stylelint --allow-empty-input --formatter verbose "$(dirname $0)/../../../$1/$2/**/*.scss" || status=$?

exit $status
