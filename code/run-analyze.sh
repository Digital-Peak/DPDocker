#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

# Ensure cache directory exists
mkdir -p $(dirname $0)/tmp/cache/rector
mkdir -p $(dirname $0)/tmp/cache/phpstan

EXTENSION=$1 FILE=$2 docker compose -f $(dirname $0)/docker-compose.yml run --rm analyze
