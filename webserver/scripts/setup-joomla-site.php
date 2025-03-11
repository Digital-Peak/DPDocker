<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

$wwwRoot	   = '/var/www/html/' . $argv[1];
$db			   = array_key_exists(3, $argv) ? $argv[3] : 'mysql';
$joomlaVersion = array_key_exists(4, $argv) ? $argv[4] : (substr($argv[1], -1) == 4 ? 4 : 3);
$force		   = array_key_exists(5, $argv) && $argv[5] === 'yes' ? true : false;
$isBranch      = strpos($joomlaVersion, '-dev') !== false;

if (is_dir($wwwRoot) && !$force) {
	return;
}

$completeVersion = $isBranch ? $joomlaVersion : null;
if (!$completeVersion) {
	foreach (json_decode(file_get_contents('https://downloads.joomla.org/api/v1/latest/cms'))->branches as $branch) {
		if ($branch->branch !== 'Joomla! ' . $joomlaVersion) {
			continue;
		}

		$completeVersion = $branch->version;
		break;
	}
}

// No version found
if (!$completeVersion) {
	return;
}

$syncBack = false;
if (!is_dir('/var/www/html/cache/' . $completeVersion)) {
	echo 'Cloning ' . $completeVersion . ' from repo to cache directory' . PHP_EOL;
	shell_exec('git clone https://github.com/joomla/joomla-cms.git /var/www/html/cache/' . $completeVersion . ' > /dev/null 2>&1');
	// Checkout latest stable release
	shell_exec('git --work-tree=/var/www/html/cache/' . $completeVersion . ' --git-dir=/var/www/html/cache/' . $completeVersion . '/.git checkout ' . ($isBranch ? $completeVersion : 'tags/' . $completeVersion) . ' > /dev/null 2>&1');
	$syncBack = true;
}

// Only update when it is a branch and not newly cloned
if ($isBranch && !$syncBack) {
	echo 'Updating branch ' . $completeVersion . PHP_EOL;
	shell_exec('git --work-tree=/var/www/html/cache/' . $completeVersion . ' --git-dir=/var/www/html/cache/' . $completeVersion . '/.git fetch > /dev/null 2>&1');
	shell_exec('git --work-tree=/var/www/html/cache/' . $completeVersion . ' --git-dir=/var/www/html/cache/' . $completeVersion . '/.git reset --hard > /dev/null 2>&1');
	shell_exec('git --work-tree=/var/www/html/cache/' . $completeVersion . ' --git-dir=/var/www/html/cache/' . $completeVersion . '/.git pull > /dev/null 2>&1');
	$syncBack = true;
}

echo 'Syncing cache to ' . $wwwRoot . PHP_EOL;
shell_exec('rsync -r --delete --exclude .git /var/www/html/cache/' . $completeVersion . '/ ' . $wwwRoot . ' > /dev/null 2>&1');

echo 'Using version ' . $completeVersion . ' on ' . $wwwRoot . PHP_EOL;

// Put joomla in dev state so we don't have to delete the installation directory
file_put_contents(
	$wwwRoot . '/libraries/src/Version.php',
	str_replace("const DEV_STATUS = 'Stable';", "const DEV_STATUS = 'Development';", file_get_contents($wwwRoot . '/libraries/src/Version.php'))
);

// Live output the install Joomla command
while (@ob_end_flush());
$proc = popen('/var/www/html/Projects/DPDocker/webserver/scripts/install-joomla.sh ' . $wwwRoot . ' ' . $db . ' sites_' . $argv[1] . ' "Joomla ' . $argv[1] . '" mailcatcher' .($isBranch ? ' r' : ''), 'r');
while (!feof($proc)) {
	echo fread($proc, 4096);
	@flush();
}

// When cloned sync back the assets and dependencies
if ($syncBack) {
	echo 'Syncing assets and dependencies back to cache ' . $wwwRoot . PHP_EOL;
	shell_exec('rsync -r --delete --exclude .git --exclude configuration.php --exclude node_modules --exclude .vscode ' . $wwwRoot . '/ /var/www/html/cache/' . $completeVersion . ' > /dev/null 2>&1');
}

// Check if extensions are needed to be installed
if (!$argv[2]) {
	return;
}

$folders = explode(',', $argv[2]);
if ($argv[2] == 'all') {
	$folders = array_diff(scandir(dirname(dirname(dirname(__DIR__)))), ['..', '.', 'DPDocker']);
}

require_once 'link-extension.php';

foreach ($folders as $project) {
	// Ignore projects with a dash when not a dev site is built and we use all extensions
	if ($argv[2] == 'all' && strpos($argv[1], 'dev') === false && strpos($project, '-') > 0) {
		continue;
	}

	// Ignore all non dev projects when we have a dev site and we use all extensions
	if ($argv[2] == 'all' && strpos($argv[1], 'dev') !== false && strpos($project, '-Dev') === false) {
		continue;
	}

	// Check if it is a Joomla installation
	if (is_dir('/var/www/html/Projects/' . $project . '/includes')) {
		continue;
	}

	// Ignore files
	if (is_file('/var/www/html/Projects/' . $project)) {
		continue;
	}

	createLinks('/var/www/html/Projects/' . $project . '/', $wwwRoot);
}
echo 'Discovering extensions on ' . $wwwRoot . PHP_EOL;
// Ugly hack to not abort when an extension fails
echo shell_exec('sed -i "0,/return -1;/s/return -1;/continue;/" ' . $wwwRoot . '/libraries/src/Console/ExtensionDiscoverInstallCommand.php');
echo shell_exec('php -d error_reporting=1 ' . $wwwRoot . '/cli/joomla.php extension:discover');
echo shell_exec('php -d error_reporting=1 ' . $wwwRoot . '/cli/joomla.php extension:discover:install');
