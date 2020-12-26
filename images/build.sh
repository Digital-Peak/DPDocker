#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

PHP_VERSION=${PHP_VERSION:-7.4}
GLOBAL_VERSION=${GLOBAL_VERSION:-3}
NODE_VERSION=${NODE_VERSION:-12}
REBUILD=${REBUILD:false}

while [ $# -gt 0 ]; do
    if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
    fi
  shift
done

if [[ $REBUILD == 'true' || $REBUILD == 'rebuild' ]]; then
  docker rm $(docker ps -a -q) -f
  docker rmi $(docker images -a -q) -f
fi

# Build the images
docker build $(dirname $0)/cli -t dpdocker-cli --build-arg PHP_VERSION=${PHP_VERSION} --build-arg GLOBAL_VERSION=${GLOBAL_VERSION} --build-arg NODE_VERSION=${NODE_VERSION}
docker build $(dirname $0)/web -t dpdocker-web --build-arg PHP_VERSION=${PHP_VERSION} --build-arg GLOBAL_VERSION=${GLOBAL_VERSION} --build-arg NODE_VERSION=${NODE_VERSION}
