<?php
/**
 * @author     Digital Peak http://www.digital-peak.com
 * @copyright  Copyright (C) 2007 - 2020 Digital Peak. All rights reserved.
 * @license    http://www.gnu.org/licenses/gpl.html GNU/GPL
 */

$wwwRoot = '/var/www/html/' . $argv[1];
$db      = array_key_exists(3, $argv) ? $argv[3] : 'mysql';
$force   = array_key_exists(4, $argv) ? (bool)$argv[4] : false;
$binary  = '/home/docker/.composer/vendor/bin/joomla';

if (is_dir($wwwRoot) && !$force) {
	return;
}

if (!is_dir($wwwRoot) || $force) {
	if (!is_dir('/var/www/html/cache')) {
		shell_exec('git clone https://github.com/joomla/joomla-cms.git /var/www/html/cache 2>&1 > /dev/null');
	} else {
		shell_exec('git --work-tree=/var/www/html/cache --git-dir=/var/www/html/cache/.git fetch origin 2>&1 > /dev/null');
	}

	shell_exec('rm -rf ' . $wwwRoot);
	shell_exec('cp -r /var/www/html/cache ' . $wwwRoot);

	$versions = json_decode(file_get_contents('https://downloads.joomla.org/api/v1/latest/cms'));
	foreach ($versions->branches as $branch) {
		if (strpos($branch->version, '3.') !== 0) {
			continue;
		}
		// Latest stable release is not working on PHP 7.4
		//shell_exec('git --work-tree=' . $wwwRoot . ' --git-dir=' . $wwwRoot . '/.git checkout tags/' . $branch->version . ' 2>&1 > /dev/null');
	}
}
echo shell_exec('/var/www/html/Projects/DPDocker/webserver/scripts/install-joomla.sh ' . $wwwRoot . ' ' . $db . ' sites_' . $argv[1] . ' "Joomla ' . $argv[1] . '" mailcatcher');

// Check if extensions are needed to be installed
if (!$argv[2]) {
	return;
}

$folders = explode(',', $argv[2]);
if ($argv[2] == 'all') {
	$folders = array_diff(scandir(dirname(dirname(dirname(__DIR__)))), ['..', '.', 'DPDocker']);
}

foreach ($folders as $project) {
	// Ignore projects with a dash when not a dev site is built and we use all extensions
	if ($argv[2] == 'all' && $argv[1] != 'dev' && strpos($project, '-') > 0) {
		continue;
	}

	// Ignore all non dev projects when we have a dev site and we use all extensions
	if ($argv[2] == 'all' && $argv[1] == 'dev' && strpos($project, '-Dev') === false) {
		continue;
	}

	createLinks('/var/www/html/Projects/' . $project . '/', $wwwRoot);
}
echo 'Discovering extensions on ' . $wwwRoot . PHP_EOL;
rename($wwwRoot . '/installation', $wwwRoot . '/_installation');
shell_exec($binary . ' extension:install ' . $argv[1] . ' all --www=/var/www/html');
rename($wwwRoot . '/_installation', $wwwRoot . '/installation');

function createLinks($folderRoot, $wwwRoot)
{
	echo 'Starting to create the links for ' . $folderRoot . PHP_EOL;

	foreach (new DirectoryIterator($folderRoot) as $filename) {
		if (strpos($filename, 'com_') === 0) {
			createLink($folderRoot . $filename . '/admin', $wwwRoot . '/administrator/components/' . $filename);
			createLink($folderRoot . $filename . '/site', $wwwRoot . '/components/' . $filename);
			createLink($folderRoot . $filename . '/media', $wwwRoot . '/media/' . $filename);
		}
		if (strpos($filename, 'mod_') === 0) {
			createLink($folderRoot . $filename, $wwwRoot . '/modules/' . $filename);

			if (file_exists($folderRoot . $filename . '/media')) {
				createLink($folderRoot . $filename . '/media', $wwwRoot . '/media/' . $filename);
			}
		}
		if (strpos($filename, 'plg_') === 0) {
			foreach (new RegexIterator(new DirectoryIterator($folderRoot . $filename), "/\\.xml\$/i") as $pluginFile) {
				$xml = new SimpleXMLElement(file_get_contents($folderRoot . $filename . '/' . $pluginFile));

				foreach ($xml->files->filename as $file) {
					$plugin = (string)$file->attributes()->plugin;
					if (!$plugin) {
						continue;
					}

					$group = (string)$xml->attributes()->group;
					if (!is_dir($wwwRoot . '/plugins/' . $group)) {
						@mkdir($wwwRoot . '/plugins/' . $group, '0777', true);
						exec('chmod 777 ' . $wwwRoot . '/plugins/' . $group);
					}

					createLink($folderRoot . $filename, $wwwRoot . '/plugins/' . $group . '/' . $plugin);

					if (file_exists($folderRoot . $filename . '/media')) {
						createLink($folderRoot . $filename . '/media', $wwwRoot . '/media/' . $filename);
					}
				}
			}
		}
		if (strpos($filename, 'tmpl_') === 0) {
			createLink($folderRoot . $filename, $wwwRoot . '/templates/' . str_replace('tmpl_', '', $filename));
		}
	}
	echo 'Finished to create the links for ' . $folderRoot . PHP_EOL;
}

function createLink($source, $target)
{
	$source = realpath($source);

	@mkdir(dirname($target), '777', true);
	shell_exec('ln -sfn ' . $source . ' ' . $target);
}
