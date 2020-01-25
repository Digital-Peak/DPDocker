# Base images
This here is not a task, it contains the base images for the containers in the tasks.

## Prerequisites
Nothing special.

## Execute
To run a build, execute the following command:

`./build.sh`

Example

`./build.sh`

## Internals
The images are built normally with docker. Every image contains a DOCKERFILE which defines the image. All images are built from [thecodingmachine PHP docker project](https://github.com/thecodingmachine/docker-images-php). These images are already configured the way that file permission issues and other problems you normally face with docker are already solved.

### Cli
The cli image is intended to be used with cli tasks like running scripts or other tasks.

### Web
The web image runs an apache web server with all needed extensions enabled.

## Result
The docker registry contains two new images, dpdocker-cli and dpdocker-web which are ready to be used.
