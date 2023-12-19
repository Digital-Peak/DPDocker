#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

# Push the images
docker push digitpeak/dpdocker-cli:7.4
docker push digitpeak/dpdocker-cli:8.2
docker push digitpeak/dpdocker-cli:8.3
docker push digitpeak/dpdocker-cli:latest
docker push digitpeak/dpdocker-web:7.4
docker push digitpeak/dpdocker-web:8.2
docker push digitpeak/dpdocker-web:8.3
docker push digitpeak/dpdocker-web:latest
