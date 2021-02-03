<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2021 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

$path = dirname(__FILE__);
if (isset($_SERVER["SCRIPT_FILENAME"])) {
	$path = dirname($_SERVER["SCRIPT_FILENAME"]);
}

define('_JEXEC', 1);
define('JPATH_BASE', $path);
require_once JPATH_BASE . '/includes/defines.php';
require_once JPATH_BASE . '/includes/framework.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

class DPDockerExtensionDiscover extends Joomla\CMS\Application\CliApplication
{
	public function doExecute()
	{
		// Refresh the cache of discovered extensions
		Joomla\CMS\MVC\Model\BaseDatabaseModel::addIncludePath(JPATH_ADMINISTRATOR . '/components/com_installer/models');
		$model = Joomla\CMS\MVC\Model\BaseDatabaseModel::getInstance('Discover', 'InstallerModel');
		$model->discover();

		// Get the discovered extensions
		$db    = Joomla\CMS\Factory::getDbo();
		$query = $db->getQuery(true)
			->select($db->quoteName(['extension_id']))
			->from($db->quoteName('#__extensions'))
			->where($db->quoteName('state') . ' = -1');
		$db->setQuery($query);

		$installer = new Joomla\CMS\Installer\Installer();
		foreach ($db->loadObjectList() as $extensionToDiscover) {
			// Install the discovered extension
			$installer->discover_install($extensionToDiscover->extension_id);
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

$app                             = Joomla\CMS\Application\CliApplication::getInstance('DPDockerExtensionDiscover');
Joomla\CMS\Factory::$application = $app;
$app->execute();
