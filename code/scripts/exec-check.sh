#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

cd $(dirname $0)/../config
composer install --quiet

# Allow the extension to overwrite the default file
file=$(dirname $0)/../config/.php-cs-fixer.php
if [ -f $(dirname $0)/../../../$1/.php-cs-fixer.php ]; then
	file=$(dirname $0)/../../../$1/.php-cs-fixer.php
fi

$(dirname $0)/../config/vendor/bin/php-cs-fixer fix --dry-run --path-mode=intersection -v --config $file $(dirname $0)/../../../$1/$2
