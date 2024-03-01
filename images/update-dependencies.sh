#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

$(dirname $0)/../composer/run-update.sh DPDocker code/config
$(dirname $0)/../npm/run-update.sh DPDocker code/config

$(dirname $0)/../npm/run-update.sh DPDocker npm/scripts

$(dirname $0)/../composer/run-update.sh DPDocker tests/config/extension
