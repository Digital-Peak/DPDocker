import js from '@eslint/js/src/index.js';
import globals from 'globals/index.js';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default [{
	files: ['**/*.js'],
	ignores: ['**/media/**', '**/node_modules/**', 'plg_dpcalendar_spreadsheet/vendor/**/*.js'],
	rules: {
		...js.configs.recommended.rules,
		indent: [
			'error',
			'tab',
			{ 'SwitchCase': 1 }
		],
		'linebreak-style': [
			'error',
			'unix'
		],
		quotes: [
			'error',
			'single'
		],
		semi: [
			'error',
			'always'
		]
	},
	languageOptions: {
		ecmaVersion: 2021,
		sourceType: 'script',
		globals: {
			...globals.browser,
			'Joomla': true,
			'Stripe': true,
			'braintree': true,
			'JitsiMeetExternalAPI': true,
			'DPCalendar': true,
			'loadDPAssets': true,
			'jQuery': true,
			'dayjs': true,
			'ZoomMtg': true,
			'RSFormProUtils': true,
			'tippy': true,
			'Pikaday': true,
			'Popper': true,
			'Url': true,
			'tingle': true,
			'L': true,
			'm': true,
			'google': true,
			'FullCalendar': true,
			'iFrameResize': true
		},
	}
}];
