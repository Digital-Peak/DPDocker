# Code task
This task runs some different code quality scripts. You can analyze and fix code violations of your code style. Additionally you can print some code stats of your extension.

The code sniffer PHP project from [squizlabs](https://github.com/squizlabs/PHP_CodeSniffer) is used for code analysis and the [phploc](https://github.com/sebastianbergmann/phploc) project from Sebastian Bergmann for measuring your extension.

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

### Code stats
To run a code stats, execute the following command:

`./run-stats.sh extension`

Example

`./run-stats.sh Foo`

## Internals
Our code style is based on PSR-2 and not the Joomla standard. So we are using this one as template. But it is possible to define your own one in your extension. Just place your preferred rule style file in your extension at the location _package/rules/phpcs.xml_ and you can overwrite the ones from us.

## Result
### Code checker
The code check prints the output of the _phpcs_ command directly to the console:
```
./run-check.sh Foo
......E............................................ 51 / 51 (100%)


FILE: ...c/Projects/Foo/com_foo/site/controllers/foo.php
--------------------------------------------------------------------------------
FOUND 1 ERROR AFFECTING 1 LINE
--------------------------------------------------------------------------------
40 | ERROR | [x] Short array syntax must be used to define arrays
--------------------------------------------------------------------------------
PHPCBF CAN FIX THE 1 MARKED SNIFF VIOLATIONS AUTOMATICALLY
--------------------------------------------------------------------------------

Time: 3.62 secs; Memory: 32.01MB
```

### Code fixer
The code fixer fixes the code style violations where possible with the  _phpcbf_ command and prints the result directly to the console:
```
./run-fix.sh Foo

PHPCBF RESULT SUMMARY
--------------------------------------------------------------------------------
FILE                                                            FIXED  REMAINING
--------------------------------------------------------------------------------
...tachments/com_foo/site/controllers/foo.php  1      0
--------------------------------------------------------------------------------
A TOTAL OF 1 ERROR WERE FIXED IN 1 FILE
--------------------------------------------------------------------------------

Time: 3.95 secs; Memory: 32.01MB
```

### Code stats
The code stats task prints the output of the _phploc_ command directly to the console:
```
./run-stats.sh Foo
phploc 5.0.0 by Sebastian Bergmann.

Directories                                         20
Files                                               40

Size
  Lines of Code (LOC)                             3010
  Comment Lines of Code (CLOC)                     474 (15.75%)
  Non-Comment Lines of Code (NCLOC)               2536 (84.25%)
  Logical Lines of Code (LLOC)                     925 (30.73%)
    Classes                                        593 (64.11%)
      Average Class Length                          32
        Minimum Class Length                         0
        Maximum Class Length                       112
      Average Method Length                          8
        Minimum Method Length                        0
        Maximum Method Length                       63
    Functions                                        0 (0.00%)
      Average Function Length                        0
    Not in classes or functions                    332 (35.89%)

Cyclomatic Complexity
  Average Complexity per LLOC                     0.33
  Average Complexity per Class                   12.67
    Minimum Class Complexity                      1.00
    Maximum Class Complexity                     42.00
  Average Complexity per Method                   4.28
    Minimum Method Complexity                     1.00
    Maximum Method Complexity                    26.00

Dependencies
  Global Accesses                                    9
    Global Constants                                 0 (0.00%)
    Global Variables                                 0 (0.00%)
    Super-Global Variables                           9 (100.00%)
  Attribute Accesses                               368
    Non-Static                                     365 (99.18%)
    Static                                           3 (0.82%)
  Method Calls                                     812
    Non-Static                                     456 (56.16%)
    Static                                         356 (43.84%)

Structure
  Namespaces                                         1
  Interfaces                                         0
  Traits                                             0
  Classes                                           18
    Abstract Classes                                 0 (0.00%)
    Concrete Classes                                18 (100.00%)
  Methods                                           64
    Scope
      Non-Static Methods                            52 (81.25%)
      Static Methods                                12 (18.75%)
    Visibility
      Public Methods                                44 (68.75%)
      Non-Public Methods                            20 (31.25%)
  Functions                                          0
    Named Functions                                  0 (0.00%)
    Anonymous Functions                              0 (0.00%)
  Constants                                          0
    Global Constants                                 0 (0.00%)
    Class Constants                                  0 (0.00%)
```
