# Base images
This here is not a task, it contains the base images for most of the containers used in the tasks.

DPDocker needs some common standard images like mysql or selenium. But for most tasks it needs some self made images. They have the name `digitpeak/dpdocker-cli` and `digitpeak/dpdocker-web`. These images are available in the [global docker hub](https://hub.docker.com/u/digitpeak). 

Sometimes there is a need to modify the images. So you can edit the `Dockerfile`'s in the respective subfolders. After that you have to build the images again, how to do that can be found in the _Execute_ chapter.

## Prerequisites
Nothing special.

## Execute
To build the images, execute the following command:

`./build.sh`

Example

`./build.sh`

## Internals
The images are built normally with docker. Every image contains a DOCKERFILE which defines the image. All images are built from [thecodingmachine PHP docker project](https://github.com/thecodingmachine/docker-images-php). These images are already configured the way that file permission issues and other problems you normally face with docker are already solved.

The hooks folder within the cli and web folder are for dockerhub to build the images automatically during branch updates. You can find more about build hooks [here](https://docs.docker.com/docker-hub/builds/advanced/#override-build-test-or-push-commands).

### Cli
The cli image is intended to be used with cli tasks like running scripts or other tasks.

### Web
The web image runs an apache web server with all needed extensions enabled.

## Result
The docker registry contains two new images, digitpeak/dpdocker-cli and digitpeak/dpdocker-web which are ready to be used. If you want to use a specific PHP version then use the images with a tag, like `digitpeak/dpdocker-cli:8.0`.
