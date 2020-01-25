# Webserver task
This task starts a web server on localhost with port 80. The latest PHP version is used and as web server is apache running. There are two joomla sites built during startup, one for patch release development and the other for feature release development where extensions are linked into them. Additionally there are other tools available which are documented below.

Optionally if you have checked out the joomla core repository then they are linked as well.

Also keep in mind that you should **NOT USE THIS IN PRODUCTION**!!

## Prerequisites
Nothing special, the extensions do need to follow the directory structure mentioned in the [main document](..).

## Execute
To start the web server, execute the following command:

`./run.sh [rebuild]`

Example

`./run.sh`

The rebuild argument is optional, if set then the whole web server is rebuild and you have a clean setup as when you started it for the first time.

## Internals
When starting the web server, there are four docker containers executed. An Apache web server, a MySQL server, a phpMyAdmin server and a Mailcatcher. All of them are out of the box ready to use.

To manage the joomla sites and link extensions the great [joomla console project](https://github.com/joomlatools/joomlatools-console) from the joomlatools guys is used.

### Extension linking
Extensions in the same directory as this project will automatically being linked when the follow the directory structure as described in the [main document](..). After linking they are installed as well.

## Result
When the web server is successfully started then are the following sites available:

- **Patch release dev site**  
With the url _localhost/j_ you get access to a joomla instance which contains your linked extensions. This site is used for patch release development. Only extensions which do have no _-_ in its directory name are linked into this site.  
You can log in on the site with admin/admin.
- **Feature release dev site**  
With the url _localhost/dev_ you get access to a joomla instance which contains your linked extensions. This site is used for feature release development. Only extensions which do have a _-Dev_ in its directory name are linked into this site.  
You can log in on the site with admin/admin.
- **Joomla 3 core dev site**  
With the url _localhost/cms_ you get access to a joomla instance which is linked from the _cms_ folder in the same directory as you have this project. This folder can be a clone of the joomla _staging_ branch which contains the actual code of Joomla 3.
- **Joomla 4 core dev site**  
With the url _localhost/j4_ you get access to a joomla instance which is linked from the _j4_ folder in the same directory as you have this project. This folder can be a clone of the joomla _j4-dev_ branch which contains the actual code of Joomla 4. When you have opened the site for the first time, then all the assets should be built already and the PHP dependencies installed.
- **Webgrind profiler**  
With the url _localhost/wg_ you get access to a webgrind instance, which displays some profiling information. Profiling is enabled on all sites but only with a trigger. This means you have to add _XDEBUG_PROFILE_ to the url or use a browser extension like [Xdebug helper for Firefox](https://addons.mozilla.org/en-US/firefox/addon/xdebug-helper-for-firefox) to profile a site. More information how webgrind works can be found [here](https://github.com/jokkedk/webgrind).
- **phpMyAdmin**  
With the url _localhost:81_ you get access to a phpMyAdmin instance.
- **MailCatcher**  
With the url _localhost:82_ you get access to a MailCatcher instance. [Mailcatcher](https://mailcatcher.me/) is a simple web front end to read mails. All sites are configured the way that mails are not sent to the real recipient but do land instead in the mailcatcher. This is handy when yo have to deal with mails.
