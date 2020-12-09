# Npm task
This task offers multiple scripts to build or watch local assets and manage Javascript dependencies.

## Prerequisites
The extension needs a package folder with a assets.json file which describes the assets of the extension.

If there are Javascript dependencies then the package.json file needs to be available in the package folder as well.

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
The code to perform the tasks is running on node.js. It uses tools like sass compiler, babel, rollup or minifyjs. All the local assets of an extension should not be placed in the media folder, because the transpile tasks does copy them there. So you would end in an infinite loop. We at Digital Peak do place the assets always in the resource folder on the same level as the media folder is.
If the assets file contans a "docBlock" property then all comments in the generated JS files are stripped out and the "docBlock" is added to the top of the generated file.

### Install/update
npm install or update is executed within the package folder. All dependencies will then be available in the node_modules folder.

### Build/watch
Both tasks are transpiling the files in the same way. Sass files are transpiled into CSS and Javascript files are first bundled with rollup and then a none minified file is written with a map file to the target location. The none minified file is not compiled back to ES5, it is used as it is. The minified file which ends with .min.js is converted back to be compatible with ES (in particular IE 11).

From the Javascript dependencies are only the none minified files used. The minified file is generated out of this one and not the one from the package itself. Like that we have it consistent across the whole project and it is possible to generate map files correctly for local development.

## Result
All assets and PHP dependencies are on the right location.

## Asset file documentation
The asset.json file does define the assets of an extension. It can include local assets or external dependencies.

The top level properties can be local, localDev, vendor or docBlock. Each of them will be handled differently.

### local
The local property contains an array of _src_ and _dest_ properties. They can be a folder or file within the extension top level directory. If it is a folder then all files are generated on the target location with the same name.

### localDev
This is a helper property which can contain an array of file paths relative to the top level folder of the extension. It is used in the watch script as it can be the case that you have ES6 modules or SASS files in different locations and when changes do happen there that the whole extension should be built, to correctly regenerate all dependencies.

### vendor
The vendor property can contain an array of Javascript dependencies from the node_modules folder. Every entry has a _src_ and _dest_ property. where the _src_ property is the relative location (file or folder) in the node_modules folder and the _dest_ the relative one from the top level root folder. _src_ can also be an array, so multiple files are concatenated together. This is handy when you have a library which is split into multiple files and you want to use only the ones you actually need.

Example:
```
{
  "local": [
    {
      "src": "com_foo/resources/scss",
      "dest": "com_foo/media/css"
    },
    {
      "src": "com_foo/resources/js",
      "dest": "com_foo/media/js"
    }
  ],  
  "localDev": [
    "com_foo/resources/scss-blocks/layouts",
    "com_foo/resources/js-modules"
  ],
  "vendor": [
    {
      "src": "tingle.js/dist/tingle.js",
      "dest": "com_foo/media/js/tingle/tingle.js"
    },
    {
      "src": "tingle.js/dist/tingle.css",
      "dest": "com_foo/media/css/tingle/tingle.css"
    }
  ]
}
```

### docBlock
A docblock which is added to the top of the generated JS files. All the other ones are then stripped out of the file.