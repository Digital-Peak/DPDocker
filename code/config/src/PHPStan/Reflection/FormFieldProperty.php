<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2024 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

namespace DigitalPeak\DPDocker\Code\PHPStan\Reflection;

use PHPStan\Reflection\ClassReflection;
use PHPStan\Reflection\PropertyReflection;
use PHPStan\TrinaryLogic;
use PHPStan\Type\Type;

class FormFieldProperty implements PropertyReflection
{
	public function __construct(
		private ClassReflection $classReflection,
		private string $propertyName
	) {
	}

	public function getDeclaringClass(): ClassReflection
	{
		return $this->classReflection;
	}

	public function isStatic(): bool
	{
		return false;
	}

	public function isPrivate(): bool
	{
		return false;
	}

	public function isPublic(): bool
	{
		return true;
	}

	public function getDocComment(): ?string
	{
		return '';
	}

	public function getReadableType(): Type
	{
		return $this->classReflection->getNativeProperty($this->propertyName)->getReadableType();
	}

	public function getWritableType(): Type
	{
		return $this->classReflection->getNativeProperty($this->propertyName)->getWritableType();
	}

	public function canChangeTypeAfterAssignment(): bool
	{
		return true;
	}

	public function isReadable(): bool
	{
		return true;
	}

	public function isWritable(): bool
	{
		return true;
	}

	public function isInternal(): TrinaryLogic
	{
		return $this->classReflection->getNativeProperty($this->propertyName)->isInternal();
	}

	public function isDeprecated(): TrinaryLogic
	{
		return $this->classReflection->getNativeProperty($this->propertyName)->isDeprecated();
	}

	public function getDeprecatedDescription(): ?string
	{
		return '';
	}
}
