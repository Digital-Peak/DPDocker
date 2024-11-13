/**
 * @package   DPCalendar
 * @copyright Copyright (C) 2024 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

// The needed libs
const fs = require('fs');
const path = require('path');
const sass = require('sass');
const watch = require('node-watch');
const util = require('./util');

async function buildAsset(root, asset, config) {
	// Traverse the directory and build the assets
	util.getFiles(root + '/' + asset.src).forEach((file) => {
		// Files starting with an underscore are treated as imports and do not need to be built
		if (path.basename(file).indexOf('_') === 0 || file.indexOf('.js') !== -1) {
			return;
		}

		// The destination
		let destination = file.replace(asset.src, asset.dest).replace('scss', 'css');

		// For the build task, make it minified
		if (process.argv[1].indexOf('build.js') > 0) {
			destination = destination.replace('.css', '.min.css');
		}

		// Transpile the file
		transpile(file, destination, config);
	});
};

function watchAssets(root, assets) {
	console.log('Building index for ' + root);

	let index = [];
	let filesToWatch = [];

	// Load extra dev assets when available
	if (assets.localDev) {
		assets.localDev.forEach((asset) => filesToWatch.push(root + '/' + asset));
	}

	assets.local.forEach((asset) => {
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
			if (path.basename(file).indexOf('_') === 0 || file.indexOf('.js') !== -1) {
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
			if (type != 'update' || file.indexOf('.js') !== -1) {
				return;
			}

			if (index[file] == null) {
				console.log('Building the whole extension because of file: ' + file.replace(root + '/', ''));
				assets.local.forEach((asset) => buildAsset(root, asset, assets.config));
				return;
			}

			console.log('Transpiling the file ' + file.replace(root + '/', '') + ' to ' + index[file].replace(root + '/', ''));
			try {
				transpile(file, index[file], assets.config);
			} catch (e) {
				console.log(e.message);
			}
		}
	);
}

/**
 * Transpile function which can handle Javascript, SASS and CSS files.
 *
 * @param string source The full path of the source file
 * @param string destination The full path of the destination file
 * @param object config Some configuration options
 */
function transpile(source, destination, config) {
	// Ensure that the target directory exists
	if (!fs.existsSync(path.dirname(destination))) {
		fs.mkdirSync(path.dirname(destination), { recursive: true });
	}

	// Transpile the files
	switch (path.extname(source).replace('.', '')) {
		case 'scss':
		case 'css':
			// Define the content and file path, based on the extension of the destination
			if (destination.indexOf('.min.css') > -1) {
				const result = sass.compile(source, {
					outFile: destination,
					style: 'compressed',
					loadPaths: [config.moduleRoot + '/node_modules'],
					quietDeps: true,
					silenceDeprecations: ['import']
				});

				// Write the minified content to the file
				fs.writeFileSync(destination, (config.docBlock ? config.docBlock + '\n' : '') + result.css.toString().trim());
				return;
			}

			// Compile sass files
			const result = sass.compile(source, {
				outFile: destination,
				style: 'expanded',
				indentType: 'tab',
				indentWidth: 1,
				sourceMap: true,
				loadPaths: [config.moduleRoot + '/node_modules'],
				quietDeps: true,
				silenceDeprecations: ['import']
			});

			// Normalize the extension
			destination = destination.replace('.css', '.min.css');

			// Write the map content to the destination file with the adjusted paths
			const mapRoot = destination.substring(0, destination.indexOf('/resources') + 1);
			const segments = destination.substring(destination.indexOf('/media')).split('/');
			fs.writeFileSync(destination + '.map', JSON.stringify(result.sourceMap).replaceAll('file://' + mapRoot, '../'.repeat(segments.length - 2)));

			// Write the content to the destination file with the source mapping
			fs.writeFileSync(destination, result.css.toString().trim() + '\n/*# sourceMappingURL=' + path.basename(destination) + '.map */');
	}
}

module.exports = {
	buildAsset: buildAsset,
	watchAssets: watchAssets,
	transpile: transpile
}
