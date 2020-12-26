# Tests task
This task runs the system tests of an extension. System tests are browser tests performed by selenium and written in PHP with [codeception](https://codeception.com).

Through a VNC viewer you can actually see what is executed inside a container in the browser.

## Prerequisites
The extension needs a tests folder with an acceptance folder which contains the tests.

If you  have some install tasks which should be executed before every test, then put them into the acceptance/install folder. Additionally add the group annotation @install, because DPDocker is skipping this group on the main codeception install run. [Here](https://codeception.com/docs/07-AdvancedUsage#Groups) you can find more information about codeception groups.

## Execute
To run the extension tests, execute the following command:

`./run-system-tests.sh --EXTENSION extension [--TEST test] [--JOOMLA_MAJOR_VERSION version]`

Example

`./run-system-tests.sh --EXTENSION Foo --TEST tests/acceptance/views/ArticleViewCest.php:canSeeUploadFormInArticle --JOOMLA_MAJOR_VERSION 4`

The `test`, `rebuild` and `joomla_major_version` attributes are optional:    
- If `test` is set then only this test is executed, otherwise the whole extension.  
- If `rebuild` is not set then it defaults to false. 
- If `joomla_major_version` is _not_ set then version `3` is used. You have to set it to `4` if you need Joomla version 4.

## Internals
Running the system tests is a rather complex setup. Due some startup issues we need to start every container manually. Five containers are started actually. First the mySQL container. Then the web server which is accessible on the url _localhost:8080/joomla_ and selenium. If all are up, then the actual system tests are executed.

During a test PHPMyAdmin is available under _localhost:8081_ and the mailcatcher on _localhost:8082_.

Every suite needs an install folder which contains some setup tasks during installation of the extension. The order of the other tests is randomly to prevent execution order issues as every tests need to be isolated.

If you like to test an installation, please run run [`./build/run.sh extension [version]`](https://github.com/Digital-Peak/DPDocker/tree/master/build). All in this task created Zip files will be copied before starting the tests to the root of the webserver. So you are able to use them in a test.  

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
You will see directly the output of the tests in the console where the system tests are started. If some do fail, then detailed reports are printed.
