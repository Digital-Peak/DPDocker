# Tests task
This task runs the system tests of an extension on joomla 3 and 4. System tests are browser tests performed by selenium and written in PHP with [codeception](https://codeception.com).

Through a VNC viewer you can actually see what is executed inside a container in the browser.

## Prerequisites
The extension needs a tests folder with an acceptance folder in it, this is the location for your tests. Additionally, you need a "_bootstrap.php" file in the tests folder and in the tests/acceptance folder. There you can do some setup stuff which will be executed before codeception is running the tests. Like including some base classes or defining some global variables like a timeout.

If you  have some install tasks which should be executed before every test, then put them into the acceptance/install folder.

## Execute
To run the extension tests, execute the following command:

`./run-system-tests.sh -e extension [-t test] [-j jooma-version] [-p php-version]`

Examples

```
./run-system-tests.sh -e Foo #All tests on Joomla 3 and 4 on the latest PHP version on chrome
./run-system-tests.sh -e Foo -b firefox #All tests on Joomla 3 and 4 on the latest PHP version on firefox
./run-system-tests.sh -e Foo -j 3 -php 7.3 #All tests only on Joomla 3 and PHP 7.3 on chrome
./run-system-tests.sh -e Foo -t tests/acceptance/views -php 8.0 #Test in folder tests/acceptance/views on Joomla 3 and 4 on PHP 8.0 on chrome
./run-system-tests.sh -e Foo -t tests/acceptance/views -j 4 #Tests in folder tests/acceptance/views on Joomla 4 on the latest PHP version on chrome
./run-system-tests.sh -e Foo -t tests/acceptance/views/ArticleViewCest.php:canSeeArticle #Test tests/acceptance/views/ArticleViewCest.php:canSeeArticle on Joomla 3 and 4 on the latest PHP version on chrome
./run-system-tests.sh -e Foo -t tests/acceptance/views/ArticleViewCest.php:canSeeArticle -j 4 -php 7.4 #Test tests/acceptance/views/ArticleViewCest.php:canSeeArticle on Joomla 4 on PHP 7.4 on chrome
./run-system-tests.sh -e Foo -d '' #All tests on Joomla 3 and 4 on the latest PHP version on firefox but not in debug mode
```

- -e  
  The extension to test.
- -t  
  The test attribute is optional. If it is set then only this test is executed, otherwise the whole extension.
- -j  
  The Joomla version is optional. If it is not set, tests will be run on Joomla 3 and 4.
- -php  
  The PHP version is optional. If it is not set, tests will be run on the latest PHP version.
- -b  
  The browser is optional. If it is not set, tests will be run on the chrome. available are `chrome` and `firefox`.
- -d  
  The debug parameter is optional. If it is not set, it starts in debug mode where a VCN viewer can be connected to.

## Internals
Running the system tests is a rather complex setup. Due some startup issues we need to start every container in sequence. In total are five containers created. First the MySQL container. Then the web server which is accessible on the url _localhost:8080/joomla{joomla version}_ and selenium. If all are up, then the actual system tests are executed.

During a test PHPMyAdmin is available under _localhost:8081_ and the mailcatcher on _localhost:8082_.

Every suite can provide an install folder which will be executed first to do some setup tasks after installation of the extension. The order of the other tests is randomly to prevent execution order issues as every test need to be isolated.

Tests on Joomla 3 are executed on the url /joomla3 and for Joomla 4 on /joomla4.

### Mailcatcher usage
Mailcatcher has a simple REST interface where you can interact with the mails. To access mailcatcher in codeception use the host mailcatcher-test:1080. The following code snippet is an example how to test if a mail contains a string:
 
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
You will see directly the output of the tests in the console where the system tests are started. If some do fail, then detailed reports are printed. Additionally you can find screenshots and the HTML pages of the failing tests in the folder tmp/_output of your docker project.
