# Code task
This task runs some different code quality scripts. You can analyze and fix code violations of your code style. What for rules are used can be found in the file /code/config/.php-cs-fixer.php.

The code style fixer PHP project from [the symfony guys](https://github.com/PHP-CS-Fixer/PHP-CS-Fixer) is used for code style checks and fixes.

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
Our code style is based on PSR-2 which is also the Joomla standard now, but we are using tabs. So we are using this one as template. But it is possible to define your own one in your extension. Just place your preferred code style file in the root folder of your extension.

## Result
### Code checker
The code check prints the output of the _phpcs_ command directly to the console:
```

./run-fix.sh Foo

PHP CS Fixer 3.22.0 Chips & Pizza by Fabien Potencier and Dariusz Ruminski.
PHP runtime: 8.2.2
Loaded config default from "/usr/src/Projects/DPDocker/code/scripts/../../../DPAttachments/.php-cs-fixer.php".
.FF.F...FFFFF..F.........F.....F..................                                                                                                                                               50 / 50 (100%)
Legend: .-no changes, F-fixed, S-skipped (cached or empty file), I-invalid file syntax (file ignored), E-error
   1) /usr/src/Projects/DPAttachments/com_dpattachments/site/src/View/Attachment/HtmlView.php (global_namespace_import, no_unused_imports)
   2) /usr/src/Projects/DPAttachments/com_dpattachments/site/src/View/Form/HtmlView.php (global_namespace_import, no_unused_imports)
   3) /usr/src/Projects/DPAttachments/com_dpattachments/site/src/Controller/DisplayController.php (global_namespace_import, no_unused_imports)
   4) /usr/src/Projects/DPAttachments/com_dpattachments/admin/src/Model/AttachmentModel.php (single_space_around_construct, global_namespace_import, no_unused_imports)
   5) /usr/src/Projects/DPAttachments/com_dpattachments/admin/src/View/Attachment/HtmlView.php (global_namespace_import, no_unused_imports)
   6) /usr/src/Projects/DPAttachments/com_dpattachments/admin/src/View/Attachments/HtmlView.php (global_namespace_import, no_unused_imports)
   7) /usr/src/Projects/DPAttachments/com_dpattachments/admin/src/Table/AttachmentTable.php (global_namespace_import, no_unused_imports)
   8) /usr/src/Projects/DPAttachments/com_dpattachments/admin/src/Extension/DPAttachmentsComponent.php (global_namespace_import, no_unused_imports)
   9) /usr/src/Projects/DPAttachments/com_dpattachments/admin/src/Controller/AttachmentController.php (global_namespace_import, no_unused_imports)
  10) /usr/src/Projects/DPAttachments/tests/src/Support/_generated/AcceptanceTesterActions.php (indentation_type, single_space_around_construct, blank_line_after_opening_tag, blank_lines_before_namespace, constant_case, curly_braces_position, no_whitespace_in_blank_line)
  11) /usr/src/Projects/DPAttachments/tests/src/Support/Step/Attachment.php (global_namespace_import, no_unused_imports)

Found 11 of 50 files that can be fixed in 2.494 seconds, 28.000 MB memory used
```

### Code fixer
The code fixer fixes the code style violations where possible with the  _phpcbf_ command and prints the result directly to the console:
```
./run-fix.sh Foo

PHP CS Fixer 3.22.0 Chips & Pizza by Fabien Potencier and Dariusz Ruminski.
PHP runtime: 8.2.2
Loaded config default from "/usr/src/Projects/DPDocker/code/scripts/../../../DPAttachments/.php-cs-fixer.php".
.FF.F...FFFFF..F.........F.....F..................                                                                                                                                               50 / 50 (100%)
Legend: .-no changes, F-fixed, S-skipped (cached or empty file), I-invalid file syntax (file ignored), E-error
   1) /usr/src/Projects/DPAttachments/com_dpattachments/site/src/View/Attachment/HtmlView.php (global_namespace_import, no_unused_imports)
   2) /usr/src/Projects/DPAttachments/com_dpattachments/site/src/View/Form/HtmlView.php (global_namespace_import, no_unused_imports)
   3) /usr/src/Projects/DPAttachments/com_dpattachments/site/src/Controller/DisplayController.php (global_namespace_import, no_unused_imports)
   4) /usr/src/Projects/DPAttachments/com_dpattachments/admin/src/Model/AttachmentModel.php (single_space_around_construct, global_namespace_import, no_unused_imports)
   5) /usr/src/Projects/DPAttachments/com_dpattachments/admin/src/View/Attachment/HtmlView.php (global_namespace_import, no_unused_imports)
   6) /usr/src/Projects/DPAttachments/com_dpattachments/admin/src/View/Attachments/HtmlView.php (global_namespace_import, no_unused_imports)
   7) /usr/src/Projects/DPAttachments/com_dpattachments/admin/src/Table/AttachmentTable.php (global_namespace_import, no_unused_imports)
   8) /usr/src/Projects/DPAttachments/com_dpattachments/admin/src/Extension/DPAttachmentsComponent.php (global_namespace_import, no_unused_imports)
   9) /usr/src/Projects/DPAttachments/com_dpattachments/admin/src/Controller/AttachmentController.php (global_namespace_import, no_unused_imports)
  10) /usr/src/Projects/DPAttachments/tests/src/Support/_generated/AcceptanceTesterActions.php (indentation_type, single_space_around_construct, blank_line_after_opening_tag, blank_lines_before_namespace, constant_case, curly_braces_position, no_whitespace_in_blank_line)
  11) /usr/src/Projects/DPAttachments/tests/src/Support/Step/Attachment.php (global_namespace_import, no_unused_imports)

Fixed 11 of 50 files in 2.532 seconds, 28.000 MB memory used
```
