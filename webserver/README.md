# Webserver task
This task starts an apache web server on localhost with port 80. There are different joomla sites built during startup, either with Joomla 3 or 4. Some are for patch release development and some for feature release development where extensions are linked into them. Additionally there are other sites and tools available which are documented below.

Optionally if you have checked out the joomla core repository then they are linked as well.

Also keep in mind that you should **NOT USE THIS IN PRODUCTION**!! The initial load takes a while because compiling the assets is a very long running task and this must be executed when setting up Joomla 4.

## Prerequisites
Nothing special, the extensions do need to follow the directory structure mentioned in the [main document](..).

## Execute
To start the web server, execute the following command:

`./run.sh [-php php-version] [-db db-type] [-my mysql-db-version] [-pg postgres-db-version] [-r rebuild]`

Examples

- `./run.sh -php 8.1 -db mysql -my 5.6`

- `./run.sh -php 8.3 -db postgres -pg 13 -r yes`

All attributes are optional.
- -php  
  The PHP version to load the web server with. Supported are:  
  - 8.1
  - 8.2
  - 8.3
  - 8.4
- -db  
  You can use either _mysql_ or _postgres_ as value. If set then the Joomla installations will be installed with the respective driver. _mysql_ is loaded by default.
- -my  
  The MySQL database version. You can use supported tags on [hub.docker.com](https://hub.docker.com/_/mysql). If set then the Joomla installations will be installed with the respective driver. _latest_ is loaded by default.
- -pg  
  The Postgres database version. You can use supported tags on [hub.docker.com](https://hub.docker.com/_/postgres). If set then the Joomla installations will be installed with the respective driver. _latest_ is loaded by default.
- -r  
  When "yes" then the whole web server is rebuild and you have a clean setup as when you started it for the first time.

## Internals
When starting the web server, there are seven docker containers started. An Apache web server, a MySQL server, a phpMyAdmin server, a postgres server, a pgAdmin server, a Mailcatcher server and an FTP server. All of them are out of the box ready to use.

To install Joomla, link the extensions and discover them we use a mix of PHP and shell scripts. All these scripts can be found in the scripts folder.

To speed up Joomla installations, DPDocker is caching the Joomla releases in the www/cache folder. So when something is screwed up, delete the cache folder. It downloads then the code again and installs the dependencies and builds the assets from scratch.

### Extension linking
Extensions in the same directory as this project will automatically being linked when they follow the directory structure as described in the [main document](https://github.com/Digital-Peak/DPDocker#structure) or the [Weblinks for Joomla! Repository](https://github.com/joomla-extensions/weblinks). 

After linking they are mostly installed as well. In all cases you can discover them manually.

## Result
When the web server is successfully started then are the following sites available:

- **Patch release development site**  
With the url _localhost/{j5|j6}_ you get access to a joomla instance which contains your linked extensions. This site is used for patch release development. Only extensions which do have no _-_ in its directory name are linked into this site.  
You can log in on the site with admin/admin. In the "/webdav" subdirectory you get access to a webdav server instance, if the document root is mounted by a volume, then this directory needs to be created manually. The credentials to log in are webdav/webdav.
- **Feature release development site**  
With the url _localhost/{dev5|dev6}_ you get access to a joomla instance which contains your linked extensions. This site is used for feature release development. Only extensions which do have a _-Dev_ in its directory name are linked into this site.  
You can log in on the site with admin/admin. In the "/webdav" subdirectory you get access to a webdav server instance, if the document root is mounted by a volume, then this directory needs to be created manually. The credentials to log in are webdav/webdav.
- **Joomla 5 core dev site**  
With the url _localhost/cms5_ you get access to a joomla instance which is linked from the _cms5_ folder in the same directory as you have this project. This folder can be a clone of the joomla _5.x-dev_ branch which contains the actual code of Joomla 5. When you have opened the site for the first time, then all the assets should be built already and the PHP dependencies installed. In the "/webdav" subdirectory you get access to a webdav server instance, if the document root is mounted by a volume, then this directory needs to be created manually. The credentials to log in are webdav/webdav.
- **Joomla 6 core dev site**  
With the url _localhost/cms6_ you get access to a joomla instance which is linked from the _cms6_ folder in the same directory as you have this project. This folder can be a clone of the joomla _6.x-dev_ branch which contains the actual code of Joomla 6. When you have opened the site for the first time, then all the assets should be built already and the PHP dependencies installed. In the "/webdav" subdirectory you get access to a webdav server instance, if the document root is mounted by a volume, then this directory needs to be created manually. The credentials to log in are webdav/webdav.
- **Playground site**  
With the url _localhost/{play5|play6}_ you get access to a joomla instance which is intended to be used to mess around. There are no linked extensions into it. In the "/webdav" subdirectory you get access to a webdav server instance, if the document root is mounted by a volume, then this directory needs to be created manually. The credentials to log in are webdav/webdav.
- **Webgrind profiler**  
With the url _localhost/wg_ you get access to a webgrind instance, which displays some profiling information. Profiling is enabled on all sites but only with a trigger. This means you have to add _XDEBUG_PROFILE_ to the url or use a browser extension like [Xdebug helper for Firefox](https://addons.mozilla.org/en-US/firefox/addon/xdebug-helper-for-firefox) to profile a site. More information how webgrind works can be found [here](https://github.com/jokkedk/webgrind).
- **phpMyAdmin**  
With the url _localhost:81_ you get access to a phpMyAdmin instance.
- **pgAdmin**  
With the url _localhost:82_ you get access to a pgAdmin instance.
- **MailCatcher**  
With the url _localhost:83_ you get access to a MailCatcher instance. [Mailcatcher](https://mailcatcher.me/) is a simple web front end to read mails. All sites are configured the way that mails are not sent to the real recipient but do land instead in the mailcatcher. This is handy when yo have to deal with mails.
- **FTP server**  
With the url _localhost:21_ you get access to a FTP server instance. You can log in with ftp/ftp. Please use none secure connections.
- **SSH server**  
With the url _localhost:2222_ you get access to a SSH server instance with SFTP support. You can log in with sftp/sftp or the key which is available in the web root on /var/www/html/key.
