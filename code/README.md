# Code task
This task runs some different code quality scripts. You can check and fix PHP, Javascript and (S)CSS code style violations or analyze and fix your PHP code quality. Currently is syntax allowed down to PHP 8.1.

Currently are the following code style checks performed:
- **PHP**  
The code style fixer PHP project from [the symfony guys](https://github.com/PHP-CS-Fixer/PHP-CS-Fixer) is used for code style checks and fixes for PHP files. The rules are defined in the file in the file /code/config/.php-cs-fixer.php. When the extension has a .php-cs-fixer.php file in the root folder, then this one will taken, instead of the default one. An extension can include the the one from this project and add some more sugar. Like that are always changes in the base file automatically included in the project.
- **Javascript**  
[Eslint](https://eslint.org) is used for code style checks of Javascript files. The rules are defined in the file in the file /code/config/eslint.config.mjs. When the extension has a eslint.config.mjs. file in the root folder, then this one will taken, instead of the default one.
- **CSS/SCSS**  
[Stylelint](https://stylelint.io) is used for code style checks of CSS and SCSS files. The rules are defined in the file in the file /code/config/.stylelintrc.json. When the extension has a .stylelintrc.json file in the root folder, then this one will taken, instead of the default one.

Currently are the following PHP code analyze checks performed:
- **Rector**  
[Rector](https://getrector.com) fixes the PHP code and is able to upgrade it to a specific PHP version. Currently a minimum PHP compatibility of 8.1 is configured. The configuration is defined in the file in the file /code/config/rector.php. When the extension has a rector.php file in the root folder, then this one will taken, instead of the default one.
- **PHPStan**  
[PHPStan](https://phpstan.org) finds bugs in the extension PHP code with strong type hinting. Currently up to level 8 does PHPStan check the code quality, as typed arrays is out of scope for now. The configuration is defined in the file in the file /code/config/phpstan.neon. When the extension has a phpstan.neon file in the root folder, then this one will taken, instead of the default one. It is also possible to create a phpstan.neon file in the root of the extension project which references the original file from DPCocker through the [includes attribute](https://phpstan.org/config-reference#multiple-files).

## Prerequisites
Nothing special.

## Execute
### Code check
To run a code check, execute the following command:

`./run-check.sh extension [path]`

Example

`./run-check.sh Foo com_foo/admin/src/Controller`

The path is optional. If specified only files in the subpath are checked, it can also point to a single file.

### Code fix
THIS TASK CHANGES YOUR CODE FILES, COMMIT ALL YOUR STUFF BEFORE RUNNING IT!!

To run a code fix, execute the following command:

`./run-fix.sh extension [path]`

Example

`./run-fix.sh Foo com_foo/admin/src/Model`

The path is optional. If specified only files in the subpath are checked, it can also point to a single file.

### Code analyze
THIS TASK CHANGES YOUR CODE FILES, COMMIT ALL YOUR STUFF BEFORE RUNNING IT!! It is also recommended that you run the code style fixer after the analyze task as Rector works on the AST and it can happen that it does not rebuild the files the same way as they were before.

To run a code analyze, execute the following command:

`./run-analyze.sh extension [path]`

Example

`./run-analyze.sh Foo  com_foo/admin/src/View`

The path is optional. If specified only files in the subpath are checked, it can also point to a single file.

## Internals
Our PHP code style is based on PSR-2 which is also the Joomla standard now, but we are using tabs. So we are using this one as template. But it is possible to define your own one in your extension. Just place your preferred code style file in the root folder of your extension.

The analyze tools Rector and PHPStan are using the most strict levels, if you want to be less strict, copy the default configuration files and remove rector sets or individual rules or lover the PHPStan level. Both tools do load the joomla-bootstrap.php file which adds the Joomla classes and loads the extension classes into the Joomla classloader. Thats why the Joomla code is cloned into the folder /code/tmp/joomla. The default branch is used and is updated on every analyze run, including the PHP dependencies installed.

If your project connects to other extensions, then you can create a Joomla-Projects folder on the same level as DPDocker. The files of that project are included during code analyze. For example when you have a reference to DPAttachments, include the whole project there.

### Rector
Rector runs all available rules, except the naming ones as naming should be independent. It does also ignore the following rules:

- Keeps Joomla version compare with JVersion
- Does not remove @param and @return doc tags when types are used in the function signature
- The <?php } > code statement in template files is fine
- Unused methods and properties should not be removed as template files can always use them or when a custom classloader is available
- Classes do not get the final attribute and parent calls are also not removed when Rector can't analyze the hierarchy
- The or boolean statement is allowed
- Increments can also be written the post way
- If statements are not split
- Component classes can have use statements on one line as the CategoryServiceTrait and TagServiceTrait need to be defined with insteadof

Rector does the first time cache the classes in /code/tmp/cache, so if something goes wrong, clear the cache directory.

### PHPStan
PHPStan analyzes the code up to level 8, for now it doesn't care about mixed types which are on level 9 checked. While the analyze is performed, the following errors are ignored:

- The $this variable is allowed in template files in the /tmpl/ folder
- The $displayData variable is allowed in layout files in the /layouts/ folder
- Array doesn't need to be specified correctly with all attributes, we are relaxed here
- CMSObject type hint messages for the getItem function, needs to be fixed in core first
- Ignoring triggerEvent as not all core events are converted yet
- Ignoring the deprecated getError function as we need to wait till the core actually throws exceptions
