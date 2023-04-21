# Tests task
This task runs the system tests of an extension on joomla 3 and 4 or a core joomla clone. System tests are browser tests performed by selenium and written in PHP with [Codeception](https://codeception.com). Since Joomla 4.3, the core system tests of the CMS are ported to [cypress](https://www.cypress.io).

Through a VNC viewer you can actually see what is executed inside a container in the browser, when the extension system tests are executed. More information can be found in the "Observe" chapter.

## Prerequisites extension system tests
The extension needs a tests folder which is the location for your tests. This folder is used as root for your namespaced tests. Means every test needs to be in the namespace `Tests/`. So it would make sense to put your backend tests into the folder `tests/Acceptance/Administrator/ListViewCest.php`, then the namespace must be `Tests/Acceptance/Administrator`. More information can be found in the [Codeception docs](https://codeception.com/docs/GettingStarted).

If you  have some install tasks which should be executed before every test, then put them into the Acceptance/Install folder.

## Prerequisites joomla core CMS system tests
If you want to test the core system tests, then you need to have a clone of the repo in the same parent folder of DPDocker so that they are on the same level. The JS and PHP dependencies are installed and configured on demand

## Execute extension tests
To run the extension tests, execute the following command:

`./run-system-tests.sh -e extension [-t test] [-j jooma-version] [-p php-version]`

Examples

```
./run-system-tests.sh -e Foo # All tests on Joomla 3 and 4 on the latest PHP version on chrome
./run-system-tests.sh -e Foo -b firefox # All tests on Joomla 3 and 4 on the latest PHP version on firefox
./run-system-tests.sh -e Foo -j 3 -php 7.3 # All tests only on Joomla 3 and PHP 7.3 on chrome
./run-system-tests.sh -e Foo -t tests/acceptance/views -php 8.0 # Test in folder tests/acceptance/views on Joomla 3 and 4 on PHP 8.0 on chrome
./run-system-tests.sh -e Foo -t tests/acceptance/views -j 4 # Tests in folder tests/acceptance/views on Joomla 4 on the latest PHP version on chrome
./run-system-tests.sh -e Foo -t tests/acceptance/views/ArticleViewCest.php:canSeeArticle # Test tests/acceptance/views/ArticleViewCest.php:canSeeArticle on Joomla 3 and 4 on the latest PHP version on chrome
./run-system-tests.sh -e Foo -t tests/acceptance/views/ArticleViewCest.php:canSeeArticle -j 4 -php 7.4 # Test tests/acceptance/views/ArticleViewCest.php:canSeeArticle on Joomla 4 on PHP 7.4 on chrome
```

- -e  
  The extension to test.
- -t  
  The test attribute is optional. If it is set then only this test is executed, otherwise the whole extension.
- -j  
  The Joomla version is optional. If it is not set, tests will be run on Joomla 3 and 4.
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
  The folder where joomla is cloned into.
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

## Internals
Running the system tests is a rather complex setup. Due some startup issues we need to start every container in sequence. In total are six containers created. First the MySQL and postgres container. Then the web server which is accessible on the url _localhost:8080/joomla{joomla version}_ or _localhost:8080/{joomla}_ and selenium. If all are up, then the actual system tests are executed.

During a test PHPMyAdmin is available under _localhost:8081_, PGAdmin is available under _localhost:8082_ and the mailcatcher on _localhost:8083_.

Every suite can provide an install folder which will be executed first to do some setup tasks after installation of the extension. The order of the other tests is randomly to prevent execution order issues as every test need to be isolated.

Tests for extension on Joomla 3 are executed on the url /joomla3 and for Joomla 4 on /joomla4. When the joomla core system tests are executed then joomla is available in the same folder as defined like /joomla-cms.

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

## Result
You will see directly the output of the tests in the console where the Codeception system tests are started. If some do fail, then detailed reports are printed. Additionally you can find screenshots and the HTML pages of the failing tests in the folder tmp/_output of your docker project.

The cypress tests are giving immediate feedback in the user interface. The screenshots can be found in the folder /tests/cypress/output/screenshots.
