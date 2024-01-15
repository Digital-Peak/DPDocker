<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2024 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

namespace DigitalPeak\DPDocker\Code\PHPStan\DynamicReturnType;

use Joomla\CMS\MVC\Model\BaseDatabaseModel;
use PhpParser\Node\Expr\MethodCall;
use PHPStan\Analyser\Scope;
use PHPStan\Reflection\MethodReflection;
use PHPStan\Type\ObjectType;
use PHPStan\Type\Type;

class ModelBootComponent extends NamespaceBased
{
	public function getClass(): string
	{
		return BaseDatabaseModel::class;
	}

	public function isMethodSupported(MethodReflection $methodReflection): bool
	{
		return $methodReflection->getName() === 'bootComponent';
	}

	public function getTypeFromMethodCall(MethodReflection $methodReflection, MethodCall $methodCall, Scope $scope): ?Type
	{
		if (count($methodCall->getArgs()) === 0) {
			return null;
		}

		$name = str_replace("'", '', $methodCall->getArgs()[0]->value->getAttribute('rawValue'));

		if ($namespace = $this->findNamespace('\\Component\\' . $name . '\\Administrator')) {
			return new ObjectType($namespace . 'Extension\\' . $name . 'Component');
		}

		return null;
	}
}
