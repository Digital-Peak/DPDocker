# Code task
This task runs some different code quality scripts. You can analyze and fix code violations of your code style.

Currently are the following code style checks performed:
- **PHP**  
The code style fixer PHP project from [the symfony guys](https://github.com/PHP-CS-Fixer/PHP-CS-Fixer) is used for code style checks and fixes for PHP files. The rules are defined in the file in the file /code/config/.php-cs-fixer.php.
- **Javascript**  
[Eslint](https://eslint.org) is used for code style checks of Javascript files. The rules are defined in the file in the file /code/config/.eslintrc.js.
- **CSS/SCSS**  
[Stylelint](https://stylelint.io) is used for code style checks of CSS and SCSS files. The rules are defined in the file in the file /code/config/.stylelintrc.json.

The extension can override the default file with it's own configuration in the root folder .


## Prerequisites
Nothing special.

## Execute
### Code check
To run a code check, execute the following command:

`./run-check.sh extension`

Example

`./run-check.sh Foo`

### Code fix
THIS TASK CHANGES YOUR CODE FILES, COMMIT ALL YOUR STUFF BEFORE RUNNING IT!!

To run a code fix, execute the following command:

`./run-fix.sh extension`

Example

`./run-fix.sh Foo`


## Internals
Our PHP code style is based on PSR-2 which is also the Joomla standard now, but we are using tabs. So we are using this one as template. But it is possible to define your own one in your extension. Just place your preferred code style file in the root folder of your extension.
