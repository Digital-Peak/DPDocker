<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2024 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

declare(strict_types=1);

use Rector\CodeQuality\Rector\LogicalAnd\LogicalToBooleanRector;
use Rector\CodingStyle\Rector\PostInc\PostIncDecToPreIncDecRector;
use Rector\CodingStyle\Rector\Stmt\NewlineAfterStatementRector;
use Rector\Config\RectorConfig;
use Rector\Core\ValueObject\PhpVersion;
use Rector\DeadCode\Rector\ClassMethod\RemoveUnusedPrivateMethodRector;
use Rector\DeadCode\Rector\ClassMethod\RemoveUselessParamTagRector;
use Rector\DeadCode\Rector\ClassMethod\RemoveUselessReturnTagRector;
use Rector\DeadCode\Rector\If_\UnwrapFutureCompatibleIfPhpVersionRector;
use Rector\DeadCode\Rector\StaticCall\RemoveParentCallWithoutParentRector;
use Rector\EarlyReturn\Rector\If_\ChangeOrIfContinueToMultiContinueRector;
use Rector\EarlyReturn\Rector\Return_\PreparedValueToEarlyReturnRector;
use Rector\Privatization\Rector\Class_\FinalizeClassesWithoutChildrenRector;
use Rector\Set\ValueObject\LevelSetList;
use Rector\Set\ValueObject\SetList;

return static function (RectorConfig $rectorConfig) : void {
	// Min version
	$rectorConfig->phpVersion(PhpVersion::PHP_74);

	// No short class import
	$rectorConfig->importShortClasses(false);

	// Tabs for indentation
	$rectorConfig->indent('	', 1);

	// Complete sets with rules
	$rectorConfig->sets([
		SetList::CODE_QUALITY,
		SetList::CODING_STYLE,
		SetList::DEAD_CODE,
		SetList::EARLY_RETURN,
		SetList::INSTANCEOF,
		// SetList::NAMING,
		SetList::PRIVATIZATION,
		SetList::STRICT_BOOLEANS,
		SetList::TYPE_DECLARATION,
		LevelSetList::UP_TO_PHP_74
	]);

	// Skip some rules and folders/files
	$rectorConfig->skip([
		// Keep Joomla version compare
		UnwrapFutureCompatibleIfPhpVersionRector::class,
		// Keep docs
		RemoveUselessParamTagRector::class,
		RemoveUselessReturnTagRector::class,
		// Keep <?php } ? on same line
		NewlineAfterStatementRector::class,
		// Functions are needed which belong to
		RemoveUnusedPrivateMethodRector::class,
		// Internal base classes are not detected correctly
		FinalizeClassesWithoutChildrenRector::class,
		RemoveParentCallWithoutParentRector::class,
		// Keep the or in JEXEC
		LogicalToBooleanRector::class,
		// Fixing early return is too dangerous with missing classes
		PreparedValueToEarlyReturnRector::class,
		// Post inc
		PostIncDecToPreIncDecRector::class,
		// No splitting if with ||
		ChangeOrIfContinueToMultiContinueRector::class,

		// Ignore not project files
		'*/vendor',
		'*/AcceptanceTesterActions.php',
		'*/deleted.php'
	]);
};
