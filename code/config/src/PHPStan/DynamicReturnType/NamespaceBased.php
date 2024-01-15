<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2024 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

namespace DigitalPeak\DPDocker\Code\PHPStan\DynamicReturnType;

use PHPStan\Type\DynamicMethodReturnTypeExtension;

abstract class NamespaceBased implements DynamicMethodReturnTypeExtension
{
	private array $namespaces = [];

	/**
	 * Returns a list of namespaces.
	 */
	protected function getNamespaces(): array
	{
		if (!$this->namespaces) {
			$this->namespaces = require dirname(__DIR__, 4) . '/tmp/administrator/cache/autoload_psr4.php';
		}

		return $this->namespaces;
	}

	/**
	 * Searches namespaces for the given name case insensitive.
	 */
	protected function findNamespaces(string $name): array
	{
		$result = [];

		foreach ($this->getNamespaces() as $ns => $path) {
			if (!stripos($ns, $name)) {
				continue;
			}

			$result[$ns] = $path;
		}

		return $result;
	}

	/**
	 * Searches a namespace for the given name case insensitive.
	 */
	protected function findNamespace(string $name): string
	{
		foreach ($this->getNamespaces() as $ns => $path) {
			if (!stripos($ns, $name)) {
				continue;
			}

			return $ns;
		}

		return '';
	}
}
