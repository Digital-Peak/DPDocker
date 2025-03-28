/**
 * @package   DPDocker
 * @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

const fs = require('fs');
const path = require('path');
const watch = require('node-watch');
const js = require('./jsbuilder');
const css = require('./cssbuilder');
const util = require('./util');
const build = require('./build');

util.findFilesRecursiveSync(path.resolve(process.argv[2] + (3 in process.argv ? '/' + process.argv[3] : '')), 'assets.json').forEach((file) => {
	// Loading the assets from the assets file of the extension
	console.log('Started watching assets from config ' + file);
	const assets = JSON.parse(fs.readFileSync(file, 'utf8'));
	if (!assets.config) {
		assets.config = {};
	}
	assets.config.moduleRoot = path.dirname(file);

	if (assets.modules) {
		js.watchAssets(path.dirname(file), assets);
		css.watchAssets(path.dirname(file), assets);

		return;
	}

	watchAssets(path.dirname(file), assets);
});

function watchAssets(root, assets) {
	console.log('Building index for ' + root);

	let index = [];
	let filesToWatch = [];

	// Load extra dev assets when available
	if (assets.localDev) {
		assets.localDev.forEach((asset) => filesToWatch.push(root + '/' + asset));
	}

	assets.local.forEach(asset => {
		if (!fs.existsSync(root + '/' + asset.src)) {
			return;
		}

		filesToWatch.push(root + '/' + asset.src);

		// If it is a single file add it to the index only
		if (!fs.lstatSync(root + '/' + asset.src).isDirectory()) {
			index[root + '/' + asset.src] = root + '/' + asset.dest;
			return;
		}

		// Traverse the directory and build the assets
		util.getFiles(root + '/' + asset.src).forEach(file => {
			// Files starting with an underscore are treated as imports and do not need to be built
			if (path.basename(file).indexOf('_') === 0) {
				return;
			}

			index[file] = file.replace(asset.src, asset.dest).replace('scss', 'css');
		});
	});

	console.log('Watching ' + root + ' for changes');
	watch(
		filesToWatch,
		{ recursive: true },
		(type, file) => {
			if (type != 'update') {
				return;
			}

			// For every App.vue there should be a plain js file
			if (file.indexOf('App.vue')) {
				// Replace the app part in the filename
				let fileName = path.basename(file).replace('App.vue', '.js').toLowerCase();

				// When there is nothing left default to default.js
				if (fileName === '.js') {
					fileName = 'default.js';
				}

				// Compile the new file path with js
				file = path.dirname(file).replace('/vue/', '/js/') + '/' + fileName;
			}

			if (index[file] == null) {
				console.log('Building the whole extension because of file: ' + file.replace(root + '/', ''));
				build.build(root, assets, false);
				return;
			}

			console.log('Transpiling the file ' + file.replace(root + '/', '') + ' to ' + index[file].replace(root + '/', ''));
			try {
				util.transpile(file, index[file], false, assets.config);
			} catch (e) {
				console.log(e.message);
			}
		}
	);
}
