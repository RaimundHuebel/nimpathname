# Nim Pathname

[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://github.com/yglukhov/nimble-tag)



## Introduction

This is a port of the pathname library from the ruby-standard-library.



## Get Started

Install Nim Pathname

   ```bash
   $ nimble install nimpathname
   ```

Use Nim Pathname

   ```nim
   import pathname

   # Construct pathname ...
   let aPath        = Pathname.new("/var/lib/a_directory/")
   let currPath     = Pathname.new()
   let tempPath     = Pathname.fromTempDir()
   let appDirPath   = Pathname.fromAppDir()
   let rootPath     = Pathname.fromRootDir()
   let userHomePath = Pathname.fromUserHomeDir()
   let userDataPath = Pathname.fromUserConfigDir()

   # Convert back to String ...
   echo aPath.toPathStr()

   # Working with Pathname
   echo aPath.isAbsolute()
   echo aPath.isRelative()
   echo aPath.isExisting()
   echo aPath.isNotExisting()
   echo aPath.isRegularFile()
   echo aPath.isDirectory()
   echo aPath.isSymlink()
   echo aPath.isPipeFile()
   echo aPath.isDeviceFile()

   userDataPath.join("MyApp").createDirectory()
   userDataPath.join("MyApp","config.ini").touch()

   echo Pathname.fromRootDir("bin","cat").isExisting()
   echo Pathname.fromRootDir("bin","cat").isExecutable()

   echo Pathname.fromUserConfigDir("MyApp","config.ini").fileSizeInBytes()
   echo Pathname.fromUserConfigDir("MyApp","config.ini").userId()

   echo Pathname.fromUserConfigDir("MyApp","config.ini").getLastAccessTime()
   echo Pathname.fromUserConfigDir("MyApp","config.ini").getLastChangeTime()
   echo Pathname.fromUserConfigDir("MyApp","config.ini").getLastStatusChangeTime()

   echo aPath("..//./config.d/././//./config.ini).cleanpath()
   echo aPath("..//./config.d/././//./config.ini).normalize()

   # Example: Create Application-Config-Directory ...
   Pathname.fromUserConfigDir("MyApp").tap do (confDir: Pathname):
     confDir.createDirectory(mode=0o750)
     confDir.createyDirectory("exports")
     confDir.createEmptyDirectory("imports")
     confDir.createEmptyDirectory("run")
     confDir.createRegularFile("config.ini")
     confDir.createFile("app.pid")
     confDir.touch("run/")
     confDir.touch("last_started")
     ...
     confDir.removeRegularFile("app.pid")
     confDir.removeEmptyDirectory("exports")
     confDir.removeDirectoryTree("imports")
     ...
     confDir.remove()
   ```

## Develop

### Running Tests

   ```bash
   $ nimble test
   ```



## Links

- [Repository of Nim Pathname](https://github.com/RaimundHuebel/NimPathname)
