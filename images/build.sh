#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

# Build the images
docker build $(dirname $0)/cli -t dpdocker-cli
docker build $(dirname $0)/web -t dpdocker-web
