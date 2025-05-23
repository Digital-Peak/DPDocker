/**
 * @package   DPDocker
 * @copyright Copyright (C) 2020 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

// The needed libs
const fs = require('fs');
const path = require('path');
const js = require('./jsbuilder');
const css = require('./cssbuilder');
const util = require('./util');

util.findFilesRecursiveSync(path.resolve(process.argv[2] + (3 in process.argv ? '/' + process.argv[3] : '')), 'assets.json').forEach((file) => {
	// Loading the assets from the assets file of the extension
	console.log('Started building assets from config ' + file);

	const assets = JSON.parse(fs.readFileSync(file, 'utf8'));
	if (!assets.config) {
		assets.config = {};
	}
	assets.config.moduleRoot = path.dirname(file);
	buildAssets(path.dirname(file), assets).then(() => console.log('Finished building assets from config ' + file));
});

async function buildAssets(root, assets) {
	const promises = [];

	// Looping over the assets
	assets.local.forEach(async (asset) => {
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

		if (assets.modules) {
			// Build the JS asset
			promises.push(js.buildAsset(root, asset, assets.config));

			// Build the style asset
			promises.push(css.buildAsset(root, asset, assets.config));

			return;
		}

		// Traverse the directory and build the assets
		util.getFiles(root + '/' + asset.src).forEach((file) => {
			// Files starting with an underscore are treated as imports and do not need to be built
			if (path.basename(file).indexOf('_') === 0) {
				return;
			}

			// Transpile the file
			util.transpile(file, file.replace(asset.src, asset.dest).replace('scss', 'css'), false, assets.config);
		});
	});

	await Promise.all(promises);

	// Check if the vendor dir needs to be built as well
	if (!assets.vendor) {
		return;
	}

	// Loop over the vendor assets
	for (let i = 0; i < assets.vendor.length; i++) {
		const asset = assets.vendor[i];

		// Make sure that the destination folder exists
		let dir = path.extname(asset.dest) ? path.dirname(root + '/' + asset.dest) : root + '/' + asset.dest;
		if (!fs.existsSync(dir)) {
			fs.mkdirSync(dir, { recursive: true });
		}

		// Ensure that the source assets is an array
		if (!Array.isArray(asset.src)) {
			asset.src = [asset.src];
		}

		// Loop over the source assets and combine them into a single file
		for (let index = 0; index < asset.src.length; index++) {
			const source = asset.src[index];

			// Determine file name
			let file = root + '/node_modules/' + source;
			if (source.indexOf('https://') === -1) {
				if (!fs.existsSync(file)) {
					file = root + '/' + source;
				}

				// On the first entry write the file
				if (index == 0 && fs.statSync(file).isFile()) {
					copyFileSync(file, root + '/' + asset.dest);
					continue;
				}

				if (index === 0) {
					copyFolderRecursiveSync(file, root + '/' + asset.dest);
					continue;
				}
			}

			// If the destination is a folder just copy the file there
			if (!path.extname(asset.dest)) {
				copyFileSync(file, root + '/' + asset.dest);
				continue;
			}

			if (asset.binary === undefined) {
				asset.binary = false;
			}

			let content = '';
			if (source.indexOf('https://') === 0 && !asset.binary) {
				content = await fetch(source).then((res) => res.text());

			}
			if (source.indexOf('https://') === 0 && asset.binary) {
				content = await fetch(source).then((res) => res.arrayBuffer()).then((array) => Buffer.from(array));
			}

			if (source.indexOf('https://') !== 0 && !asset.binary) {
				content = '\n' + fs.readFileSync(file, 'utf8');
			}
			if (source.indexOf('https://') !== 0 && asset.binary) {
				content = fs.readFileSync(file, 'utf8');
			}

			if (index == 0) {
				fs.writeFileSync(root + '/' + asset.dest, content);
				continue;
			}

			// Append to the existing file
			fs.appendFileSync(root + '/' + asset.dest, content);
		};

		// If defined, replace in the asset copy some content
		if (asset.replace) {
			// Loop over the assets replace array
			asset.replace.forEach((def) => {
				const replace = (def, file) => {
					// The file content
					let content = fs.readFileSync(file, 'utf8');

					// Perform the search and replace
					content = content.replace(def.search, def.replace);
					content = content.replace(new RegExp(def.search, 'g'), def.replace);

					// Write back the replaced code
					fs.writeFileSync(file, content, 'utf8');
				};

				if (fs.lstatSync(root + '/' + asset.dest).isDirectory()) {
					fs.readdirSync(root + '/' + asset.dest).forEach((file) => replace(def, root + '/' + asset.dest + '/' + file));
					return;
				}

				replace(def, root + '/' + asset.dest);
			});
		}

		// If defined, append in the asset copy
		if (asset.append) {
			// Loop over the assets replace array
			asset.append.forEach((def) => {
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
			continue;
		}

		// Only transpile Javascript and CSS files
		if (path.extname(asset.dest) == '.js' || path.extname(asset.dest) == '.css') {
			util.transpile(root + '/' + asset.dest, root + '/' + asset.dest, true, assets.config);
		}

		if (asset.onlyMinified === true) {
			fs.unlinkSync(root + '/' + asset.dest);
		}
	};
}

function copyFileSync(source, target) {
	let targetFile = target;

	// If target is a directory, a new file with the same name will be created
	if (fs.existsSync(target) && fs.lstatSync(target).isDirectory()) {
		targetFile = path.join(target, path.basename(source));
	}

	fs.copyFileSync(source, targetFile);
}

function copyFolderRecursiveSync(source, target) {
	if (!fs.existsSync(target)) {
		fs.mkdirSync(target);
	}

	// Copy
	if (!fs.lstatSync(source).isDirectory()) {
		return;
	}

	fs.readdirSync(source).forEach((file) => {
		const currentSource = path.join(source, file);
		if (fs.lstatSync(currentSource).isDirectory()) {
			copyFolderRecursiveSync(currentSource, path.join(target, file));
			return;
		}

		copyFileSync(currentSource, target);
	});
}
