const { defineConfig } = require('cypress');
const setupPlugins = require('./tests/System/plugins/index');

module.exports = defineConfig({
	fixturesFolder: 'tests/System/fixtures',
	videosFolder: 'tests/System/output/videos',
	screenshotsFolder: 'tests/System/output/screenshots',
	viewportHeight: 1000,
	viewportWidth: 1200,
	e2e: {
		setupNodeEvents(on, config) {
			setupPlugins(on, config);
		},
		specPattern: [
			'tests/System/integration/install/*.cy.{js,jsx,ts,tsx}',
			'tests/System/integration/administrator/**/*.cy.{js,jsx,ts,tsx}',
			'tests/System/integration/site/**/*.cy.{js,jsx,ts,tsx}',
			'tests/System/integration/api/**/*.cy.{js,jsx,ts,tsx}',
			'tests/System/integration/plugins/**/*.cy.{js,jsx,ts,tsx}'
		],
		supportFile: 'tests/System/support/index.js',
		scrollBehavior: 'center',
		browser: 'firefox',
		screenshotOnRunFailure: true,
		video: false
	},
	env: {
		sitename: 'Joomla CMS Test',
		name: 'Admin',
		email: 'admin@example.com',
		username: 'admin',
		password: 'admin',
		db_type: '{DBTYPE}',
		db_host: '{DB}',
		db_name: 'joomla_{SITE}',
		db_user: 'root',
		db_password: 'root',
		db_prefix: 'j_',
		cmsPath: '.'
	},
})
