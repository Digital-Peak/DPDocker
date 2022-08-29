<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

/**
 * Build release files.
 */
class DPDockerReleaseBuild
{
	public $extensionRoot;

	public function build()
	{
		// Normalize path
		$this->extensionRoot = realpath($this->extensionRoot);

		// Cleanup the dist folder
		$distFolder = dirname($this->extensionRoot) . '/dist';
		shell_exec('rm -rf ' . $distFolder);
		mkdir($distFolder);

		// Read the build config
		$config = json_decode(file_get_contents($this->extensionRoot . '/package/build.json'));
		foreach ($config->packages as $package) {
			// Prepare the temp folder
			$tmpFolder = dirname($this->extensionRoot) . '/build';
			shell_exec('rm -rf ' . $tmpFolder);
			mkdir($tmpFolder);

			// Read the manifest file
			$manifestFile = $this->extensionRoot . '/package/' . $package->originalManifestFileName . '.xml';

			// When there is no package file use the normal extension manifest
			if (!file_exists($manifestFile)){
				$manifestFile = $this->extensionRoot . '/' . $package->name . '/' . $package->originalManifestFileName . '.xml';
			}

			$manifest  = new SimpleXMLElement(file_get_contents($manifestFile));
			$dpVersion = (string)$manifest->version;

			echo ' Creating version ' . $dpVersion . ' of ' . $package->name . PHP_EOL;

			$dpVersion = str_replace('.', '_', $dpVersion);

			// Collect the extensions which do belong to the package
			$extensions = [];

			// Iterate over the files in the manifest
			foreach ($manifest->files->file as $file) {
				$extension = null;
				$id		   = (string)$file->attributes()->id;

				if (!empty($package->extensions)) {
					// Look for an override in the build config
					foreach ($package->extensions as $ex) {
						if ($ex->name == $id) {
							$extension = $ex;
							break;
						}
					}
				}

				// If none override is found, create an extension from the manifest
				if ($extension == null) {
					$extension = (object)['name' => $id];
				}
				$extensions[] = $extension;
			}

			// When no extensions from package we look in the build config
			if (!$extensions) {
				foreach ($package->extensions as $extension) {
					$extensions[] = $extension;
				}
			}

			// Loop over the extensions
			foreach ($extensions as $extension) {
				// Default the excludes
				$excludes = [];
				if (!empty($extension->excludes)) {
					foreach ($extension->excludes as $exclude) {
						$excludes[] = $extension->name . '/' . $exclude;
					}
				}

				// Default the substitutes
				$substitutes = [];
				if (!empty($extension->substitutes)) {
					foreach ($extension->substitutes as $substitute) {
						$substitutes[$extension->name . '/' . $substitute->original] = $extension->name . '/' . $substitute->replace;
					}
				}

				// Create the extension zip file
				$this->createZip(
					$this->extensionRoot . '/' . $extension->name,
					$tmpFolder . '/' . $extension->name . '.zip',
					$excludes,
					$substitutes
				);

				// When no single archive continue
				if (count($extensions) > 1) {
					continue;
				}

				// Extract the zip file again as we have it in the main build folder
				$zip = new ZipArchive();
				$zip->open($tmpFolder . '/' . $extension->name . '.zip');
				$zip->extractTo($tmpFolder);
				$zip->close();

				// Delete the zip file
				unlink($tmpFolder . '/' . $extension->name . '.zip');
			}

			// Copy some package files to the tmp folder
			if (count($extensions) > 1 && is_file($this->extensionRoot . '/package/script.php')) {
				copy($this->extensionRoot . '/package/script.php', $tmpFolder . '/script.php');
			}
			copy($this->extensionRoot . '/License.md', $tmpFolder . '/License.txt');
			copy($manifestFile, $tmpFolder . '/' . $package->substituteManifestFileName . '.xml');

			// Create the package zip file
			$this->createZip($tmpFolder, $distFolder . '/' . $package->name . '_' . $dpVersion . '.zip', [], []);
		}
	}

	private function createZip($folder, $zipFile, $excludes, $substitutes)
	{
		// Some predefined excludes
		$excludes[] = 'vendor-ignore.txt';
		$excludes[] = 'composer.json';
		$excludes[] = 'composer.lock';
		$excludes[] = 'css.map';
		$excludes[] = 'js.map';

		// The zip objects
		$zip = new ZipArchive();
		$zip->open($zipFile, ZIPARCHIVE::CREATE);

		// The file iterator
		$files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($folder), RecursiveIteratorIterator::LEAVES_ONLY);
		foreach ($files as $file) {
			// Get real path for current file
			$filePath = $file->getRealPath();
			$fileName = str_replace($this->extensionRoot . '/', '', $filePath);
			$fileName = str_replace(dirname($this->extensionRoot) . '/build', '', $fileName);

			// Handling top level resources directory special as it can be that vendor has resources too
			$segments = explode('/', $fileName);
			if (count($segments) > 1 && $segments[1] == 'resources') {
				continue;
			}

			// Check if the file should be ignored
			$ignore = false;
			foreach ($excludes as $exclude) {
				if (stripos($fileName, $exclude) !== false) {
					$ignore = true;
					break;
				}
			}

			// Also ignore directories
			if ($ignore || is_dir($filePath) || !$fileName) {
				continue;
			}

			// Doe the substitution
			if (key_exists($fileName, $substitutes)) {
				$fileName = $substitutes[$fileName];
			}

			// Remove trailing slashes
			$fileName = trim($fileName, '/');

			// Remove the main extension name so the files are all in the main folder
			$baseName = basename($folder) . '/';
			if (strpos($fileName, $baseName) === 0) {
				$fileName = str_replace($baseName, '', $fileName);
			}

			// Add current file to archive
			$zip->addFile($filePath, $fileName);
		}

		// Close the zip file
		$zip->close();
	}
}

// Instantiate and run the app
$build				  = new DPDockerReleaseBuild();
$build->extensionRoot = $argv[1];
$build->build();
