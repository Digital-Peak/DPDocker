<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

$name    = basename($argv[1]);
$wwwRoot = $argv[1];
if (!str_starts_with($wwwRoot, '/')) {
	$wwwRoot = '/var/www/html/' . $wwwRoot;
}
$root          = \dirname($wwwRoot);
$db            = \array_key_exists(3, $argv) ? $argv[3] : 'mysql';
$joomlaVersion = \array_key_exists(4, $argv) ? $argv[4] : (substr($name, -1) == 6 ? 6 : 5);
$force         = \array_key_exists(5, $argv) && $argv[5] === 'yes' ? true : false;
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
if (!is_dir($root . '/cache/' . $completeVersion)) {
	downloadStableJoomla($completeVersion, $root);
}

echo 'Syncing cache to ' . $wwwRoot . PHP_EOL;
shell_exec('rsync -r --delete --exclude .git ' . $root . '/cache/' . $completeVersion . '/ ' . $wwwRoot . ' > /dev/null 2>&1');

echo 'Using version ' . $completeVersion . ' on ' . $wwwRoot . PHP_EOL;

// Live output the install Joomla command
while (@ob_end_flush());
$proc = popen($root . '/Projects/DPDocker/webserver/scripts/install-joomla.sh ' . $wwwRoot . ' ' . $db . ' sites_' . $name . ' "Joomla ' . $name . '" mailcatcher', 'r');
while (!feof($proc)) {
	echo fread($proc, 4096);
	@flush();
}

// Check if extensions are needed to be installed
if (!$argv[2]) {
	return;
}

$folders = explode(',', $argv[2]);
if ($argv[2] == 'all') {
	$folders = array_diff(scandir(\dirname(\dirname(\dirname(__DIR__)))), ['..', '.', 'DPDocker']);
}

require_once 'link-extension.php';

foreach ($folders as $project) {
	// Ignore projects with a dash when not a dev site is built and we use all extensions
	if ($argv[2] == 'all' && strpos($name, 'dev') === false && strpos($project, '-') > 0) {
		continue;
	}

	// Ignore all non dev projects when we have a dev site and we use all extensions
	if ($argv[2] == 'all' && strpos($name, 'dev') !== false && strpos($project, '-Dev') === false) {
		continue;
	}

	// Check if it is a Joomla installation
	if (is_dir($root . '/Projects/' . $project . '/includes')) {
		continue;
	}

	// Ignore files
	if (is_file($root . '/Projects/' . $project)) {
		continue;
	}

	createLinks($root . '/Projects/' . $project . '/', $wwwRoot);
}
echo 'Discovering extensions on ' . $wwwRoot . PHP_EOL;
// Ugly hack to not abort when an extension fails
echo shell_exec('sed -i "0,/return -1;/s/return -1;/continue;/" ' . $wwwRoot . '/libraries/src/Console/ExtensionDiscoverInstallCommand.php');
echo shell_exec('php -d error_reporting=1 ' . $wwwRoot . '/cli/joomla.php extension:discover');
echo shell_exec('php -d error_reporting=1 ' . $wwwRoot . '/cli/joomla.php extension:discover:install');

function downloadStableJoomla($version, $root)
{
	echo 'Downloading ' . $version . ' from site to cache directory' . PHP_EOL;

	$destinationDir = $root . '/cache/' . $version;

	// Download ZIP
	if (!is_dir($destinationDir)) {
		mkdir($destinationDir, 0755, true);
	}

	[$major]     = explode('.', $version);
	$version     = str_replace('.', '-', $version);
	$downloadUrl = 'https://downloads.joomla.org/cms/joomla' . $major . '/' . $version . '/Joomla_' . $version . '-Stable-Full_Package.zip?format=zip';

	$filename = basename(parse_url($downloadUrl, PHP_URL_PATH));
	$zipPath  = $destinationDir . '/' . $filename;

	$ch = curl_init($downloadUrl);
	$fp = fopen($zipPath, 'w');
	curl_setopt($ch, CURLOPT_FILE, $fp);
	curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
	curl_setopt($ch, CURLOPT_TIMEOUT, 600);
	curl_exec($ch);
	curl_close($ch);
	fclose($fp);

	// Unzip
	if (!is_dir($destinationDir)) {
		mkdir($destinationDir, 0755, true);
	}

	$zip = new ZipArchive();
	if (!$zip->open($zipPath) === true) {
		throw new RuntimeException('Could not extract Joomla package');
	}

	$zip->extractTo($destinationDir);
	$zip->close();

	unlink($zipPath);

	echo 'Extracted successfully' . PHP_EOL;
}

function downloadDevJoomla($version, $branch, $root)
{

	$syncBack = false;
	if (!is_dir($root . '/cache/' . $version)) {
		echo 'Cloning ' . $version . ' from repo to cache directory' . PHP_EOL;
		shell_exec('git clone https://github.com/joomla/joomla-cms.git ' . $root . '/cache/' . $version . ' > /dev/null 2>&1');
		// Checkout latest stable release
		shell_exec('git --work-tree=' . $root . '/cache/' . $version . ' --git-dir=' . $root . '/cache/' . $version . '/.git checkout ' . ($isBranch ? $version : 'tags/' . $version) . ' > /dev/null 2>&1');
		$syncBack = true;
	}

	// Only update when it is a branch and not newly cloned
	if ($isBranch && !$syncBack) {
		echo 'Updating branch ' . $version . PHP_EOL;
		shell_exec('git --work-tree=' . $root . '/cache/' . $version . ' --git-dir=' . $root . '/cache/' . $version . '/.git fetch > /dev/null 2>&1');
		shell_exec('git --work-tree=' . $root . '/cache/' . $version . ' --git-dir=' . $root . '/cache/' . $version . '/.git reset --hard > /dev/null 2>&1');
		shell_exec('git --work-tree=' . $root . '/cache/' . $version . ' --git-dir=' . $root . '/cache/' . $version . '/.git pull > /dev/null 2>&1');
		$syncBack = true;
	}
}
