<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2024 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

define('_JEXEC', 1);

// Load the Joomla class loader
require_once dirname(__DIR__) . '/tmp/includes/defines.php';

require_once JPATH_LIBRARIES . '/loader.php';
JLoader::setup();
require_once JPATH_LIBRARIES . '/vendor/autoload.php';

// Rector crashes as it is inside a phar
//require_once dirname(__DIR__) . '/tmp/libraries/bootstrap.php';

// Start the auto loaders
foreach (new RecursiveIteratorIterator(new RecursiveDirectoryIterator(getenv('DPDOCKER_EXTENSION_PATH'))) as $file) {
	 if (strpos($file , '/vendor/autoload.php') !== false) {
		require_once $file;
	 }
}

// Create the links to the extension
require_once '../../webserver/scripts/link-extension.php';

// Hide the output
ob_start();
createLinks(getenv('DPDOCKER_EXTENSION_PATH') . '/', dirname(__DIR__) . '/tmp');
ob_end_clean();

// Delete the cached namespace file
if (file_exists(JPATH_CACHE . '/autoload_psr4.php')) {
	unlink(JPATH_CACHE . '/autoload_psr4.php');
}

// Load the extension namespaces
JLoader::register('JNamespacePsr4Map', JPATH_LIBRARIES . '/namespacemap.php');
$map = new JNamespacePsr4Map();
$map->load();
