<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2021 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

use Joomla\CMS\Application\CliApplication;
use Joomla\CMS\Factory;
use Joomla\CMS\Installer\Installer;
use Joomla\CMS\Log\Log;
use Joomla\CMS\Log\LogEntry;
use Joomla\CMS\MVC\Model\BaseDatabaseModel;

$path = dirname(__FILE__);
if (isset($_SERVER["SCRIPT_FILENAME"])) {
	$path = dirname($_SERVER["SCRIPT_FILENAME"]);
}

define('_JEXEC', 1);
define('JPATH_BASE', $path);
require_once JPATH_BASE . '/includes/defines.php';
require_once JPATH_BASE . '/includes/framework.php';

// Disable error reporting for Joomla 3
error_reporting(E_ERROR);

Log::addLogger(['logger' => 'echo'], Log::ERROR);

class DPDockerExtensionDiscover extends CliApplication
{
	public function doExecute()
	{
		// Set the host variable for uri access
		$_SERVER['HTTP_HOST'] = 'https://example.com';

		// Refresh the cache of discovered extensions
		BaseDatabaseModel::addIncludePath(JPATH_ADMINISTRATOR . '/components/com_installer/models');
		$model = BaseDatabaseModel::getInstance('Discover', 'InstallerModel');
		$model->discover();

		// Get the discovered extensions
		$db	= Factory::getDbo();
		$query = $db->getQuery(true)
			->select($db->quoteName(['extension_id']))
			->from($db->quoteName('#__extensions'))
			->where($db->quoteName('state') . ' = -1');
		$db->setQuery($query);

		$installer = new Installer();
		foreach ($db->loadObjectList() as $extensionToDiscover) {
			// Install the discovered extension
			if ($installer->discover_install($extensionToDiscover->extension_id)) {
				continue;
			}

			echo 'Could not install extension with ID: ' . $extensionToDiscover->extension_id . PHP_EOL;
		}

		// In joomla 4 have discovered extensions an access level of 0
		$query = $db->getQuery(true)
			->update($db->quoteName('#__extensions'))
			->set($db->quoteName('access') . ' = 1')
			->where($db->quoteName('access') . ' = 0');
		$db->setQuery($query);
		$db->execute();
	}

	public function getName()
	{
		return 'DPDockerExtensionDiscover';
	}

	public function isClient($name)
	{
		return $name == 'administrator';
	}

	public function flushAssets()
	{
	}
}

$app				  = CliApplication::getInstance('DPDockerExtensionDiscover');
Factory::$application = $app;
$app->execute();
