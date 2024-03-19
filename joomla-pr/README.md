# Tests task
This task starts a web server with a specific joomla pr or branch. The pr argument can be a pr number or a branch on the repo like staging or 4.0-dev. So either you can test it with the latest code or the pr changes.

Composer and NPM is executed during setup and after start a joomla installation is ready on localhost:8090/pr/{number/branch} with the credentials admin/admin, manager/manager or user/user.

It is also possible to run it with postgres instead of mysql.

## Execute
To start the web server, execute the following command in a terminal inside the DPDocker project:

`joomla-pr/run-joomla-pr-webserver.sh pr/branch [db type] [rebuild] [php version]`

### Examples

- `joomla-pr/run-joomla-pr-webserver.sh 22228 -db postgres -r rebuild`  
Runs the web server for pr 22228 on a postgres database and rebuilds it when already fetched.
- `joomla-pr/run-joomla-pr-webserver.sh 33333 -db mysql -php 8.1`  
Runs the web server for pr 33333 on a mysql database with PHP 8.1.
- `joomla-pr/run-joomla-pr-webserver.sh 4.0-dev`  
Runs the web server for pr branch 4.0-dev with the default PHP version and mysql database.

### Arguments
The first argument must always be the pr number or branch, the other ones are optional arguments.
- -php  
  The PHP version to load the web server with. Supported are:
    - 8.1
    - 8.2
    - 8.3
- -db  
  You can use either _mysql_ or _postgres_ as value. If set then the Joomla installations will be installed with the respective driver. _mysql_ is loaded by default.
- -my  
  The MySQL database version. You can use supported tags on [hub.docker.com](https://hub.docker.com/_/mysql). If set then the Joomla installations will be installed with the respective driver. _latest_ is loaded by default.
- -pg  
  The Postgres database version. You can use supported tags on [hub.docker.com](https://hub.docker.com/_/postgres). If set then the Joomla installations will be installed with the respective driver. _latest_ is loaded by default.
- -r  
  If it is set and you have used that pr before it cleans the installation, otherwise it just reuses it.

## Internals
Joomla is cloned from Github and the given pr or branch is checked out. "npm install" and "composer install" is executed after the clone. Then the joomla SQL file is executed with the database driver defined as argument. The proper configuration.php file created. After installation is the website ready to be used.

PHPMyAdmin is available under _localhost:8091_, pgAdmin on _localhost:8092_, the mailcatcher on _localhost:8093_ and FTP on _localhost:8021_.

## Result
On localhost:8090/pr/{number/branch} is joomla available with the given pr or branch and ready to use.
