<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

function createLinks($folderRoot, $wwwRoot)
{
	echo 'Starting to create the links for ' . $folderRoot . PHP_EOL;

	// Folder structure like https://github.com/joomla-extensions/weblinks
	if (file_exists($folderRoot . '/src/administrator/components/')) {
		foreach (new DirectoryIterator($folderRoot . '/src/administrator/components/') as $filename) {
			createLink($folderRoot . '/src/administrator/components/' . $filename, $wwwRoot . '/administrator/components/' . $filename);
		}
	}
	if (file_exists($folderRoot . '/src/administrator/manifests/packages/')) {
		foreach (new DirectoryIterator($folderRoot . '/src/administrator/manifests/packages/') as $filename) {
			createLink(
				$folderRoot . '/src/administrator/manifests/packages/' . $filename,
				$wwwRoot . '/administrator//manifests/packages/' . $filename
			);
		}
	}
	if (file_exists($folderRoot . '/src/api/components/')) {
		foreach (new DirectoryIterator($folderRoot . '/src/api/components/') as $filename) {
			createLink($folderRoot . '/src/api/components/' . $filename, $wwwRoot . '/api/components/' . $filename);
		}
	}
	if (file_exists($folderRoot . '/src/components/')) {
		foreach (new DirectoryIterator($folderRoot . '/src/components/') as $filename) {
			createLink($folderRoot . '/src/components/' . $filename, $wwwRoot . '/components/' . $filename);
		}
	}
	if (file_exists($folderRoot . '/src/administrator/language')) {
		$languages = scandir($folderRoot . '/src/administrator/language');
		foreach ($languages as $language) {
			foreach (new DirectoryIterator($folderRoot . '/src/administrator/language/' . $language) as $filename) {
				createLink(
					$folderRoot . '/src/administrator/language/' . $language . '/' . $filename,
					$wwwRoot . '/administrator/language/' . $language . '/' . $filename
				);
			}
		}
	}
	if (file_exists($folderRoot . '/src/language')) {
		$languages = scandir($folderRoot . '/src/language');
		foreach ($languages as $language) {
			foreach (new DirectoryIterator($folderRoot . '/src/language/' . $language) as $filename) {
				createLink($folderRoot . '/src/language/' . $language . '/' . $filename, $wwwRoot . '/language/' . $language . '/' . $filename);
			}
		}
	}
	if (file_exists($folderRoot . '/src/media/')) {
		foreach (new DirectoryIterator($folderRoot . '/src/media/') as $filename) {
			createLink($folderRoot . '/src/media/' . $filename, $wwwRoot . '/media/' . $filename);
		}
	}
	if (file_exists($folderRoot . '/src/modules/')) {
		foreach (new DirectoryIterator($folderRoot . '/src/modules/') as $filename) {
			createLink($folderRoot . '/src/modules/' . $filename, $wwwRoot . '/modules/' . $filename);
		}
	}
	if (file_exists($folderRoot . '/src/plugins')) {
		$groups = scandir($folderRoot . '/src/plugins');
		foreach ($groups as $group) {
			foreach (new DirectoryIterator($folderRoot . '/src/plugins/' . $group) as $filename) {
				createLink($folderRoot . '/src/plugins/' . $group . '/' . $filename, $wwwRoot . '/plugins/' . $group . '/' . $filename);
			}
		}
	}
	if (file_exists($folderRoot . '/src/templates/')) {
		foreach (new DirectoryIterator($folderRoot . '/src/templates/') as $filename) {
			createLink($folderRoot . '/src/templates/' . $filename, $wwwRoot . '/templates/' . $filename);
		}
	}

	foreach (new DirectoryIterator($folderRoot) as $filename) {
		// Ignore files
		if (is_file($folderRoot . $filename)) {
			continue;
		}

		if (strpos($filename, 'com_') === 0) {
			createLink($folderRoot . $filename . '/admin', $wwwRoot . '/administrator/components/' . $filename);
			createLink($folderRoot . $filename . '/site', $wwwRoot . '/components/' . $filename);
			createLink($folderRoot . $filename . '/media', $wwwRoot . '/media/' . $filename);

			if (file_exists($folderRoot . $filename . '/api') && file_exists($wwwRoot . '/api/components/')) {
				createLink($folderRoot . $filename . '/api', $wwwRoot . '/api/components/' . $filename);
			}
		}

		if (strpos($filename, 'mod_') === 0) {
			foreach (new RegexIterator(new DirectoryIterator($folderRoot . $filename), "/\\.xml\$/i") as $moduleFile) {
				$xml = new SimpleXMLElement(file_get_contents($folderRoot . $filename . '/' . $moduleFile));
				createLink($folderRoot . $filename, $wwwRoot . ((string)$xml->attributes()->client === 'administrator' ? '/administrator/' : '') . '/modules/' . $filename);
			}

			if (file_exists($folderRoot . $filename . '/media')) {
				createLink($folderRoot . $filename . '/media', $wwwRoot . '/media/' . $filename);
			}
		}

		if (strpos($filename, 'plg_') === 0) {
			foreach (new RegexIterator(new DirectoryIterator($folderRoot . $filename), "/\\.xml\$/i") as $pluginFile) {
				$xml = new SimpleXMLElement(file_get_contents($folderRoot . $filename . '/' . $pluginFile));

				foreach ($xml->files->children() as $file) {
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

		if (strpos($filename, 'tpl_') === 0) {
			createLink($folderRoot . $filename, $wwwRoot . '/templates/' . str_replace('tpl_', '', $filename));
		}

		if (strpos($filename, 'lib_') === 0) {
			createLink($folderRoot . $filename, $wwwRoot . '/libraries/' . $filename);
			createLink($folderRoot . $filename . '/' . $filename . '.xml', $wwwRoot . '/administrator/manifests/libraries/' . $filename . '.xml');

			if (file_exists($folderRoot . $filename . '/media')) {
				createLink($folderRoot . $filename . '/media', $wwwRoot . '/media/' . $filename);
			}
		}

		// Link resources for sourcemap
		if (file_exists($folderRoot . $filename . '/resources')) {
			createLink($folderRoot . $filename . '/resources', $wwwRoot . '/media/resources/' . $filename);
		}
	}
	echo 'Finished to create the links for ' . $folderRoot . PHP_EOL;
}

function createLink($source, $target)
{
	$source = realpath($source);

	@mkdir(\dirname($target), 0777, true);
	shell_exec('ln -sfn ' . $source . ' ' . $target);
}
