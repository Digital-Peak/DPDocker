# Base images
This here is not a task, it contains the base images for the containers in the tasks.

## Prerequisites
Nothing special.

## Execute
To run a build, execute the following command:

`./build.sh [--PHP_VERSION php-version] [--GLOBAL_VERSION global-version] [--NODE_VERSION node-version] [--REBUILD rebuild]`

Examples

`./build.sh`

- `./build.sh --PHP_VERSION 7.4 --GLOBAL_VERSION 3 --NODE_VERSION 12 --REBUILD rebuild`

- `./build.sh --PHP_VERSION 8.0 --GLOBAL_VERSION 4 --NODE_VERSION 14 --REBUILD rebuild`  

All attributes are optional.

- `PHP_VERSION`: `7.4` is loaded by default.
- `GLOBAL_VERSION`: `3` is loaded by default.
- `NODE_VERSION`: `12` is loaded by default.
- `REBUILD`: _If you set this parameter with true or rebuild, then all images and containers on your computer will be deleted!_ `false` is loaded by default.

More information about the parameters - and how you can combine them - can be found on thecodingmachine PHP docker project on [Github-Page](https://github.com/thecodingmachine/docker-images-php).

## Internals
The images are built normally with docker. Every image contains a DOCKERFILE which defines the image. All images are built from [thecodingmachine PHP docker project](https://github.com/thecodingmachine/docker-images-php). These images are already configured the way that file permission issues and other problems you normally face with docker are already solved.

### Cli
The cli image is intended to be used with cli tasks like running scripts or other tasks.

### Web
The web image runs an apache web server with all needed extensions enabled.

## Result
The docker registry contains two new images, dpdocker-cli and dpdocker-web which are ready to be used.
