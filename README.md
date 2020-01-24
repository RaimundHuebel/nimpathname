# Nim Pathname

[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://github.com/yglukhov/nimble-tag)



## Introduction

This is a port of the pathname library from the ruby-standard-library.



## Get Started

Install Nim Pathname

   ```bash
   $ nimble install pathname
   ```

Use Nim Pathname

   ```nim
   import pathname

   let aPath        = Pathname.new("/var/lib/a_directory/")
   let currPath     = Pathname.new()
   let tempPath     = Pathname.fromTempDir()
   let appDirPath   = Pathname.fromAppDir()
   let rootPath     = Pathname.fromRootDir()
   let userHomePath = Pathname.fromUserHomeDir()
   let userDataPath = Pathname.fromUserConfigDir()

   echo aPath.toPathStr()
   ```

## Develop

### Running Tests

   ```bash
   $ nimble test
   ```



## Links

- [Repository of Nim Pathname](https://github.com/RaimundHuebel/NimPathname)
