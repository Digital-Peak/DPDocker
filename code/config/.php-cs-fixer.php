<?php
/**
 * @package   DPDocker
 * @copyright Copyright (C) 2023 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

use PhpCsFixer\Config;
use PhpCsFixer\Finder;
use PhpCsFixer\Runner\Parallel\ParallelConfigFactory;

$finder = Finder::create()
	->in(__DIR__)
	->notPath('/tmpl/')
	->notPath('/layouts/');

$config = new Config();

$config->setRules([
		'@PSR12'                          => true,
		'array_syntax'                    => ['syntax' => 'short'],
		'whitespace_after_comma_in_array' => true,
		'single_space_around_construct'   => true,
		'concat_space'                    => ['spacing' => 'one'],
		'cast_spaces'                     => ['space' => 'none'],
		'indentation_type'                => true,
		'no_break_comment'                => false,
		'no_unused_imports'               => true,
		'no_trailing_comma_in_singleline' => true,
		'ordered_imports'                 => ['imports_order' => ['class', 'function', 'const'], 'sort_algorithm' => 'alpha'],
		'binary_operator_spaces'          => [
			'default'   => 'single_space',
			'operators' => [
				'||' => 'single_space',
				'&&' => 'single_space',
				'='  => 'align_single_space_minimal',
				'+=' => 'align_single_space_minimal',
				'=>' => 'align_single_space_minimal'
			]
		],
		'no_useless_else'                                  => true,
		'nullable_type_declaration_for_default_null_value' => true,
		'global_namespace_import'                          => ['import_classes' => false, 'import_constants' => false, 'import_functions' => false],
		'fully_qualified_strict_types'                     => ['import_symbols' => true],
		'native_function_invocation'                       => true
	])
	->setUsingCache(false)
	->setIndent("\t")
	->setFinder($finder)
	->setParallelConfig(ParallelConfigFactory::detect());

return $config;
