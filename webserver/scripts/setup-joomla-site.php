<?php
/**
 * @author     Digital Peak http://www.digital-peak.com
 * @copyright  Copyright (C) 2007 - 2020 Digital Peak. All rights reserved.
 * @license    http://www.gnu.org/licenses/gpl.html GNU/GPL
 */

$wwwRoot = '/var/www/html/' . $argv[1];
$db      = $argv[3];
$force   = array_key_exists(4, $argv) ? (bool)$argv[4] : false;
$binary  = '/home/docker/.composer/vendor/bin/joomla';

if (is_dir($wwwRoot)) {
	if (!$force) {
		return;
	}

	shell_exec($binary . ' site:delete ' . $argv[1] . ' --www=/var/www/html --mysql-host=' . $db);
}
shell_exec($binary . ' site:create ' . $argv[1] . ' --www=/var/www/html --disable-ssl --mysql-host=' . $db);

$folders = explode(',', $argv[2]);
if ($argv[2] == 'all') {
	$folders = array_diff(scandir(dirname(dirname(dirname(__DIR__)))), array('..', '.'));
}

foreach ($folders as $project) {
	// Ignore projects with a dash when not a dev site is built
	if ($argv[1] != 'dev' && strpos($project, '-') > 0) {
		continue;
	}

	// Ignore all non dev projects when we have a dev site
	if ($argv[1] == 'dev' && strpos($project, '-Dev') === false) {
		continue;
	}

	createLinks('/var/www/html/Projects/' . $project . '/', $wwwRoot);
}
shell_exec($binary . ' extension:install ' . $argv[1] . ' all --www=/var/www/html');

function createLinks($folderRoot, $wwwRoot)
{
	echo 'Starting to create the links for ' . $folderRoot . '.' . PHP_EOL;

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
	echo 'Finished to create the links for ' . $folderRoot . '.' . PHP_EOL;
}

function createLink($source, $target)
{
	$source = realpath($source);

	@mkdir(dirname($target), '777', true);
	shell_exec('ln -sfn ' . $source . ' ' . $target);
}
