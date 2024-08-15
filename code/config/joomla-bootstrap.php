<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2024 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

if (!defined('_JEXEC')) {
	define('_JEXEC', 1);
	define('JPATH_PLATFORM', 1);
	define('JPATH_BASE', dirname(__DIR__) . '/tmp/joomla');

	// Load the Joomla class loader
	require_once JPATH_BASE . '/includes/defines.php';

	require_once JPATH_LIBRARIES . '/loader.php';
	JLoader::setup();
	require_once JPATH_LIBRARIES . '/vendor/autoload.php';

	// Rector crashes as it is inside a phar
	//require_once JPATH_BASE . '/tmp/libraries/bootstrap.php';
}

// Start the auto loaders
foreach (new RecursiveIteratorIterator(new RecursiveDirectoryIterator(getenv('DPDOCKER_EXTENSION_PATH'))) as $file) {
	if (strpos($file, '/vendor/autoload.php') !== false) {
		require_once $file;
	}
}

// Create the links to the extension
require_once '../../../webserver/scripts/link-extension.php';

// Hide the output
ob_start();
createLinks(getenv('DPDOCKER_EXTENSION_PATH') . '/', JPATH_BASE);
$extensions = dirname(getenv('DPDOCKER_EXTENSION_PATH')) . '/Joomla-Extensions';
if (is_dir($extensions)) {
	createLinks($extensions . '/', JPATH_BASE);
}
ob_end_clean();

// Load the extension namespaces
JLoader::register('JNamespacePsr4Map', JPATH_LIBRARIES . '/namespacemap.php');
$map = new JNamespacePsr4Map();
$map->create();
