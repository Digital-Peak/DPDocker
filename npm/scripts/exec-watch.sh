#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

# Make sure the dependencies are correct
cd $(dirname $0)

if [ ! -d node_modules ]; then
  npm install
fi

# Execute build
node watch.js $1 $2
