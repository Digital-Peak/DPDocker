# Composer task
This task handles the PHP dependencies of an extension.

## Prerequisites
Nothing special, just a composer.json file either in the admin folder of your component or in the root folder of the other extensions within your package.

## Execute
### Install
To install the dependencies, execute the following command:

`./run-install.sh extension [extension]`

Example

`./run-install.sh Foo`

The extension attribute is optional if you want to install the dependencies of only one extension and not all.

### Update
To update the dependencies, execute the following command:

`./run-update.sh extension [extension]`

Example

`./run-update.sh Foo`

The extension attribute is optional if you want to update the dependencies of only one extension and not all.

## Internals
### Cache
That composer has not to download all the dependencies on every task, the install scripts create a tmp folder which is linked on every install tasks. This folder is the home directory of composer. YOu will find in it a cache folder and a auth.json folder if you have added a token to composer. If you want to restart, just delete the folder and you do an install as if you are working on an empty system.

### Outdated packages
After installation and update of the dependencies are the outdated packages displayed.

### Cleanup
After a successful install or update run some packages do contain test folders or readme files. These files should not be in production. To prevent this situation a cleanup file is executed which deletes not needed files or folders. If a file or folder matches the following list of names then it will be deleted:

- bin/
- test/
- tests/
- doc/
- docs/
- examples
- phpunit
- git
- build/
- composer.json
- README
- ChangeLog
- CONTRIBUTING
- UPGRADE
- Makefile
- .travis
- .styleci
- .sh
- .dist
- scrutinizer

Additionally it is possible by the extension to exclude files by its own. If a file with the name _vendor-ignore.txt_ exists in the same directory as the composer.json is, then it is taken into account as well. The content must be a new line separated list of file name patterns.

## Result
When the tasks have finished then the vendor directory is correctly populated.
