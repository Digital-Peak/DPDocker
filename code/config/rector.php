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
use Rector\TypeDeclaration\Rector\StmtsAwareInterface\SafeDeclareStrictTypesRector;
use Rector\ValueObject\PhpVersion;

$config = RectorConfig::configure()
	// Min version
	->withPhpVersion(PhpVersion::PHP_81)
	->withPhpSets(php81: true)
	// Complete sets with rules
	->withPreparedSets(
		deadCode: true,
		codeQuality: true,
		codingStyle: true,
		typeDeclarations: true,
		privatization: true
	)
	// Tabs for indentation
	->withIndent("\t", 1)
	// Skip some rules and folders/files
	->withSkip([
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
		// Multiuse should be allowed in component classes
		SeparateMultiUseImportsRector::class => ['*Component.php'],
		// Do not add strict types
		SafeDeclareStrictTypesRector::class,

		// Ignore not project files
		'*/vendor/*',
		'*/AcceptanceTesterActions.php',
		'*/deleted.php'
	])
	// The bootstrap file, which finds the core classes and loads the extension namespace
	->withBootstrapFiles([__DIR__ . '/joomla-bootstrap.php'])
	// Do not overload the system
	->withParallel(120, 2, 2);

// The cache directory, only when the temp dir exists
if (is_dir('/tmp/rector')) {
	$cacheDir = '/tmp/rector/' . getenv('DPDOCKER_EXTENSION_NAME');
	if (!is_dir($cacheDir)) {
		mkdir($cacheDir);
	}

	$config->withCache($cacheDir);
}

return $config;
