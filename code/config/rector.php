<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2024 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

declare(strict_types=1);

use Rector\CodeQuality\Rector\LogicalAnd\LogicalToBooleanRector;
use Rector\CodingStyle\Rector\Stmt\NewlineAfterStatementRector;
use Rector\CodingStyle\Rector\Use_\SeparateMultiUseImportsRector;
use Rector\Config\RectorConfig;
use Rector\DeadCode\Rector\ClassMethod\RemoveUnusedPrivateMethodRector;
use Rector\DeadCode\Rector\ClassMethod\RemoveUselessParamTagRector;
use Rector\DeadCode\Rector\ClassMethod\RemoveUselessReturnTagRector;
use Rector\DeadCode\Rector\If_\UnwrapFutureCompatibleIfPhpVersionRector;
use Rector\DeadCode\Rector\StaticCall\RemoveParentCallWithoutParentRector;
use Rector\EarlyReturn\Rector\If_\ChangeOrIfContinueToMultiContinueRector;
use Rector\Set\ValueObject\LevelSetList;
use Rector\Set\ValueObject\SetList;
use Rector\ValueObject\PhpVersion;

return static function (RectorConfig $rectorConfig): void {
	// Min version
	$rectorConfig->phpVersion(PhpVersion::PHP_81);

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
		LevelSetList::UP_TO_PHP_81
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
		// Do not remove methods and properties
		RemoveUnusedPrivateMethodRector::class,
		// Stay safe and do not remove code
		RemoveParentCallWithoutParentRector::class,
		// Keep the or in JEXEC
		LogicalToBooleanRector::class,
		// No splitting if with ||
		ChangeOrIfContinueToMultiContinueRector::class,
		// Multiuse should be allowed in component classes
		SeparateMultiUseImportsRector::class => ['*Component.php'],

		// Ignore not project files
		'*/vendor/*',
		'*/AcceptanceTesterActions.php',
		'*/deleted.php'
	]);

	// The bootstrap file, which finds the core classes and loads the extension namespace
	$rectorConfig->bootstrapFiles([__DIR__ . '/joomla-bootstrap.php']);

	// Do not overload the system
	$rectorConfig->parallel(120, 2, 2);

	// Check if the temp dir exists
	if (!is_dir('/tmp/rector')){
		return;
	}

	// The cache directory
	if (!is_dir('/tmp/rector/' . getenv('DPDOCKER_EXTENSION_NAME'))) {
		mkdir('/tmp/rector/' . getenv('DPDOCKER_EXTENSION_NAME'));
	}
	$rectorConfig->cacheDirectory('/tmp/rector/' . getenv('DPDOCKER_EXTENSION_NAME'));
};
