# Tests task
This task runs the system tests of an extension on any active Joomla major version or a branch. System tests are browser tests performed by selenium and written in PHP with [Codeception](https://codeception.com). Since Joomla 4.3, the core system tests of the CMS are ported to [cypress](https://www.cypress.io) and can be executed with this task as well.

Through a VNC viewer you can actually see what is executed inside a container in the browser, when the extension system tests are executed. More information can be found in the "Observe" chapter. The joomla extension specific Codeception modules are loaded from DPCeption. They offer extra functionality to test mails, files and do certain Joomla actions like log ins. More information can be found in the [DPCeption Github repository](https://github.com/Digital-Peak/DPCeption).

## Prerequisites extension system tests
The extension needs a tests folder which is the location for your tests. This folder is used as root for your namespaced tests. Means every test needs to be in the namespace `Tests/`. So it would make sense to put your backend tests into the folder `tests/Acceptance/Administrator/ListViewCest.php`, then the namespace must be `Tests/Acceptance/Administrator`. More information can be found in the [Codeception docs](https://codeception.com/docs/GettingStarted).

If you  have some install tasks which should be executed before every test, then put them into the Acceptance/Install folder.

## Prerequisites joomla core CMS system tests
If you want to test the core system tests, then you need to have a clone of the repo in the same parent folder of DPDocker so that they are on the same level. The JS and PHP dependencies are installed and configured on demand

## Execute extension tests
To run the extension tests, execute the following command:

`./run-system-tests.sh -e extension [-t test] [-j joomla-version] [-p php-version]`

Examples

```
./run-system-tests.sh -e Foo # All tests on Joomla 4 on the latest PHP version on chrome
./run-system-tests.sh -e Foo -b firefox -j 5.0-dev # All tests on Joomla 5.0-dev on the latest PHP version on firefox
./run-system-tests.sh -e Foo -j 3 -php 7.3 # All tests only on Joomla 3 and PHP 7.3 on chrome
./run-system-tests.sh -e Foo -t tests/acceptance/views -php 8.3 # Test in folder tests/acceptance/views on Joomla 4 on PHP 8.3 on chrome
./run-system-tests.sh -e Foo -t tests/acceptance/views -j 4 # Tests in folder tests/acceptance/views on Joomla 4 on the latest PHP version on chrome
./run-system-tests.sh -e Foo -t tests/acceptance/views/ArticleViewCest.php:canSeeArticle # Test tests/acceptance/views/ArticleViewCest.php:canSeeArticle on Joomla 4 on the latest PHP version on chrome
./run-system-tests.sh -e Foo -t tests/acceptance/views/ArticleViewCest.php:canSeeArticle -j 4 -php 8.1 # Test tests/acceptance/views/ArticleViewCest.php:canSeeArticle on Joomla 4 on PHP 8.1 on chrome
```

- -e  
  The extension to test.
- -t  
  The test attribute is optional. If it is set then only this test is executed, otherwise the whole extension.
- -j  
  The Joomla version is optional, if not set it defaults to the latest stable version of Joomla 4. An actual branch can also be specified, like 4.4-dev or 5.0-dev, then the latest code is fetched from the repository.
- -php  
  The PHP version is optional. If it is not set, tests will be run on the latest PHP version.

## Execute joomla tests in cypress
To run the cypress joomla core CMS tests, execute the following command:

`./run-joomla-system-tests.sh -j joomla_folder [-t test] [-p php-version] [-db db-type] [-my mysql-db-version] [-pg postgres-db-version] `

Examples

```
./run-joomla-system-tests.sh -j cms4 #All tests including the installation test on the latest PHP where joomla is cloned into the folder cms4
./run-joomla-system-tests.sh -j joomla-cms -php 7.3 #All tests including the installation test on PHP 7.3 where joomla is cloned into the folder joomla-cms
```

- -j  
  The folder, relative to the parent directory of the DPDocker installation, where joomla is cloned into. It can be also a path to a subfolder, for example when a pr should be tested like `DPDocker/joomla-pr/www/pr/12345`.
- -php  
  The PHP version is optional. If it is not set, tests will be run on the latest PHP version.
- -db  
  You can use either _mysql_ or _postgres_ as value. If set then the Joomla installations will be installed with the respective driver. _mysql_ is loaded by default.
- -my  
  The MySQL database version. You can use supported tags on [hub.docker.com](https://hub.docker.com/_/mysql). If set then the Joomla installations will be installed with the respective driver. _latest_ is loaded by default.
- -pg  
  The Postgres database version. You can use supported tags on [hub.docker.com](https://hub.docker.com/_/postgres). If set then the Joomla installations will be installed with the respective driver. _latest_ is loaded by default.

## Observe Codeception test progress
Test progress is printed on the console. When running all tests or only a whole folder or script (using the -t parameter) then every executed test is displayed with it's status. If only a function (using the -t parameter with : and a function name) of a test is executed, then the whole output is displayed.

DPDocker starts selenium which offers a [VNC endpoint](https://github.com/SeleniumHQ/docker-selenium#quick-start). So you can connect any VNC viewer to localhost on port 5900. In the app you will see what exactly the browser is doing. This is helpfully when a test fails and you are pausing the test (`$I->pause();`) to see what is wrong. Depending on the VNC viewer you can even interact with the browser window.

## Cypress test UI
When running the cypress tests a UI is opened where all the spec files are listed. It is recommended not to execute the install spec file as when launching the tests, a fresh installation is already done.

## Tests setup
The tests need to be namespaced and must be in the folder tests/src. An example can be found in the [DPAttachments repository](https://github.com/Digital-Peak/DPAttachments/tree/main/tests). Basically you place the Helper, Steps and Page classes in the tests/src/Support folder and the actual tests into tests/src/Acceptance. Is there a need to setup some sample data or setup Joomla in a way which is needed for the extension tests, then put them into the folder tests/src/Acceptance/Install.

Test data files should be placed in the tests/data folder, the can be accessed with `codecept_data_dir('test.jpg)`.

If the helper class needs some additional config data like API keys, then add them to the file tests/env/desktop.yml:

```
modules:
  config:
    Tests\Support\Helper\Acceptance:
      api_token: the-token
```

In the `Tests\Support\Helper\Acceptance` class you can then access that token with `$this->_getConfig('api_token')`. More information can be found in the [Codeception environment docs](https://codeception.com/docs/AdvancedUsage#Environments).

## Internals
Running the system tests is a rather complex setup. First are the selenium, database, (S)FTP and web servers started. If all are up, then the actual system tests are executed.

During a test PHPMyAdmin is available under _localhost:8081_, PGAdmin is available under _localhost:8082_ and the mailcatcher on _localhost:8083_. When running the Joomla system tests, then a mail server is started on port 8084 on the cypress server. This port is exposed to the outside and the Joomla testing web server can reach that port through the host _host.docker.internal_.

Every suite can provide an install folder which will be executed first to do some setup tasks after installation of the extension. The order of the other tests is randomly to prevent execution order issues as every test need to be isolated.

The testing url is always /joomla. When the joomla core system tests are executed then joomla is available in the same folder as defined like /joomla-cms. To speed up Joomla installations, DPDocker is caching the Joomla releases in the www/cache folder. So when something is screwed up, delete the cache folder. It downloads then the code again and installs the dependencies and builds the assets from scratch.

### Mailcatcher usage
Mailcatcher has a simple REST interface where you can interact with the mails. To access mailcatcher in Codeception use the host mailcatcher-test:1080. The following code snippet is an example how to test if a mail contains a string:
 
```
public function clearEmails()
{
    (new \GuzzleHttp\Client())->delete('http://mailcatcher-test:1080/messages');
}

public function seeInEmails($needle)
{
    $mailcatcher = new \GuzzleHttp\Client(['base_uri' => 'http://mailcatcher-test:1080']);
    $mails       = '';
    foreach (json_decode($mailcatcher->get('/messages')->getBody()) as $email) {
        $mails .= $mailcatcher->get('/messages/' . $email->id . '.html')->getBody();
    }
    $this->assertStringContainsString($needle, $mails);
}
```

### (S)FTP server usage
When running the system teasts is a SFTP and FTP server available for testing.

#### FTP
- Host: ftpserver-test
- Port: 21
- Username: ftp
- Password: ftp

#### SFTP
- Host: sshserver-test
- Port: 2222
- Username: sftp
- Password: sftp
- Key file: /var/www/html/key

## Result
You will see directly the output of the tests in the console where the Codeception system tests are started. If some do fail, then detailed reports are printed. Additionally you can find screenshots and the HTML pages of the failing tests in the folder tmp/_output of your docker project.

The cypress tests are giving immediate feedback in the user interface. The screenshots can be found in the folder /tests/cypress/output/screenshots.
