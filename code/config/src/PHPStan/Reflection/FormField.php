<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2024 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

namespace DigitalPeak\DPDocker\Code\PHPStan\Reflection;

use Joomla\CMS\Form\FormField as CMSFormField;
use PHPStan\Reflection\ClassReflection;
use PHPStan\Reflection\PropertiesClassReflectionExtension;
use PHPStan\Reflection\PropertyReflection;

class FormField implements PropertiesClassReflectionExtension
{
	public function hasProperty(ClassReflection $classReflection, string $propertyName): bool
	{
		if (!$classReflection->is(CMSFormField::class)) {
			return false;
		}

		return $classReflection->hasNativeProperty($propertyName);
	}

	public function getProperty(ClassReflection $classReflection, string $propertyName): PropertyReflection
	{
		return new FormFieldProperty($classReflection, $propertyName);
	}
}
