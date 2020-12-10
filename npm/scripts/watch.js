/**
 * @package   DPDocker
 * @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

const fs = require('fs');
const path = require('path');
const watch = require('node-watch');
const util = require('./util');
const build = require('./build');

// Global variables
const root = path.resolve(process.argv[2]);

// Loading the assets from the assets file of the extension
const assets = JSON.parse(fs.readFileSync(root + '/package/assets.json', 'utf8'));

console.log('Building index');

let index = [];
let filesToWatch = [];

// Load extra dev assets when available
if (assets.localDev) {
	assets.localDev.forEach(asset => filesToWatch.push(root + '/' + asset));
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
	{recursive: true},
	(type, file) => {
		if (type != 'update') {
			return;
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
