# Tests task
This task starts a web server with a specific joomla pr. Composer and NPM is executed during setup and after start a joomla installation is ready on localhost:8090.

## Execute
To start the web server, execute the following command:

`./run-joomla-pr-webserver.sh pr [rebuild]`

Example

`./run-joomla-pr-webserver.sh 22228 rebuild`

The rebuild attribute is optional. If it is set and you have used that pr before it cleans the installation, otherwise it just reuses it.

## Internals
Joomla is cloned from Github and the given pr is checked out. "npm install" and "composer install" is executed after the clone. Then the joomla SQL file is executed and the proper configuration.php file created. After installation is the website ready to be used.

During a test PHPMyAdmin is available under _localhost:8091_ and the mailcatcher on _localhost:8092_.

## Result
On localhost:8090 is joomla available with the given pr and ready to install.
