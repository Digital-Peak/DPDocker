#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

f=""
if [ ! -z $1 ]; then
	f="--no-cache --pull"
fi

# Build the images
docker build $(dirname $0)/cli $f -t digitpeak/dpdocker-cli:7.4 --build-arg PHP_VERSION=7.4
docker build $(dirname $0)/cli $f -t digitpeak/dpdocker-cli:8.2 --build-arg PHP_VERSION=8.2
docker build $(dirname $0)/cli $f -t digitpeak/dpdocker-cli:8.3 --build-arg PHP_VERSION=8.3
docker build $(dirname $0)/cli $f -t digitpeak/dpdocker-cli:latest --build-arg PHP_VERSION=8.3
docker build $(dirname $0)/web $f -t digitpeak/dpdocker-web:7.4 --build-arg PHP_VERSION=7.4
docker build $(dirname $0)/web $f -t digitpeak/dpdocker-web:8.2 --build-arg PHP_VERSION=8.2
docker build $(dirname $0)/web $f -t digitpeak/dpdocker-web:8.2 --build-arg PHP_VERSION=8.3
docker build $(dirname $0)/web $f -t digitpeak/dpdocker-web:latest --build-arg PHP_VERSION=8.3
