/**
 * @package   DPDocker
 * @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

// The needed libs
const fs = require('fs');
const path = require('path');
const request = require('sync-request');
const util = require('./util');

// Global variables
const root = path.resolve(process.argv[2]);

if (!fs.existsSync(root + '/package/assets.json')) {
	console.log('Nothing to build as ' + root + '/package/assets.json not found');
	return;
}

// Loading the assets from the assets file of the extension
const assets = JSON.parse(fs.readFileSync(root + '/package/assets.json', 'utf8'));

buildAssets(root, assets, 3 in process.argv);

function buildAssets(root, assets, includeVendor)
{
	// Looping over the assets
	console.log('Started to build the assets for ' + root);
	assets.local.forEach(asset => {
		if (!fs.existsSync(root + '/' + asset.src)) {
			return;
		}

		// If it is a single asset transpile it directly
		if (!fs.lstatSync(root + '/' + asset.src).isDirectory()) {
			util.transpile(root + '/' + asset.src, root + '/' + asset.dest, false, assets.config);
			return;
		}

		// Delete the assets directory first
		util.deleteDirectory(root + '/' + asset.dest);

		// Traverse the directory and build the assets
		util.getFiles(root + '/' + asset.src).forEach(file => {
			// Files starting with an underscore are treated as imports and do not need to be built
			if (path.basename(file).indexOf('_') === 0) {
				return;
			}

			// Transpile the file
			util.transpile(file, file.replace(asset.src, asset.dest).replace('scss', 'css'), false, assets.config);
		});
	});

	// Check if the vendor dir needs to be built as well
	if (!includeVendor || !assets.vendor) {
		return;
	}

	// Loop over the vendor assets
	console.log('Started to build the vendor assets for ' + root);
	assets.vendor.forEach(asset => {
		// Make sure that the destination folder exists
		let dir = path.dirname(root + '/' + asset.dest);
		if (!fs.existsSync(dir)) {
			fs.mkdirSync(dir, {recursive: true});
		}

		// Ensure that the source assets is an array
		if (!Array.isArray(asset.src)) {
			asset.src = [asset.src];
		}

		// Loop over the source assets and combine them into a single file
		asset.src.forEach((source, index) => {
			// Determine file name
			let file = root + '/package/node_modules/' + source;
			if (!fs.existsSync(file)) {
				file = root + '/' + source;
			}

			// On the first entry write the file
			if (index == 0 && fs.statSync(file).isFile()) {
				fs.copyFileSync(file, root + '/' + asset.dest);
				return;
			}

			if (index == 0) {
				copyFolderRecursiveSync(file, root + '/' + asset.dest);
				return;
			}

			let content = '';
			if (source.indexOf('https://') === 0) {
				content = '' + request('GET', source).getBody();
			} else {
				content = fs.readFileSync(file, 'utf8');
			}

			// Append to the existing file
			fs.appendFileSync(root + '/' + asset.dest, '\n' + content);
		});

		// If defined, replace in the asset copy some content
		if (asset.replace) {
			// Loop over the assets replace array
			asset.replace.forEach(def => {
				// The file content
				let content = fs.readFileSync(root + '/' + asset.dest, 'utf8');

				// Perform the search and replace
				content = content.replace(def.search, def.replace);
				content = content.replace(new RegExp(def.search, 'g'), def.replace);

				// Write back the replaced code
				fs.writeFileSync(root + '/' + asset.dest, content, 'utf8');
			});
		}

		// If defined, append in the asset copy
		if (asset.append) {
			// Loop over the assets replace array
			asset.append.forEach(def => {
				// Append to the existing file
				fs.appendFileSync(root + '/' + asset.dest, '\n' + def);
			});
		}

		// If the asset is a minified one, ignore
		if (asset.dest.indexOf('.min.css') > 0 || asset.dest.indexOf('.min.js') > 0) {
			const data = fs.readFileSync(root + '/' + asset.dest, 'utf8');
			fs.writeFileSync(
				root + '/' + asset.dest,
				data.replace(/\/\/# sourceMappingURL=(.+?\.map)/g, ''),
				'utf8'
			);
			return;
		}

		// Only transpile Javascript and CSS files
		if (path.extname(asset.dest) == '.js' || path.extname(asset.dest) == '.css') {
			util.transpile(root + '/' + asset.dest, root + '/' + asset.dest, true, assets.config);
		}

		if (asset.onlyMinified === true) {
			fs.unlinkSync(root + '/' + asset.dest);
		}
	});
}

function copyFileSync(source, target)
{
	let targetFile = target;

	// If target is a directory, a new file with the same name will be created
	if (fs.existsSync(target) && fs.lstatSync(target).isDirectory()) {
		targetFile = path.join(target, path.basename(source));
	}

	fs.writeFileSync(targetFile, fs.readFileSync(source, 'utf8'));
}

function copyFolderRecursiveSync(source, target)
{
	// Check if folder needs to be created or integrated
	const targetFolder = path.join(target, path.basename(source));
	if (!fs.existsSync(targetFolder)) {
		fs.mkdirSync(targetFolder);
	}

	// Copy
	if (!fs.lstatSync(source).isDirectory()) {
		return;
	}

	const files = fs.readdirSync(source);
	files.forEach((file) => {
		const curSource = path.join(source, file);
		if (fs.lstatSync(curSource).isDirectory()) {
			copyFolderRecursiveSync(curSource, targetFolder);
			return;
		}

		copyFileSync(curSource, targetFolder);
	});
}

module.exports = {
	build: buildAssets
}
