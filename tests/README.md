# Tests task
This task runs the system tests of an extension. System tests are browser tests performed by selenium and written in PHP with [codeception](https://codeception.com).

Through a VNC viewer you can actually see what is executed inside a container in the browser.

## Prerequisites
The extension needs a tests folder with an acceptance folder which contains the tests.

## Execute
To run a build, execute the following command:

`./run-system-tests.sh extension [test]`

Example

`./run-system-tests.sh Foo tests/acceptance/views/ArticleViewCest.php:canSeeUploadFormInArticle`

The test attribute is optional. If it is set then only this test is executed, otherwise the whole extension.

## Internals
Running the system tests is a rather complex setup. Due some startup issues we need to start every container manually. Five containers are started actually. First the mySQL container. Then the web server which is accessible on the url _localhost:8080/joomla_ and selenium. If all are up, then the actual system tests are executed.

During a test PHPMyAdmin is available under _localhost:8081_ and the mailcatcher on _localhost:8082_.

Every suite needs an install folder which contains some setup tasks during installation of the extension.

## Result
You will see directly the output of the tests in the console where the system tests are started. If some do fail, then detailed reports are printed.
