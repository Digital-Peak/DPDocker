// The needed libs
const fs = require('fs');
const path = require('path');
const sass = require('node-sass');
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
		// If it is a single asset transpile it directly
		if (!fs.lstatSync(root + '/' + asset.src).isDirectory()) {
			util.transpile(root + '/' + asset.src, root + '/' + asset.dest, false);
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
			util.transpile(file, file.replace(asset.src, asset.dest).replace('scss', 'css'), false);
		});
	});

	// Check if the vendor dir needs to be built as well
	if (!includeVendor) {
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
			if (index == 0) {
				fs.copyFileSync(file, root + '/' + asset.dest);
				return;
			}

			// Append to the existing file
			fs.appendFileSync(root + '/' + asset.dest, fs.readFileSync(file));
		});

		// If defined, replace in the asset copy some content
		if (asset.replace) {
			// Loop over the assets replace array
			asset.replace.forEach(def => {
				// The file content
				let content = fs.readFileSync(root + '/' + asset.dest, 'utf8');

				// Perform the search and replace
				content = content.replace(def.search, def.replace);

				// Write back the replaced code
				fs.writeFileSync(root + '/' + asset.dest, content, 'utf8');
			});
		}

		// If the asset is a minified one, then create the formatted file
		if (asset.dest.indexOf('.min.css') > 0) {
			// Read the content
			let content = fs.readFileSync(root + '/' + asset.dest, 'utf8');

			// Format the minified file
			const code = sass.renderSync({data: content, outputStyle: 'expanded', indentType: 'tab', indentWidth: 1}).css.toString();

			// Define the none minified file as destination
			asset.dest = asset.dest.replace('.min.css', '.css');

			// Write the formatted CSS back to the file
			fs.writeFileSync(root + '/' + asset.dest, code);
		}

		// Only transpile Javascript and CSS files
		if (path.extname(asset.dest) == '.js' || path.extname(asset.dest) == '.css') {
			util.transpile(root + '/' + asset.dest, root + '/' + asset.dest, true);
		}
	});
}

module.exports = {
	build: buildAssets
}
