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

   let aPath        = newPathname("/var/lib/a_directory/")
   let currPath     = newPathname()
   let tempPath     = pathnameFromTempDir()
   let appDirPath   = pathnameFromAppDir()
   let rootPath     = pathnameFromRootDir()
   let userHomePath = pathnameFromUserHomeDir()
   let userDataPath = pathnameFromUserConfigDir()

   echo aPath.toPathStr()
   ```

## Develop

### Running Tests

   ```bash
   $ nimble test
   ```



## Links

- [Repository of Nim Pathname](https://github.com/RaimundHuebel/NimPathname)
