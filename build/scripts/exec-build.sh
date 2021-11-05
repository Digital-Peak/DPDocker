#!/bin/bash
# @package   DPDocker
# @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
# @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL

extension=$1
version=$2
root=$3
if [ -z $root ]; then
	root=$(realpath $(dirname $0)/../../../$extension)
fi

workingDir=$(realpath "$(dirname $0)/../tmp")

echo "Building $extension version $version!"

sudo rm -rf $(dirname $0)/../dist
sudo rm -rf $workingDir
mkdir $workingDir

echo "Copy $root to $workingDir"
cp -r $root $workingDir/$extension
sudo rm -rf $workingDir/$extension/.git

echo "Installing dependencies"
$(dirname $0)/../../composer/scripts/exec-install.sh $extension '' $workingDir

echo "Building assets"
$(dirname $0)/../../npm/scripts/exec-npm-install.sh $extension '' $workingDir

if [ ! -z "$version" ]; then
	echo "Define version number in manifest files"
	find $workingDir/$extension -type f -name "*.xml" -exec sed -i "s/DP_DEPLOY_VERSION/$version/g" {} +
	find $workingDir/$extension -type f -name "*.xml" -exec sed -i "s/DP_DEPLOY_DATE/$(LANG=en_us_88591; date "+%-d %b %Y")/g" {} +
fi

echo "Clearing comments from ini files"
find $workingDir/$extension -type f -name "*.ini" -exec sed -i "/^;/d;/^$/d" {} +

echo "Executing the build script to create the installation packages"
php $(dirname $0)/build.php $workingDir/$extension

echo "Copy files to build directory"
cp -r $workingDir/dist $(dirname $0)/..

echo "Cleanup working directory"
sudo rm -rf $workingDir

echo "Finished to build $extension with version $version!!"
