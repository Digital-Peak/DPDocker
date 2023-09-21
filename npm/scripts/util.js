/**
 * @package   DPCalendar
 * @copyright Copyright (C) 2017 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

// The needed libs
const fs = require('fs');
const path = require('path');
const terser = require('terser');
const sass = require('sass');
const babel = require('@babel/core');
const rollup = require('rollup');
const strip = require('js-cleanup');
const resolve = require('@rollup/plugin-node-resolve');
const replace = require('@rollup/plugin-replace');
const svg = require('rollup-plugin-svg');
const vue = require('rollup-plugin-vue');
const css = require('rollup-plugin-import-css');

/**
 * Transpile function which can handle Javascript, SASS and CSS files.
 *
 * @param string source The full path of the source file
 * @param string destination The full path of the destination file
 * @param string isVendor If the file is a vendor file and doesn't need some extra bundling
 * @param object config Some configuration options
 */
function transpile(source, destination, isVendor, config) {
	// Ensure that the target directory exists
	if (!fs.existsSync(path.dirname(destination))) {
		fs.mkdirSync(path.dirname(destination), { recursive: true });
	}

	if (!config.compatibility) {
		config.compatibility = [',> 0.25%, not dead', 'safari >= 9', 'ios >= 9', 'not ie 11', 'not op_mini all'];
	}

	// Transpile the files
	switch (path.extname(source).replace('.', '')) {
		case 'js':
			const babelify = async (file, full) => {
				// Transform the content to ensure we support the required browsers
				let result = babel.transformSync(fs.readFileSync(file, 'utf8'), {
					sourceMaps: true,
					compact: false,
					presets: [['@babel/preset-env', { 'targets': { 'browsers': config.compatibility }, 'modules': false }]]
				});

				if (full) {
					// Write the none minified content to the destination file
					fs.writeFileSync(destination, result.code);

					// Write the map content to the destination file
					fs.writeFileSync(destination + '.map', JSON.stringify(result.map));
				}

				let minified = await terser.minify(result.code);
				if (minified.error) {
					console.log(minified.error);
					return
				}

				// Write the minified content to the destination file
				fs.writeFileSync(destination.replace('.js', '.min.js'), minified.code);
			};

			(async () => {
				// Bundle only when it is an extension file
				if (isVendor) {
					babelify(source, true);
					return;
				}

				try {
					const bundle = await rollup.rollup({
						input: source,
						plugins: [
							replace({
								preventAssignment: true,
								values: {
									'process.env.NODE_ENV': JSON.stringify('development'),
									'process.env.VUE_ENV': JSON.stringify('browser')
								}
							}),
							resolve.nodeResolve({ modulePaths: [config.moduleRoot + '/node_modules'] }),
							svg(),
							vue(),
							css()
						]
					});

					// Generate code
					await bundle.write({ file: destination, format: 'iife', sourcemap: true });

					if (config.docBlock) {
						let content = strip(fs.readFileSync(destination, 'utf8'), null, { comments: 'none', sourcemap: true });
						fs.writeFileSync(destination, config.docBlock + "\n" + content.code);
						fs.writeFileSync(destination + '.map', content.map.mappings);
					}

					babelify(destination, false);
				} catch (e) {
					console.log(e);
				}
			})();
			break;
		case 'scss':
		case 'css':
			// Compile sass files
			let result = sass.renderSync({
				file: source,
				outFile: destination,
				outputStyle: 'expanded',
				indentType: 'tab',
				indentWidth: 1,
				sourceMap: true,
				includePaths: [config.moduleRoot + '/node_modules']
			});

			// Write the none minified content to the destination file
			fs.writeFileSync(destination, result.css.toString());

			// Write the map content to the destination file
			fs.writeFileSync(destination + '.map', result.map);

			// Write the minified content to the destination file
			fs.writeFileSync(
				destination.replace('.css', '.min.css'),
				sass.renderSync({ data: result.css.toString(), outputStyle: 'compressed' }).css.toString()
			);
	}
}

/**
 * Return all files recursively of the given directory.
 *
 * @param string dir The directory to traverse
 * @returns {Array}
 */
function getFiles(dir) {
	// The results array
	let results = [];

	// Loope over the current directory files
	fs.readdirSync(dir).forEach(function (file) {
		// The file to work on
		file = dir + '/' + file;

		// The file stats
		const stat = fs.statSync(file);

		// If it is a directory, read it as well
		if (stat && stat.isDirectory()) {
			results = results.concat(getFiles(file));
		} else {
			results.push(file);
		}
	});
	return results;
}

/**
 * Deletes the given directory.
 *
 * @param string path The path to delete
 */
function deleteDirectory(path) {
	// Check if the direcory exists
	if (!fs.existsSync(path)) {
		return;
	}

	// Loop over the files of the directory
	fs.readdirSync(path).forEach(function (file) {
		// The file to work on
		const currentPath = path + '/' + file;

		// If it is a directory, delete it first
		if (fs.lstatSync(currentPath).isDirectory()) {
			deleteDirectory(currentPath);
		} else {
			fs.unlinkSync(currentPath);
		}
	});

	// Delete the top level directory
	fs.rmdirSync(path);
}

/**
 * Search for files with the given name recursive in the base.
 *
 * @param base
 * @param name
 * @param files
 * @param result
 *
 * @returns {*[]}
 */
function findFilesRecursiveSync(base, name, files, result) {
	files = files || fs.readdirSync(base);
	result = result || [];

	files.forEach(
		(file) => {
			const newbase = path.join(base, file);
			if (fs.statSync(newbase).isDirectory()) {
				result = findFilesRecursiveSync(newbase, name, fs.readdirSync(newbase), result);
				return;
			}

			if (file.indexOf(name) > -1) {
				result.push(newbase);
			}
		}
	);
	return result;
}

module.exports = {
	transpile: transpile,
	getFiles: getFiles,
	deleteDirectory: deleteDirectory,
	findFilesRecursiveSync: findFilesRecursiveSync
}
