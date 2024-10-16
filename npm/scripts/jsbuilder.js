/**
 * @package   DPCalendar
 * @copyright Copyright (C) 2024 Digital Peak GmbH. <https://www.digital-peak.com>
 * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL
 */

// The needed libs
const fs = require('fs');
const path = require('path');
const jsstrip = require('js-cleanup');
const rollup = require('rollup');
const resolve = require('@rollup/plugin-node-resolve');
const replace = require('@rollup/plugin-replace');
const terser = require('@rollup/plugin-terser');
const strip = require('@rollup/plugin-strip');
const svg = require('rollup-plugin-svg');
const vue = require('rollup-plugin-vue');
const css = require('rollup-plugin-import-css');
const urlresolve = require('rollup-plugin-url-resolve');
const util = require('./util');

async function buildAsset(root, asset, config) {
	try {
		const rollupConfig = getConfig(root, asset, config);
		if (Object.keys(rollupConfig.input).length === 0) {
			return;
		}

		const bundle = await rollup.rollup(rollupConfig);

		// Generate code
		await bundle.write(rollupConfig.output);

		if (config.docBlock) {
			Object.values(rollupConfig.input).forEach((f) => {
				const destination = f.replace(asset.src, asset.dest);
				let content = jsstrip(fs.readFileSync(destination, 'utf8'), null, { comments: 'none', sourcemap: true });
				fs.writeFileSync(destination, config.docBlock + "\n" + content.code);
				fs.writeFileSync(destination + '.map', content.map.mappings);
			});
		}
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

		util.deleteDirectory(root + '/' + asset.dest);

		try {
			const bundle = await rollup.watch(rollupConfig);

			bundle.on('event', (event) => {
				switch (event.code) {
					case 'START':
						startBundleTime = Date.now();
						break;
					case 'BUNDLE_START':
						console.log(`bundles ${event.input} → ${Array.isArray(event.output) ? event.output.join(',') : event.output}`);
						break;
					case 'BUNDLE_END':
						console.log(`created ${Array.isArray(event.output) ? event.output.join(',') : event.output} in ${Date.now() - startBundleTime}ms`);
						break;
					case 'END':
						console.log('waiting for changes');
						break;
					default:
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

	return {
		input: files,
		output: {
			dir: root + '/' + asset.dest, format: 'es', sourcemap: true, chunkFileNames: (chunkInfo) => {
				if (chunkInfo.facadeModuleId !== null && chunkInfo.facadeModuleId.indexOf('node_modules') !== -1) {
					return 'libraries/[name].js';
				}

				return 'modules/[name].js';
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
			resolve.nodeResolve({ modulePaths: [config.moduleRoot + '/node_modules'] }),
			urlresolve(),
			svg(),
			vue(),
			css(),
			strip()
		],
		context: 'window'
	};
}

module.exports = {
	buildAsset: buildAsset,
	watchAssets: watchAssets
}
