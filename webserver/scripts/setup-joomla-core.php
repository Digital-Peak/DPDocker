<?php
/**
 * @author     Digital Peak http://www.digital-peak.com
 * @copyright  Copyright (C) 2007 - 2020 Digital Peak. All rights reserved.
 * @license    http://www.gnu.org/licenses/gpl.html GNU/GPL
 */

$wwwRoot = '/var/www/html/' . $argv[1];
$force   = array_key_exists(2, $argv) ? (bool)$argv[2] : false;

if (!is_dir($wwwRoot)) {
	symlink('/var/www/html/Projects/' . $argv[1], $wwwRoot);
}

// Change the working directory
chdir($wwwRoot);

if (is_file($wwwRoot . '/libraries/autoload_psr4.php')) {
	unlink($wwwRoot . '/libraries/autoload_psr4.php');
}

if (!is_dir($wwwRoot . '/libraries/vendor') || $force) {
	shell_exec('rm -rf ' . $wwwRoot . '/libraries/vendor');
	shell_exec('composer install');
}

if (is_file($wwwRoot . '/package.json') && (!is_dir($wwwRoot . '/media') || $force)) {
	shell_exec('npm ci');
}
