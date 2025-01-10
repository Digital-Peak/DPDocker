# Docker containers for Joomla core and extension development
This repository contains different docker tasks which do help for Joomla core and extension development. Its is for local development purposes only and should **NOT BE USED IN PRODUCTION**!! It contains a lot of dev apps and libraries like xdebug or webgrind and is configured without any security considerations.

## Introduction
Docker allows to perform tasks inside containers. Like that you are not forced to mess around with dependencies on your working computer. Just execute the containers and you are good to go.

That the tasks are actually executed on your code on your local machine, the parent folder of this project is mapped into _/usr/src/Projects_. So the changes which are done inside the container are immediately available on your host and vice versa. If you change something in your code in your IDE, it will be applied directly inside your container. Like that rapid development is possible as you don't have to manually sync code between folders or virtual machines.

If you want to do a test run, use the DPAttachments extension. More information can be found in the [repository](https://github.com/Digital-Peak/DPAttachments).

## Prerequisites
You only need the `docker` binary installed with `compose V2` support. For your convenience there are shell scripts available which do some preparation and start the docker containers properly.

### Windows prerequisites
The easiest way to use DPDocker on Windows is with WSL2, then you work in a Linux environment within Windows. It is the recommended way to use Docker on Windows anyway. First you need to [install your preferred Distro into WSL2](https://docs.microsoft.com/en-us/windows/wsl/install). Then start the WSL Console where you find yourself in a full Linux terminal. Now you can go to the installation step.

Side note: It is recommended to have your project files stored in the WSL system for better performance as DPDocker does a lot of copy operations to start Joomla. More information can be found in the [WSL developer article](https://docs.microsoft.com/en-us/windows/wsl/setup/environment) or on [docker.com](https://docs.docker.com/desktop/windows/wsl/).

## Installation
Clone this repository (when on Windows, make sure in a WSL console):

`git clone https://github.com/Digital-Peak/DPDocker.git`

## Tasks
The following tasks are supported to help developing your extension:

- [Build](build)  
Creates installable packages based on a build.json file.
- [Code](code)  
Different code quality tasks.
- [Composer](composer)  
Installs or updates all PHP dependencies in the extension and performs some cleanup to be production ready.
- [Joomla PR](joomla-pr)  
Does start a web server with a joomla pr.
- [Npm](npm)  
Some npm tasks to install or update the Javascript dependencies. Additionally there is a task to build the assets or do watch the extension for changes and do direct builds.
- [Tests](tests)  
Runs the system tests inside different containers of an extension or joomla core.
- [Webserver](webserver)  
A dev server which set's up a Joomla instance and installs some extensions out of the box.

Every task has a shell script which starts with _run-_. These scripts can be executed on the host on a Linux OS (and probably also on Mac) and do start the containers and in some cases do a bit of setup work. If you are on Windows, then use either a power shell or run the commands by hand in the shell.

Most tasks do have a _scripts_ folder which contains all the scripts which are executed within the container.

## Extension setup
There are tight requirements about the structure of an extension to be able to use this repository. Basically the extension repository is always treated as a package which contains as top level folders the extensions of the package. A Joomla package itself does contain a manifest file and some different extensions like components, modules, plugins or templates.

### Structure
The extension must have the following structure to be able to run the different tasks in this repository:

- package  
Contains the manifest files, asset definitions and build information.
- com_*  
The components of the package. Every component has the administrator code in the _admin_ folder and the site code in the _site_ folder.
- mod_*  
The modules.
- plg_*  
The plugins.
- tmpl_*  
The templates.
- tests  
The folder with the acceptance tests.

## DPDocker images
If you want to build the images by your own, then head on to the [images folder](images), where you will find more information about our images. 
