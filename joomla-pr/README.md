# Tests task
This task starts a web server with a specific joomla pr or branch. The pr argument can be a pr number or a branch on the repo like staging or 4.0-dev. So either you can test it with the latest code or the pr changes.

Composer and NPM is executed during setup and after start a joomla installation is ready on localhost:8090/pr/{number/branch}.
It is also possible to run it with postgres.

## Execute
To start the web server, execute the following command:

`./run-joomla-pr-webserver.sh pr/branch [db-type] [rebuild]`

Example

`./run-joomla-pr-webserver.sh 22228 postgres rebuild`
`./run-joomla-pr-webserver.sh staging mysql`
`./run-joomla-pr-webserver.sh 4.0-dev`

- The db-type attribute is optional. You can use either _mysql_ or _postgres_.
- The rebuild attribute is optional. If it is set and you have used that pr before it cleans the installation, otherwise it just reuses it.

## Internals
Joomla is cloned from Github and the given pr or branch is checked out. "npm install" and "composer install" is executed after the clone. Then the joomla SQL file is executed with the database driver defined as argument. The proper configuration.php file created. After installation is the website ready to be used.

PHPMyAdmin is available under _localhost:8091_, pgAdmin on _localhost:8092_ and the mailcatcher on _localhost:8093_.

## Result
On localhost:8090/pr/{number/branch} is joomla available with the given pr or branch and ready to use.
