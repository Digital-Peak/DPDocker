#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

cd $(dirname $0)/../config
composer install --quiet
npm install --silent

echo -e "\nFixing PHP code style issues"
# Allow the extension to overwrite the default config file
file=$(dirname $0)/../config/.php-cs-fixer.php
if [ -f $(dirname $0)/../../../$1/.php-cs-fixer.php ]; then
	file=$(dirname $0)/../../../$1/.php-cs-fixer.php
fi
$(dirname $0)/../config/vendor/bin/php-cs-fixer fix --diff --path-mode=intersection -v --config $file $(dirname $0)/../../../$1/$2

echo -e "\nFixing Javascript code style issues"
# Allow the extension to overwrite the default config file
file=$(dirname $0)/../config/.eslintrc.js
if [ -f $(dirname $0)/../../../$1/.eslintrc.js ]; then
	file=$(dirname $0)/../../../$1/.eslintrc.js
fi
DEBUG=eslint:cli-engine eslint --fix --no-error-on-unmatched-pattern --config $file --ignore-pattern '**/media/*' --ext .js $(dirname $0)/../../../$1/$2

echo -e "\nFixing CSS code style issues"
# Allow the extension to overwrite the default config file
file=$(dirname $0)/../config/.stylelintrc.json
if [ -f $(dirname $0)/../../../$1/.stylelintrc.json ]; then
	file=$(dirname $0)/../../../$1/.stylelintrc.json
fi
npx stylelint --fix --allow-empty-input --formatter verbose "$(dirname $0)/../../../$1/$2/**/*.scss"

find $(dirname $0)/../tmp -type l -delete
