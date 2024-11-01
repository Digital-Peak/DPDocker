# Npm task
This task offers multiple scripts to build or watch local assets and manage Javascript dependencies.

## Prerequisites
The extension can contain multiple assets definitions, described in a assets.json configuration file.

If there are Javascript dependencies then the extension can use a package.json file.

## Execute
### Install dependencies
To install the Javascript dependencies, execute the following command:

`./run-install.sh extension`

Example

`./run-install.sh Foo`

### Update dependencies
To update the Javascript dependencies, execute the following command:

`./run-update.sh extension`

Example

`./run-update.sh Foo`

### Build assets
To build the local assets, execute the following command:

`./run-build.sh extension [all]`

Example

`./run-build.sh Foo`

The all argument is optional. If set it then are also the dependencies built.

### Watch assets
While you are on development, then you don't want to manually build the assets. For that a watch script is available which detects file changes and builds only the respective asset, to do so execute the following command:

`./run-watch.sh extension`

Example

`./run-watch.sh Foo`

## Internals
The code to perform the tasks is running on node.js. It uses tools like sass compiler, rollup or terser. All the local assets of an extension should not be placed in the media folder, because the transpile tasks does copy them there. So you would end in an infinite loop. We at Digital Peak do place the assets always in the resource folder on the same level as the media folder is.
If the assets file contains a "docBlock" property then all comments in the generated JS files are stripped out and the "docBlock" is added to the top of the generated file.

## ES6 modules
[ES6 module support](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules) is a first class citizen in DPDocker. Means all Javascript files are created in a way that they can be loaded with the type="module" parameter. Like that are dynamic imports possible and all the Javascript code is running in strict mode. Modules are built with [rollup](https://rollupjs.org/es-module-syntax/) and dynamic imports are placed within the asset destination.

When a module is imported, then the compiled bundle does contain the module together with the app file. Except when the module is used in different app files, then rollup does generate a chunk and adjusts the import accordingly

### Install/update
npm install or update is executed within the package folder. All dependencies will then be available in the node_modules folder.

### Build/watch
Both tasks are transpiling the files in the same way. Sass files are transpiled into CSS and Javascript files are first bundled with rollup and then a none minified file is written with a map file to the target location. The none minified file is not compiled back to ES5, it is used as it is. The minified file which ends with .min.js is converted back to be compatible with ES (in particular IE 11).

From the Javascript dependencies are only the none minified files used. The minified file is generated out of this one and not the one from the package itself. Like that we have it consistent across the whole project and it is possible to generate map files correctly for local development.

## Result
All assets are placed in the destination from the dest attribute. Vendor Javascript imports are placed within a vendor subdirectory when dynamically imported, while modules are placed within the modules subfolder.

CSS files can be imported as well and are converted during build with the filename .css.min.js. Dynamic imports are [supported too](https://github.com/Digital-Peak/DPAttachments/commit/bc8ea064421116a70028db1fe66e02af09c6ac27) as you can see in the following example:

`import('tippy.js/dist/tippy.css');`

## Asset file documentation
The asset.json file does define the assets of an extension. It can include local assets or external dependencies.

The top level properties can be local, localDev, vendor or docBlock. Each of them will be handled differently.

### local
The local property contains an array of _src_ and _dest_ properties. They can be a folder or file within the current directory of the assets.json file. If it is a folder then all files are generated on the target location with the same name.

### localDev
This is a helper property which can contain an array of file paths relative to the top level folder of the extension. It is used in the watch script as it can be the case that you have ES6 modules or SASS files in different locations and when changes do happen there that the whole extension should be built, to correctly regenerate all dependencies.

### vendor
The vendor property can contain an array of web dependencies like Javascript, CSS or icon files from the node_modules folder. Every entry has a _src_ and _dest_ property. where the _src_ property is the relative location (file or folder) in the node_modules folder and the _dest_ the relative one from the top level root folder. _src_ can also be an array, so multiple files are concatenated together except when the destination folder is a directory. This is handy when you have a library which is split into multiple files and you want to use only the ones you actually need.

### docBlock
A docblock which is added to the top of the generated JS files. All the other ones are then stripped out of the file.

### Example
Example of assets.json file in com_foo/resources:
```
{
  "local": [
    {
      "src": "scss",
      "dest": "../media/css"
    },
    {
      "src": "js",
      "dest": "../media/js"
    }
  ],  
  "localDev": [
    "scss-blocks/layouts",
    "js-modules"
  ],
  "vendor": [
    {
      "src": "tingle.js/dist/tingle.js",
      "dest": "../media/js/tingle/tingle.js"
    },
    {
      "src": "tingle.js/dist/tingle.css",
      "dest": "../media/css/tingle/tingle.css"
    }
  ],
   "config": {
    "docBlock": "/**\n * @package   Foo\n * @copyright My inc. <https://www.example.com>\n * @license   http://www.gnu.org/licenses/gpl-3.0.html GNU/GPL\n */",
    "compatibility": [
      ",> 0.25%, not dead",
      "ie 11"
    ]
  }
}
```
