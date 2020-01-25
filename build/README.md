# Build task
This task runs a script which builds installable packages of an extension.

## Prerequisites
The extension needs a package folder with a build.json file which describes the packages.

## Execute
To run a build, execute the following command:

`./run.sh extension [version]`

Example

`./run.sh Foo 1.3.2`

The version attribute is optional. If set then automatic versioning is performed as described below.

## Internals
The build task copies the whole extension to a temp folder inside the build folder. There it runs the _composer install_ and _npm install/build_ task before creating the package, so we have a clean state in the package.

### Automatic version and package date
That you don't have to make always a search and replace with the release date and version before you ship a release, you can define them in the manifest files as follows:

```
<creationDate>DP_DEPLOY_DATE</creationDate>
<version>DP_DEPLOY_VERSION</version>
```

_DP_DEPLOY_DATE_ will then be replaced with the current date and _DP_DEPLOY_VERSION_ will then be replaced with specified version argument in the task, when the build task is executed.

## Result
The installable builds are available in the dist folder after successful execution. The file name is defined in the build.json file and contains also the version number.

## Build file documentation
The build.json file does define how the extension should be built. It is able to build different packages out of the same extension. This allows a developer to build a pro and a light version for example.

The root node contains the different packages. Each package definition contains the following properties:

- **name**  
The name of the package zip file.
- **originalManifestFileName**  
The file name in the package folder of the package manifest.
- **substituteManifestFileName**  
The name of the manifest in the installable zip file.
- **extensions**  
The extensions property contains different substitutes per extension. For example the script.php file should be in the admin folder on descovery, but in the installable file in the root folder. Then you can define here different paths in the local file system and their target in the zip file. Also if there should be files or folder excluded. This is handy if you want to exclude different libraries in different installable files or deliver only a subset of views in the light version.

Example:
```
{
  "packages": [
    {
      "name": "Foo-Premium",
      "originalManifestFileName": "pkg_foo-premium",
      "substituteManifestFileName": "pkg_foo",
      "extensions": [
        {
          "name": "com_foo",
          "substitutes": [
            {
              "original": "admin/foo.xml",
              "replace": "foo.xml"
            },
            {
              "original": "admin/script.php",
              "replace": "script.php"
            }
          ]
        }
      ]
    },
    {
      "name": "Foo-Free",
      "originalManifestFileName": "pkg_foo-free",
      "substituteManifestFileName": "pkg_foo",
      "extensions": [
        {
          "name": "com_foo",
          "excludes": [
            "site/views/pro"
          ],
          "substitutes": [
            {
              "original": "admin/foo-free.xml",
              "replace": "foo.xml"
            },
            {
              "original": "admin/script.php",
              "replace": "script.php"
            }
          ]
        }
      ]
    }
  ]
}
```
