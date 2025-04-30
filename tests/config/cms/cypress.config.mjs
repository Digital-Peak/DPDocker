import { defineConfig } from 'cypress';
import setupPlugins from './tests/System/plugins/index.mjs';

export default defineConfig({
  fixturesFolder: 'tests/System/fixtures',
  videosFolder: 'tests/System/output/videos',
  screenshotsFolder: 'tests/System/output/screenshots',
  viewportHeight: 1000,
  viewportWidth: 1200,
  e2e: {
    setupNodeEvents(on, config) {
      setupPlugins(on, config);
    },
    baseUrl: 'https://localhost/',
    specPattern: [
      'tests/System/integration/install/**/*.cy.{js,jsx,ts,tsx}',
      'tests/System/integration/administrator/**/*.cy.{js,jsx,ts,tsx}',
      'tests/System/integration/site/**/*.cy.{js,jsx,ts,tsx}',
      'tests/System/integration/api/**/*.cy.{js,jsx,ts,tsx}',
      'tests/System/integration/plugins/**/*.cy.{js,jsx,ts,tsx}',
      'tests/System/integration/cli/**/*.cy.{js,jsx,ts,tsx}',
    ],
    supportFile: 'tests/System/support/index.js',
    scrollBehavior: 'center',
    browser: 'firefox',
    screenshotOnRunFailure: true,
    video: false,
	experimentalRunAllSpecs: true,
  },
  env: {
    sitename: 'Joomla CMS Test',
    name: 'Admin',
    email: 'admin@example.com',
    username: 'admin',
    password: 'admin',
    db_type: 'MySQLi',
    db_host: 'joomla',
    db_port: '',
    db_name: 'joomla_cms',
    db_user: 'root',
    db_password: 'root',
    db_prefix: 'j_',
    smtp_host: 'host.docker.internal',
    smtp_port: '8084',
    cmsPath: '.',
    logFile: '/tmp/web_logs/error.log',
  },
});
