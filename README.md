# Cigam

Cigam is small script to automate increasing android and iOS project versions with one command.

## Example usage

```shell --increment-build``` Increase build number.

```shell --increment-version``` Increase build number and patch.

```shell --increment-version 1.0.554``` Set specified version of project. This also increase build number.

```shell -h``` To list all commands.

## How to setup

Add cigam to package.json

```
  "dependencies": {
    "cigam": "^1.0.16"
  },
  ```
And link
```npm link cigam```

Create version.properties, [you can copy this file] and use it as template. Remember to use fields defined from template, only those are supported.

[you can copy this file]: https://github.com/martin-przystalka/Cigam/blob/master/version.properties




Modify ```build.gradle``` file to look like this:

    android {
      //...
      def versionPropsFile = file('version.properties')

      if (versionPropsFile.canRead()) {
          def Properties versionProps = new Properties()
          versionProps.load(new FileInputStream(versionPropsFile))
          def major = versionProps['VERSION_NAME_MAJOR'].toInteger()
          def minor = versionProps['VERSION_NAME_MINOR'].toInteger()
          def patch = versionProps['VERSION_NAME_PATCH'].toInteger()
          def version = major + "." + minor + "." + patch

          defaultConfig {
              //...
              versionCode versionProps['VERSION_CODE'].toInteger()
              versionName version
              //...
          }
      } else {
          throw new GradleException("Could not read version.properties!")
      }
    //...



