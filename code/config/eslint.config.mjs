import js from '@eslint/js/src/index.js';
import globals from 'globals/index.js';

export default [
	js.configs.recommended,
	{
		rules: {
			'space-infix-ops': 1,
			'space-before-blocks': 1,
			'keyword-spacing': 1,
			'comma-spacing': 1,
			'curly': 1,
			indent: ['error', 'tab', { 'SwitchCase': 1 }],
			'linebreak-style': ['error', 'unix'],
			quotes: ['error', 'single'],
			semi: ['error', 'always']
		},
		languageOptions: {
			ecmaVersion: 2021,
			sourceType: 'module',
			globals: {
				...globals.browser,
				'Joomla': true
			}
		}
	},
	{
		ignores: ['**/media/**', '**/node_modules/**']
	}
];
