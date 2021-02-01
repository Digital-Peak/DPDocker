#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

# Build the images
docker build $(dirname $0)/cli -t dpdocker-cli:7.3 --build-arg PHP_VERSION=7.3
docker build $(dirname $0)/cli -t dpdocker-cli:7.4 --build-arg PHP_VERSION=7.4
docker build $(dirname $0)/cli -t dpdocker-cli:8.0 --build-arg PHP_VERSION=8.0
docker build $(dirname $0)/web -t dpdocker-web:7.3 --build-arg PHP_VERSION=7.3
docker build $(dirname $0)/web -t dpdocker-web:7.4 --build-arg PHP_VERSION=7.4
docker build $(dirname $0)/web -t dpdocker-web:8.0 --build-arg PHP_VERSION=8.0
