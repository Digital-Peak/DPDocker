/**
 * @package   DPCalendar
 * @copyright Copyright (C) 2024 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

// The needed libs
const path = require('path');
const rollup = require('rollup');
const resolve = require('@rollup/plugin-node-resolve');
const replace = require('@rollup/plugin-replace');
const terser = require('@rollup/plugin-terser');
const json = require('@rollup/plugin-json');
const svg = require('rollup-plugin-svg');
const vue = require('rollup-plugin-vue');
const license = require('rollup-plugin-license');
const css = require('rollup-plugin-import-css');
const urlresolve = require('rollup-plugin-url-resolve');
const MapGenerator = require('magic-string');
const util = require('./util');

async function buildAsset(root, asset, config) {
	try {
		const rollupConfig = getConfig(root, asset, config);
		if (Object.keys(rollupConfig.input).length === 0) {
			return;
		}

		if (process.argv[1].indexOf('watch.js') > 0) {
			// Use source maps
			rollupConfig.output.sourcemap = true;
		}

		if (process.argv[1].indexOf('build.js') > 0) {
			// Compress and remove debug and comments
			rollupConfig.plugins.push(terser({
				module: true,
				compress: {
					drop_console: true,
					drop_debugger: true,
				},
				format: { comments: false }
			}));

			// Add the license header
			rollupConfig.plugins.push(license({ banner: { content: config.docBlock } }));
		}

		// Create the rollup instance
		const bundle = await rollup.rollup(rollupConfig);

		// Generate code
		await bundle.write(rollupConfig.output);
	} catch (e) {
		console.log(e);
	}
};

async function watchAssets(root, assets) {
	assets.local.forEach(async (asset) => {
		const rollupConfig = getConfig(root, asset, assets.config);
		if (Object.keys(rollupConfig.input).length === 0) {
			return;
		}

		// Delete the directory
		util.deleteDirectory(root + '/' + asset.dest);

		try {
			// Use source maps
			rollupConfig.output.sourcemap = true;

			// Watch the files
			const bundle = await rollup.watch(rollupConfig);

			bundle.on('event', (event) => {
				switch (event.code) {
					case 'START':
						startBundleTime = Date.now();
						break;
					case 'BUNDLE_START':
						console.log(`Started to create the following bundles to ${event.output}:\n  - ${Object.values(event.input).join('\n  - ').replaceAll(root, '')}`);
						break;
					case 'BUNDLE_END':
						console.log(`Finished to create bundles ${Array.isArray(event.output) ? event.output.join(',') : event.output} in ${Date.now() - startBundleTime}ms`);
						break;
					case 'END':
						console.log('Waiting for changes');
						break;
					case 'ERROR':
						event.error.watchFiles=[];
						console.log(event.error);
						break;
					default:
						console.log(event);
						break;
				}
			});
		} catch (e) {
			console.log(e);
		}
	});
}

function getConfig(root, asset, config) {
	// Traverse the directory and build the assets
	const files = {};
	util.getFiles(root + '/' + asset.src).forEach((file) => {
		// Files starting with an underscore are treated as imports and do not need to be built
		if (path.basename(file).indexOf('_') === 0 || file.indexOf('.js') === -1) {
			return;
		}

		files[file.replace(root + '/js/', '').replace('.js', '')] = file;
	});

	const includes = ['node_modules'];
	if (config.includes) {
		includes.push(...config.includes);
	}

	includes.forEach((include, index) => includes[index] = config.moduleRoot + '/' + include);

	// Create the hash from the current timestamp minus the timestamp from 1.1.2024 to make it a bit shorter
	const hash = Math.floor(Date.now() / 1000) - 1704070800;
	return {
		input: files,
		output: {
			dir: root + '/' + asset.dest,
			format: 'es',
			entryFileNames: '[name].min.js',
			chunkFileNames: (chunkInfo) => {
				// The path segments
				const segments = (chunkInfo.facadeModuleId ?? chunkInfo.moduleIds[chunkInfo.moduleIds.length-1]).split('/');

				let fileName = chunkInfo.name.replace('.min', '').replace('.esm', '');
				if (segments[segments.length - 1].endsWith('.css')) {
					fileName += '.css';
				}
				fileName += '.min.js';

				// Special handling for libs
				if (segments.indexOf('node_modules') !== -1) {
					// The root libraries name
					let name = 'vendor/';

					// Add the package name and module
					name += segments.splice(segments.findIndex((p) => p === 'node_modules') + 1, 2).join('/').replace('@', '');

					// Normalize the filename
					name += '/' + fileName;

					return name;
				}

				// Get the module folder
				const name = segments.at(-2);

				// Return the internal modules with package name as subpath
				return 'modules/' + (name !== 'js-modules' ? name + '/' : '') + fileName;
			}
		},
		plugins: [
			replace({
				preventAssignment: true,
				values: {
					'process.env.NODE_ENV': JSON.stringify('development'),
					'process.env.VUE_ENV': JSON.stringify('browser')
				}
			}),
			resolve.nodeResolve({ modulePaths: includes}),
			urlresolve(),
			svg(),
			vue(),
			json(),
			css({ modules: true }),
			{
				name: 'dp-cache',
				renderChunk(code) {
					// Append hash to the imported files for busting
					let transformed = code.replaceAll('.min.js', '.min.js?' + hash);

					// Directly append the css to the browser with polyfill
					if (transformed.endsWith('export { sheet as default };')) {
						transformed = transformed.replace('export { sheet as default };', 'if(document.adoptedStyleSheets)document.adoptedStyleSheets.push(sheet);else{var styleString="";for(let e=0;e<sheet.cssRules.length;e++)styleString=styleString.concat(sheet.cssRules[e].cssText);var style=document.createElement("style");style.type="text/css",style.innerHTML=styleString,document.getElementsByTagName("head")[0].appendChild(style)}');
					}

					return {
						code: transformed,
						map: new MapGenerator(transformed).generateMap().toString()
					};
				}
			}
		],
		context: 'window',
		onwarn: function ( message ) {
			// As maintainers refuse to remove the circular dependency https://github.com/d3/d3-interpolate/issues/58
			if ( /Circular dependency.*d3-interpolate/.test(message) ) {
			  return
			}
		  },
	};
}

module.exports = {
	buildAsset: buildAsset,
	watchAssets: watchAssets
}
