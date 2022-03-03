###
# Pathname-Module inspired by pathname from Ruby-Stdlib.
#
# license: MIT
# author:  Raimund Hübel <raimund.huebel@googlemail.com>
#
# ## compile and run + tooling:
#
#   ## Separated compile and run steps ...
#   $ nim compile [--out:pathname.exe] pathname.nim
#   $ ./pathname[.exe]
#
#   ## In one step ...
#   $ nim compile [--out:pathname.exe] --run pathname.nim
#
#   ## Optimal-Compile ...
#   $ nim compile -d:release --opt:size pathname.nim
#   $ strip --strip-all pathname  #Funktioniert wirklich
#   $ upx --best pathname
#
#   ## Run Tests on Change ...
#   $ find src/ tests/ -name '*.nim' | entr bash -c "nim compile --run tests/pathname_000_test"
#
# ## See also:
# * `https://ruby-doc.org/stdlib-2.7.0/libdoc/pathname/rdoc/Pathname.html`
# * `https://ruby-doc.org/core-2.7.0/File.html`
# * `https://ruby-doc.org/core-2.7.0/Dir.html`
# * `https://ruby-doc.org/core-2.7.0/FileTest.html`
###


#{. experimental: "codeReordering" .}



## Module for Handling with Directories and Pathnames.
##
## ## Example
## .. code-block:: Nim
##   import pathname
##   let pathname = Pathname.new()
##   echo pathname.toPathStr
##   ...


import os
import options
import times
#import sequtils
import pathname/file_utils


#when defined(Posix):
#    import posix


when defined(Windows):
    import sequtils


## Import/Export FileType-Implementation ...
import pathname/file_type
export pathname.file_type


## Import/Export FileInfo-Implementation ...
import pathname/file_status
export pathname.file_status

## Export os.FileInfo
export os.FileInfo



## Export Support-Matrix, Exceptions ...
export pathname.file_utils.AreSymlinksSupported
export pathname.file_utils.ArePipesSupported
export pathname.file_utils.AreDeviceFilesSupported
export pathname.file_utils.NotSupportedError



### Import: realpath (@see module posix)
#when defined(Posix):
#
#    const PATH_MAX = 4096'u
#    proc posixRealpath(name: cstring, resolved: cstring): cstring {. importc: "realpath", header: "<stdlib.h>" .}
#
#else:
#    # TODO: Support other Plattforms ...
#    {.fatal: "The current plattform does not support posix - realpath!".}


#proc canonicalizePathString(pathstr: string): string =
#    ## Liefert den canonischen Pfad von den gegebenen Pfad.
#    ## Dabei muss das Letzte Element des Pfades existieren, sonst schlägt der Befehl fehl.
#    if pathstr == "":
#        raise newException(Exception, "invalid param: pathstr")
#    const maxSize = PATH_MAX
#    result = newString(maxSize)
#    if nil == posixRealpath(pathstr, result):
#        raiseOSError(osLastError())
#    result[maxSize.int-1] = 0.char
#    let realSize = result.cstring.len
#    result.setLen(realSize)
#    return result




type Pathname* = ref object
    ## Class for presenting Paths to files and directories,
    ## including a rich fluent API to support easy Development.
    path :string



#DEPRECATED proc new*(class: typedesc[Pathname]): Pathname =
#DEPRECATED     ## Constructs a new Pathname with the Current Directory as Path.
#DEPRECATED     ## @returns An Pathname-Instance.
#DEPRECATED     ## @usage Pathname.new()
#DEPRECATED     return Pathname(path: os.getCurrentDir())



proc new*(class: typedesc[Pathname], path: string): Pathname {.noSideEffect.} =
    ## Constructs a new Pathname, with the Pathname direct.
    ## @param path The Directory which shall be listed.
    ## @returns An Pathname-Instance.
    ## @usage Pathname.new("/a/sample/path")
    return Pathname(path: path)



proc new*(class: typedesc[Pathname], basePath: string, pathComponent1: string, additionalPathComponents: varargs[string]): Pathname {.noSideEffect.} =
    ## Constructs a new Pathname, from a base-path and additional path-components.
    ## This should be the prefered way to construct plattform independent Pathnames.
    ## @param path The Directory which shall be listed.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A string containing the joined Path.
    ## @returns An Pathname-Instance containing the joined Path.
    ## @usage Pathname.new("/a/sample/path", "run")
    ## @usage Pathname.new("/a/sample/path", "run", "exports")
    return Pathname.new(file_utils.joinPath(basePath, pathComponent1, additionalPathComponents))



proc fromPathStr*(class: typedesc[Pathname], path: string): Pathname {.inline,noSideEffect.} =
    ## Constructs a new Pathname, with the Pathname direct.
    ## @param path The Directory which shall be listed.
    ## @returns An Pathname-Instance.
    ## @usage Pathname.fromPathStr("/a/sample/path")
    return Pathname.new(path)



proc fromPathStr*(class: typedesc[Pathname], basePath: string, pathComponent1: string, additionalPathComponents: varargs[string]): Pathname {.inline,noSideEffect.} =
    ## Constructs a new Pathname, from a base-path and additional path-components.
    ## This should be the prefered way to construct plattform independent Pathnames.
    ## @param path The Directory which shall be listed.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A string containing the joined Path.
    ## @returns An Pathname-Instance containing the joined Path.
    ## @usage Pathname.fromPathStr("/a/sample/path", "run")
    ## @usage Pathname.fromPathStr("/a/sample/path", "run", "exports")
    return Pathname.new(basePath, pathComponent1, additionalPathComponents)



proc fromCurrentWorkDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Current Work Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromCurrentWorkDir()
    return Pathname.new(file_utils.getCurrentWorkDirPath())


proc fromCurrentWorkDir*(class: typedesc[Pathname], pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Constructs a new Pathname with the Current Work Directory as Path.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromCurrentWorkDir("run")
    ## @usage Pathname.fromCurrentWorkDir("run", "backups")
    return Pathname.new(file_utils.joinPath(file_utils.getCurrentWorkDirPath(), pathComponent1, additionalPathComponents))


proc fromAppFile*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the App File as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromAppFile()
    return Pathname.new(file_utils.getAppFilePath())


proc fromAppDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the App Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromAppDir()
    return Pathname.new(file_utils.getAppDirPath())


proc fromAppDir*(class: typedesc[Pathname], pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Constructs a new Pathname with the App Directory as Path.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromAppDir("run")
    ## @usage Pathname.fromAppDir("run", "backups")
    return Pathname.new(file_utils.joinPath(file_utils.getAppDirPath(), pathComponent1, additionalPathComponents))


proc fromTempDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Temp Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromTempDir()
    return Pathname.new(file_utils.getTempDirPath())


proc fromTempDir*(class: typedesc[Pathname], pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Constructs a new Pathname with the Temp Directory as Path.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromTempDir("run")
    ## @usage Pathname.fromTempDir("run", "backups")
    return Pathname.new(file_utils.joinPath(file_utils.getTempDirPath(), pathComponent1, additionalPathComponents))


proc fromRootDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Temp Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromRootDir()
    return Pathname.new(file_utils.getRootDirPath())


proc fromRootDir*(class: typedesc[Pathname], pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Constructs a new Pathname with the Temp Directory as Path.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromRootDir("run")
    ## @usage Pathname.fromRootDir("run", "backups")
    return Pathname.new(file_utils.joinPath(file_utils.getRootDirPath(), pathComponent1, additionalPathComponents))


proc fromUserConfigDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Config Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromUserConfigDir()
    return Pathname.new(file_utils.getUserConfigDirPath())


proc fromUserConfigDir*(class: typedesc[Pathname], pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Constructs a new Pathname with the Config Directory as Path.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromUserConfigDir("run")
    ## @usage Pathname.fromUserConfigDir("run", "backups")
    return Pathname.new(file_utils.joinPath(file_utils.getUserConfigDirPath(), pathComponent1, additionalPathComponents))


proc fromUserHomeDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Config Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromUserHomeDir()
    return Pathname.new(os.getHomeDir())


proc fromUserHomeDir*(class: typedesc[Pathname], pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Constructs a new Pathname with the Config Directory as Path.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromUserHomeDir("run")
    ## @usage Pathname.fromUserHomeDir("run", "backups")
    return Pathname.new(file_utils.joinPath(os.getHomeDir(), pathComponent1, additionalPathComponents))


proc fromEnvVar*(class: typedesc[Pathname], envVar: string): Option[Pathname] =
    ## Constructs a new Pathname with the value of the given EnvVar, may return none(Pathname).
    ## The usage of this constructor may need an explicit import of options-Module.
    ## @param envVar The name of the environment variable.
    ## @returns A some(Pathname) containing the Path of the given EnvVar if defined.
    ## @returns none(Pathname) if the given EnvVar does not exist.
    ## @usage Pathname.fromEnvVar("PROJECT_PATH")
    let envPath = file_utils.getEnvVarPath(envVar)
    if unlikely(envPath.isNone()):
        return none(Pathname)
    return some(Pathname.new(envPath.get()))


proc fromEnvVarOrDefault*(class: typedesc[Pathname], envVar: string, defaultPath: string): Pathname =
    ## Constructs a new Pathname with the value of the given EnvVar, may return defaultPath.
    ## @param envVar The name of the environment variable.
    ## @returns A Pathname containing the Path of the given EnvVar if defined or defaultPath if not.
    ## @usage Pathname.fromEnvVar("RUN_DIRECTORY", "/tmp/run")
    ##
    return Pathname.new(file_utils.getEnvVarOrDefaultPath(envVar, defaultPath))


proc fromEnvVarOrNil*(class: typedesc[Pathname], envVar: string): Pathname =
    ## Constructs a new Pathname with the value of the given EnvVar, may return nil.
    ## @param envVar The name of the environment variable.
    ## @returns A Pathname containing the Path of the given EnvVar if defined.
    ## @returns nil if the given EnvVar does not exist.
    ## @usage Pathname.fromEnvVarOrNil("PROJECT_PATH")
    let envPath = file_utils.getEnvVarPath(envVar)
    if unlikely(envPath.isNone()):
        return nil
    return Pathname.new(envPath.get())


proc fromNimbleDir*(class: typedesc[Pathname], additionalPathComponents: varargs[string]): Pathname =
    ## Constructs a new Pathname with the default Nimble-Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromNimbleDir()
    ## @usage Pathname.fromNimbleDir("bin")
    ## @usage Pathname.fromNimbleDir("pkgs")
    return Pathname.new(file_utils.getNimbleDirPath(additionalPathComponents))



proc toPathStr*(self :Pathname): string {.inline.} =
    ## Converts a Pathname to a String for User-Presentation-Purposes (for End-User).
    return self.path


proc toString*(self: Pathname): string  {.inline.} =
    ## Converts a Pathname to a String for User-Presentation-Purposes (for End-User).
    return self.path


proc `$`*(self :Pathname): string {.inline.} =
    ## Converts a Pathname to a String for User-Presentation-Purposes (for End-User).
    return self.path



proc inspect*(self: Pathname) :string =
    ## Converts a Pathname to a String for Diagnostic-Purposes (for Developer).
    return "Pathname(\"" & self.path & "\")"





proc isAbsolute*(self: Pathname): bool =
    ## Tells if the Pathname contains an absolute path.
    return file_utils.isAbsolutePath(self.path)



proc isRelative*(self: Pathname): bool =
    ## Tells if the Pathname contains an relative path.
    return not file_utils.isAbsolutePath(self.path)



proc parent*(self :Pathname): Pathname =
    ## Returns the Parent-Directory of the Pathname.
    return Pathname.new(file_utils.parentPath(self.path))



proc join*(self: Pathname, pathComponents: varargs[string]): Pathname =
    ## Returns a new Pathname joined with the additional path components.
    ## @param pathComponents Additional Path-Components which shall be added to the given path.
    #return aPathname.join("run")
    #return aPathname.join("run", "backups")
    return Pathname.new(file_utils.joinPath(self.path, pathComponents))



#TODO: safeJoin -> ein Path-Join der hochnavigation verbietet, gedacht für Pfadoperationen von unsicheren Quellen getriggert.


proc joinNormalized*(self: Pathname, pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Returns a new normalized Pathname joined with the additional path components.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @alternative .join(...).normalize()
    #return aPathname.joinNormalized("run")
    #return aPathname.joinNormalized("run", "backups")
    return Pathname.new(file_utils.normalizePath(file_utils.joinPath(self.path, pathComponent1, additionalPathComponents)))



proc normalize*(self: Pathname): Pathname =
    ## Returns clean pathname of self with consecutive slashes and useless dots removed.
    ## The filesystem is not accessed.
    ## @alias #cleanpath()
    ## @alias #normalize()
    ## @see https://ruby-doc.org/stdlib/libdoc/pathname/rdoc/Pathname.html#method-i-cleanpath
    let normalizedPathStr = file_utils.normalizePath(self.path)
    # Optimierung für weniger Speicherverbrauch (gib self statt new pathname zurück, wenn identisch, für weniger RAM)
    if normalizedPathStr == self.path:
        return self
    return Pathname.new(normalizedPathStr)



proc cleanpath*(self: Pathname): Pathname {.inline.} =
    ## Returns clean pathname of self with consecutive slashes and useless dots removed.
    ## The filesystem is not accessed.
    ## @alias #cleanpath()
    ## @alias #normalize()
    ## @see https://ruby-doc.org/stdlib/libdoc/pathname/rdoc/Pathname.html#method-i-cleanpath
    return self.normalize()



proc dirname*(self: Pathname): Pathname =
    ## @returns the Directory-Part of the given Pathname as Pathname.
    return Pathname.new(file_utils.extractDirname(self.path))



proc basename*(self: Pathname): Pathname =
    ## @returns the Filepart-Part of the given Pathname as Pathname.
    return Pathname.new(file_utils.extractBasename(self.path))



proc extname*(self: Pathname): string =
    ## @returns the File-Extension-Part of the given Pathname as string.
    return file_utils.extractExtension(self.path)



proc fileType*(self: Pathname): FileType =
    ## Returns the FileType of the current Pathname. And tells if the underlying File-System-Entry
    ## is existing, and if it is either a Regular File, Directory, Symlink, or Device-File.
    ## See also: fileInfo()
    ## See also: fileStatus()
    ## See also: fileType()
    return file_utils.getFileType(self.path)



proc fileInfo*(self: Pathname): os.FileInfo =
    ## Returns an os.FileInfo of the current Pathname. Providing additional infos about the underlying File-System-Entry.
    ## The returned FileInfo-Structure is the standard-version of the nim-runtime. If some more functionality is
    ## needed see #fileStatus() which provides a more advanced interface to get information of the file.
    ## See also: fileInfo()
    ## See also: fileStatus()
    ## See also: fileType()
    ## See also: https://nim-lang.org/docs/os.html#FileInfo
    return file_utils.getFileInfo(self.path)



proc fileStatus*(self: Pathname): FileStatus =
    ## Returns the FileStatus of the current Pathname. Providing additional infos about the underlying File-System-Entry.
    ## The returned FileStatus is a custom implementation of the kind of os.FileInfo with extended functionality.
    ## See also: fileInfo()
    ## See also: fileStatus()
    ## See also: fileType()
    return file_utils.getFileStatus(self.path)



proc isExisting*(self: Pathname): bool =
    ## Returns true if the path directs to an existing file-system-entity like a file, directory, device, symlink, ...
    ## Returns false otherwise.
    ## See also:
    ## * `isExisting() proc <#isExisting,Pathname>`_
    ## * `isNotExisting() proc <#isNotExisting,Pathname>`_
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.isExisting(self.path)



proc isNotExisting*(self: Pathname): bool =
    ## Returns true if the path DOES NOT direct to an existing and accessible file-system-entity.
    ## Returns false otherwise
    ## See also:
    ## * `isExisting() proc <#isExisting,Pathname>`_
    ## * `isNotExisting() proc <#isNotExisting,Pathname>`_
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.isNotExisting(self.path)



proc isUnknownFileType*(self: Pathname): bool =
    ## @returns true if type the File-System-Entry is of unknown type.
    ## @returns false otherwise
    return file_utils.isUnknownFileType(self.path)



proc isRegularFile*(self: Pathname): bool =
    ## Returns true if the path directs to a file, or a symlink that points at a file,
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.isRegularFile(self.path)



proc isDirectory*(self: Pathname): bool =
    ## Returns true if the path directs to a directory, or a symlink that points at a directory,
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.isDirectory(self.path)



proc isSymlink*(self: Pathname): bool =
    ## Returns true if the path directs to a symlink.
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.isSymlink(self.path)



proc isDeviceFile*(self: Pathname): bool =
    ## Returns true if the path directs to a device-file (either block or character).
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.isDeviceFile(self.path)



proc isCharacterDeviceFile*(self: Pathname): bool =
    ## Returns true if the path directs to a block-device-file.
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.isCharacterDeviceFile(self.path)



proc isBlockDeviceFile*(self: Pathname): bool =
    ## Returns true if the path directs to a block-device-file.
    ## Returns false otherwise.
    ## See also: fileStatus()
    ## See also: fileType()
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    return file_utils.isBlockDeviceFile(self.path)



proc isSocketFile*(self: Pathname): bool =
    ## Returns true if the path directs to a unix socket file.
    ## Returns false otherwise.
    ## See also: fileStatus()
    ## See also: fileType()
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    return file_utils.isSocketFile(self.path)



proc isPipeFile*(self: Pathname): bool =
    ## Returns true if the path directs to a named pipe/fifo-file.
    ## Returns false otherwise.
    ## See also: fileStatus()
    ## See also: fileType()
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    return file_utils.isPipeFile(self.path)



proc isHidden*(self: Pathname): bool =
    ## Returns true if the path directs to an existing hidden file/directory/etc.
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    return file_utils.isHidden(self.path)



proc isVisible*(self: Pathname): bool =
    ## Returns true if the path directs to an existing visible file/directory/etc (eg. is NOT hidden).
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    return file_utils.isVisible(self.path)



proc isZeroSizeFile*(self: Pathname): bool =
    ## @returns true if the path directs to an existing file with a file-size of zero.
    ## @returns false otherwise
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    return file_utils.isZeroSizeFile(self.path)



proc fileSizeInBytes*(self: Pathname): int64 =
    ## @returns the FileSize of the File-System-Entry in Bytes.
    ## @returns -1 if the FileSize could not be determined.
    return file_utils.getFileSizeInBytes(self.path)



proc ioBlockSizeInBytes*(self: Pathname): int64 =
    ## @returns the Size of an IO-Block of the File-System-Entry in Bytes.
    ## @returns -1 if the BlockSize could not be determined.
    return file_utils.getIoBlockSizeInBytes(self.path)


proc ioBlockCount*(self: Pathname): int64 =
    ## @returns the count of assigned IO-Blocks of the File-System-Entry.
    ## @returns -1 if the IoBlockCount could not be determined.
    return file_utils.getIoBlockCount(self.path)



proc userId*(self: Pathname): int32 =
    ## @returns an int >= 0 containing the UserId which is assigned to the existing FileSystemEntry.
    ## @returns -1 otherwise
    return file_utils.getUserId(self.path)



proc groupId*(self: Pathname): int32 =
    ## @returns an int >= 0 containing the GroupId which is assigned to the existing FileSystemEntry.
    ## @returns -1 otherwise
    return file_utils.getGroupId(self.path)



proc countHardlinks*(self: Pathname): int32 =
    ## @returns the count of hardlinks of the File-System-Entry.
    ## @returns -1 if the count could not be determined.
    return file_utils.getCountHardlinks(self.path)



proc hasSetUidBit*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and has the Set-Uid-Bit set.
    ## @returns false otherwise
    return file_utils.hasSetUidBit(self.path)



proc hasSetGidBit*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and has the Set-Gid-Bit set.
    ## @returns false otherwise
    return file_utils.hasSetGidBit(self.path)



proc hasStickyBit*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and has the Sticky-Bit set.
    ## @returns false otherwise
    return file_utils.hasStickyBit(self.path)



proc getLastAccessTime*(self: Pathname): times.Time =
    ## @returns the Time when the stated Path was last accessed.
    ## @returns 0.Time if the FileStat is in Error-State or the FileType does not support Prefered Block-Size.
    return file_utils.getLastAccessTime(self.path)



proc getLastChangeTime*(self: Pathname): times.Time =
    ## @returns the Time when the content of the stated Path was last changed.
    ## @returns 0.Time if the FileStat is in Error-State.
    return file_utils.getLastChangeTime(self.path)



proc getLastStatusChangeTime*(self: Pathname): times.Time =
    ## @returns the Time when the status of stated Path was last changed.
    ## @returns 0.Time if the FileStat is in Error-State.
    return file_utils.getLastStatusChangeTime(self.path)



proc isUserOwned*(self: Pathname): bool =
    ## @returns true
    ##     if the File-System-Entry exists and the effective userId of the
    ##     current process is the owner of the file.
    ## @returns false otherwise
    return file_utils.isUserOwned(self.path)



proc isGroupOwned*(self: Pathname): bool =
    ## @returns true
    ##     if the File-System-Entry exists and the effective groupId of the
    ##     current process is the owner of the file.
    ## @returns false otherwise
    return file_utils.isGroupOwned(self.path)



proc isGroupMember*(self: Pathname): bool =
    ## @returns true if the named file exists and the effective user is member to the group of the the file.
    ## @returns false otherwise
    return file_utils.isGroupMember(self.path)



proc isReadable*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and is readable by any means for the current process.
    ## @returns false otherwise
    return file_utils.isReadable(self.path)



proc isReadableByUser*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and is readable by direct user ownership of the current process.
    ## @returns false otherwise
    return file_utils.isReadableByUser(self.path)



proc isReadableByGroup*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and is readable by group ownership of the current process.
    ## @returns false otherwise
    return file_utils.isReadableByGroup(self.path)



proc isReadableByOther*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and is readable by any other means of the current process.
    ## @returns false otherwise
    return file_utils.isReadableByOther(self.path)



proc isWritable*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and is writable by any means for the current process.
    ## @returns false otherwise
    return file_utils.isWritable(self.path)



proc isWritableByUser*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and is writable by direct user ownership of the current process.
    ## @returns false otherwise
    return file_utils.isWritableByUser(self.path)



proc isWritableByGroup*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and is writable by group ownership of the current process.
    ## @returns false otherwise
    return file_utils.isWritableByGroup(self.path)



proc isWritableByOther*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and is writable by any other means of the current process.
    ## @returns false otherwise
    return file_utils.isWritableByOther(self.path)



proc isExecutable*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and is executable by any means for the current process.
    ## @returns false otherwise
    return file_utils.isExecutable(self.path)



proc isExecutableByUser*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and is executable by direct user ownership of the current process.
    ## @returns false otherwise
    return file_utils.isExecutableByUser(self.path)



proc isExecutableByGroup*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and is executable by group ownership of the current process.
    ## @returns false otherwise
    return file_utils.isExecutableByGroup(self.path)



proc isExecutableByOther*(self: Pathname): bool =
    ## @returns true if File-System-Entry exists and is executable by any other means of the current process.
    ## @returns false otherwise
    return file_utils.isExecutableByOther(self.path)



proc isMountpoint*(self: Pathname): bool =
    ## @returns if File-System-Entry exists and is a mountpoint.
    ## @returns false otherwise
    return file_utils.isMountpoint(self.path)



proc readAll*(self: Pathname): string {.inline,raises: [IOError].} =
    ## @returns Returns ALL data from the current File (Regular, Character Devices, Pipes).
    ## @raises An IOError if the file could not be read.
    return file_utils.readAll(self.path)



proc read*(self: Pathname): string {.inline,raises: [IOError].} =
    ## @returns Returns ALL data from the current File (Regular, Character Devices, Pipes).
    ## @raises An IOError if the file could not be read.
    return self.readAll()
    #return file_utils.read(self.path)



proc read*(self: Pathname, length: Natural, offset: int64 = -1): string {.inline,raises: [IOError].} =
    ## @returns Returns length bytes of data from the current File (Regular, Character Devices, Pipes).
    ## @raises An IOError if the file could not be read.
    return file_utils.read(self.path, length, offset)



proc open*(self: Pathname, mode: FileMode = FileMode.fmRead; bufSize: int = -1): File {.inline,raises: [IOError].} =
    ## Opens the given File-System-Entry with given mode (default: Readonly) .
    ## @raises An IOError if something went wrong.
    return file_utils.open(self.path, mode, bufSize)



proc touch*(self: Pathname, optionalPathComponents: varargs[string], mode: uint32 = 0o664): Pathname {.discardable,raises: [IOError].} =
    ## Updates modification time (mtime) and access time (atime) of the File-System-Entries in list.
    ## If no File-System-Entry exists, then a Regular File will be created, with the given unix-access-mode.
    ## @raises An IOError if something went wrong.
    ## The difference to #createFile is, that #touch does not throw an error if the target is not a regular file.
    var targetPathname = self
    if optionalPathComponents.len > 0:
        targetPathname = self.join(optionalPathComponents)
    file_utils.touch(targetPathname.path, mode)
    return self



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - tap()
#-----------------------------------------------------------------------------------------------------------------------



proc tap*(self: Pathname, tapFn: proc (pathname: Pathname)): Pathname {.discardable,inline.} =
    ## Calls the given lambda-proc with self, enabling the user to construct directory-construction in an descriptive manner.
    tapFn(self)
    return self



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createRegularFile()/removeRegularFile()
#-----------------------------------------------------------------------------------------------------------------------



proc createRegularFile*(self: Pathname, optionalPathComponents: varargs[string], mode: uint32 = 0o664): Pathname {.discardable,raises: [IOError].} =
    ## Creates an empty regular File.
    ## If the fs-entry already exists and it is a regular file nothing happens.
    ## If the fs-entry already exists but is not a regular file an IOError is raised.
    ## @raises An IOError if the fs-entry already exists but is not a regular file.
    ## The difference to #touch is, that #touch does not throw an error if the target is not a regular file.
    var targetPathname = self
    if optionalPathComponents.len > 0:
        targetPathname = self.join(optionalPathComponents)
    file_utils.createRegularFile(targetPathname.path, mode)
    return self



proc removeRegularFile*(self: Pathname, optionalPathComponents: varargs[string]): Pathname {.discardable,raises: [IOError].} =
    ## Removes a regular file and only that.
    ## @raises An IOError if the referenced FS-Entry is existing but is not a regular file, or could not be deleted.
    # @see https://stackoverflow.com/questions/15335223/what-happens-when-unlink-a-directory/15335559#15335559
    # @see man 2 unlink
    var targetPathname = self
    if optionalPathComponents.len > 0:
        targetPathname = self.join(optionalPathComponents)
    file_utils.removeRegularFile(targetPathname.path)
    return self



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createFile()/removeFile()
#-----------------------------------------------------------------------------------------------------------------------



proc createFile*(self: Pathname, optionalPathComponents: varargs[string], mode: uint32 = 0o664): Pathname {.inline,discardable,raises: [IOError],inline.} =
    ## Creates an empty regular File.
    ## If the fs-entry already exists and it is a regular file nothing happens.
    ## If the fs-entry already exists but is not a regular file an IOError is raised.
    ## @raises An IOError if the fs-entry already exists but is not a regular file.
    ## The difference to #touch is, that #touch does not throw an error if the target is not a regular file.
    ## Alias:
    ## * `createFile() proc <#createFile,Pathname>`_
    ## * `createRegularFile() proc <#createRegularFile,Pathname>`_
    return self.createRegularFile(optionalPathComponents, mode=mode)



proc removeFile*(self: Pathname): Pathname {.inline,discardable,raises: [IOError].} =
    ## Removes a file but no directories like regular-, fifo-, link-, device-files.
    ## This proc differs from removeRegularFile(), that it removes every file based type (regular, link, pipe, devices).
    ## @raises An IOError if the referenced FS-Entry is existing but is not a regular file, link, pipe, or device.
    ## @raises An IOError if the referenced FS-Entry could not be removed (due permissions).
    # @see https://stackoverflow.com/questions/15335223/what-happens-when-unlink-a-directory/15335559#15335559
    # @see man 2 unlink
    file_utils.removeFile(self.path)
    return self



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createDirectory()/removeDirectory()
#-----------------------------------------------------------------------------------------------------------------------



proc createDirectory*(self: Pathname, optionalPathComponents: varargs[string], mode: uint32 = 0o775): Pathname {.discardable,raises: [IOError].} =
    ## Creates an empty Directory.
    ## If the fs-entry already exists and it is a directory nothing happens.
    ## If the fs-entry already exists but is not a directory an IOError is raised.
    ## @param mode The unix-Mode (OPTIONAL, default: ugo=rwx respecting the umask)
    ## @raises An IOError if the fs-entry already exists but is not a directory or the directory could not be created.
    ## Alias:
    ## * `createDirectory() proc <#createDirectory,Pathname>`_
    ## * `createEmptyDirectory() proc <#createEmptyDirectory,Pathname>`_
    var targetPathname = self
    if optionalPathComponents.len > 0:
        targetPathname = self.join(optionalPathComponents)
    file_utils.createEmptyDirectory(targetPathname.path, mode)
    return self



proc removeDirectory*(self: Pathname, optionalPathComponents: varargs[string], isRecursive: bool = false): Pathname {.discardable,raises: [IOError].} =
    ## Removes an directory.
    ## @raises An IOError if the referenced FS-Entry exists but is not an empty directory (when isRecursive == false, like the default)
    ## @raises An IOError if the referenced FS-Entry is a directory or could not be deleted (not empty, no permission).
    ## @param isRecursive Tells if the Directory shall be recursive removed (OPTIONAL, default: false)
    ## See also:
    ## * `removeDirectory() proc <#removeDirectory,Pathname>`_
    ## * `removeEmptyDirectory() proc <#removeEmptyDirectory,Pathname>`_
    ## * `removeDirectoryTree() proc <#removeDirectoryTree,Pathname>`_
    # @see https://stackoverflow.com/questions/15335223/what-happens-when-unlink-a-directory/15335559#15335559
    # @see man 2 rmdir
    var targetPathname = self
    if optionalPathComponents.len > 0:
        targetPathname = self.join(optionalPathComponents)
    file_utils.removeDirectory(targetPathname.path, isRecursive)
    return self



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createEmptyDirectory()/removeEmptyDirectory()
#-----------------------------------------------------------------------------------------------------------------------



proc createEmptyDirectory*(self: Pathname, optionalPathComponents: varargs[string], mode: uint32 = 0o775): Pathname {.discardable,raises: [IOError].} =
    ## Creates an empty Directory.
    ## If the fs-entry already exists and it is a directory nothing happens.
    ## If the fs-entry already exists but is not a directory an IOError is raised.
    ## @raises An IOError if the fs-entry already exists but is not a directory or the directory could not be created.
    ## Alias:
    ## * `createDirectory() proc <#createDirectory,Pathname>`_
    ## * `createEmptyDirectory() proc <#createEmptyDirectory,Pathname>`_
    # @see man 2 mkdir
    var targetPathname = self
    if optionalPathComponents.len > 0:
        targetPathname = self.join(optionalPathComponents)
    file_utils.createEmptyDirectory(targetPathname.path, mode)
    return self



proc removeEmptyDirectory*(self: Pathname, optionalPathComponents: varargs[string]): Pathname {.discardable,raises: [IOError].} =
    ## Removes an empty directory and only that.
    ## @raises An IOError if the referenced FS-Entry is existing but is not an empty directory, or could not be deleted.
    ## See also:
    ## * `removeDirectory() proc <#removeDirectory,Pathname>`_
    ## * `removeEmptyDirectory() proc <#removeEmptyDirectory,Pathname>`_
    ## * `removeDirectoryTree() proc <#removeDirectoryTree,Pathname>`_
    # @see https://stackoverflow.com/questions/15335223/what-happens-when-unlink-a-directory/15335559#15335559
    # @see man 2 rmdir
    var targetPathname = self
    if optionalPathComponents.len > 0:
        targetPathname = self.join(optionalPathComponents)
    file_utils.removeEmptyDirectory(targetPathname.path)
    return self




#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeDirectoryTree()
#-----------------------------------------------------------------------------------------------------------------------



proc removeDirectoryTree*(self: Pathname, optionalPathComponents: varargs[string]): Pathname {.discardable,raises: [IOError].} =
    ## Removes a directory with all its contents (eg. recursively).
    ## Please be cautious if using this proc.
    ## @see `os.removeDir() proc <#os.removeDir,string>`_
    var targetPathname = self
    if optionalPathComponents.len > 0:
        targetPathname = self.join(optionalPathComponents)
    file_utils.removeDirectoryTree(targetPathname.path)
    return self




#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createPipeFile()/removePipeFile()
#-----------------------------------------------------------------------------------------------------------------------



proc createPipeFile*(self: Pathname, optionalPathComponents: varargs[string], mode: uint32 = 0o660): Pathname {.discardable,raises: [IOError,NotSupportedError].} =
    ## Creates a named Pipe (aka Fifo).
    ## If the fs-entry already exists and it is a named pipe nothing happens.
    ## If the fs-entry already exists but is not a named pipe an IOError is raised.
    ## @param mode The unix-Mode (OPTIONAL, default: ug=rw,o= respecting the active umask)
    ## @raises An IOError if the fs-entry already exists but is not a named pipe.
    ## @raises An IOError if the fs-entry could not be created.
    # @see man 3 mkfifo
    var targetPathname = self
    if optionalPathComponents.len > 0:
        targetPathname = self.join(optionalPathComponents)
    file_utils.createPipeFile(targetPathname.path, mode)
    return self



proc removePipeFile*(self: Pathname, optionalPathComponents: varargs[string]): Pathname {.discardable,raises: [IOError,NotSupportedError].} =
    ## Removes a named pipe file and only that.
    ## @raises An IOError if the referenced FS-Entry is existing but is not a pipe file, or could not be deleted.
    # @see https://stackoverflow.com/questions/15335223/what-happens-when-unlink-a-directory/15335559#15335559
    # @see man 2 unlink
    var targetPathname = self
    if optionalPathComponents.len > 0:
        targetPathname = self.join(optionalPathComponents)
    file_utils.removePipeFile(targetPathname.path)
    return self



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createCharacterDeviceFile()/removeCharacterDeviceFile()
#-----------------------------------------------------------------------------------------------------------------------



#TODO: Testen ...
proc createCharacterDeviceFile*(self: Pathname, major: uint8, minor: uint8, mode: uint32 = 0o600): Pathname {.inline,discardable,raises: [IOError,NotSupportedError].} =
    ## Creates a character-device-file (only unix/linux).
    ## If the fs-entry already exists and it is a character-device-file, nothing happens.
    ## If the fs-entry already exists but is not a device file an IOError is raised.
    ## @param major The Major-Number of the Device-File
    ## @param minor The Minor-Number of the Device-File
    ## @param mode The unix-Mode (OPTIONAL, default: u=rw,go= respecting the active umask)
    ## @raises An IOError if the fs-entry already exists but is not a device-file.
    ## @raises An IOError if the fs-entry could not be created.
    ## See also:
    ## * `createCharacterDeviceFile() proc <#createCharacterDeviceFile,Pathname>`_
    ## * `createBlockDeviceFile() proc <#createBlockDeviceFile,Pathname>`_
    # @see man 2 mknod
    # @see man 3 makedev
    file_utils.createCharacterDeviceFile(self.path, major, minor, mode)
    return self



#TODO: Testen ...
proc removeCharacterDeviceFile*(self: Pathname): Pathname {.inline,discardable,raises: [IOError,NotSupportedError].} =
    ## Removes a character-device-file and only that.
    ## @raises An IOError if the referenced FS-Entry is existing but is not a character-device-file, or could not be deleted.
    ## See also:
    ## * `removeCharacterDeviceFile() proc <#removeCharacterDeviceFile,Pathname>`_
    ## * `removeBlockDeviceFile() proc <#removeBlockDeviceFile,Pathname>`_
    ## * `removeDeviceFile() proc <#removeDeviceFile,Pathname>`_
    # @see man 2 unlink
    file_utils.removeCharacterDeviceFile(self.path)
    return self



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createBlockDeviceFile()/removeCharacterDeviceFile()
#-----------------------------------------------------------------------------------------------------------------------



#TODO: Testen ...
proc createBlockDeviceFile*(self: Pathname, major: uint8, minor: uint8, mode: uint32 = 0o600): Pathname {.inline,discardable,raises: [IOError,NotSupportedError].} =
    ## Creates a block-device-file (only unix/linux).
    ## If the fs-entry already exists and it is a block-device-file, nothing happens.
    ## If the fs-entry already exists but is not a block-device file an IOError is raised.
    ## @param major The Major-Number of the Device-File
    ## @param minor The Minor-Number of the Device-File
    ## @param mode The unix-Mode (OPTIONAL, default: u=rw,go= respecting the active umask)
    ## @raises An IOError if the fs-entry already exists but is not a device-file.
    ## @raises An IOError if the fs-entry could not be created.
    ## See also:
    ## * `createCharacterDeviceFile() proc <#createCharacterDeviceFile,Pathname>`_
    ## * `createBlockDeviceFile() proc <#createBlockDeviceFile,Pathname>`_
    # @see man 2 mknod
    # @see man 3 makedev
    file_utils.createBlockDeviceFile(self.path, major, minor, mode)
    return self



#TODO: Testen ...
proc removeBlockDeviceFile*(self: Pathname): Pathname {.inline,discardable,raises: [IOError,NotSupportedError].} =
    ## Removes a character-device-file and only that.
    ## @raises An IOError if the referenced FS-Entry is existing but is not a character-device-file, or could not be deleted.
    ## See also:
    ## * `removeCharacterDeviceFile() proc <#removeCharacterDeviceFile,Pathname>`_
    ## * `removeBlockDeviceFile() proc <#removeBlockDeviceFile,Pathname>`_
    ## * `removeDeviceFile() proc <#removeDeviceFile,Pathname>`_
    # @see man 2 unlink
    file_utils.removeBlockDeviceFile(self.path)
    return self



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeDeviceFile()
#-----------------------------------------------------------------------------------------------------------------------



#TODO: Testen ...
proc removeDeviceFile*(self: Pathname): Pathname {.inline,discardable,raises: [IOError,NotSupportedError].} =
    ## Removes a device-file (block- and character) and only that.
    ## @raises An IOError if the referenced FS-Entry is existing but is not a device-file, or could not be deleted.
    ## See also:
    ## * `removeCharacterDeviceFile() proc <#removeCharacterDeviceFile,Pathname>`_
    ## * `removeBlockDeviceFile() proc <#removeBlockDeviceFile,Pathname>`_
    ## * `removeDeviceFile() proc <#removeDeviceFile,Pathname>`_
    # @see man 2 unlink
    file_utils.removeDeviceFile(self.path)
    return self



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createSymlinkFrom() / createSymlinkTo() / removeSymlink()
#-----------------------------------------------------------------------------------------------------------------------



proc createSymlinkFrom*(self: Pathname, dstPath: string): Pathname {.inline,discardable,raises: [IOError,NotSupportedError].} =
    ## Creates a Symlink at the Pathname-Location (== srcPath) pointing to the given dstPath.
    ## @raises An IOError if the fs-entry already exists.
    # @see man 2 symlink
    file_utils.createSymlink(self.path, dstPath)
    return self



proc createSymlinkTo*(self: Pathname, srcPath: string): Pathname {.inline,discardable,raises: [IOError,NotSupportedError].} =
    ## Creates a Symlink at the Pathname-Location (== dstPath) pointing to the given srcPath.
    ## @raises An IOError if the fs-entry already exists.
    # @see man 2 symlink
    file_utils.createSymlink(srcPath, self.path)
    return self



proc removeSymlink*(self: Pathname): Pathname {.inline,discardable,raises: [IOError,NotSupportedError].} =
    ## Removes a character-device-file and only that.
    ## @raises An IOError if the referenced FS-Entry is existing but is not a character-device-file, or could not be deleted.
    ## See also:
    ## * `removeCharacterDeviceFile() proc <#removeCharacterDeviceFile,Pathname>`_
    ## * `removeBlockDeviceFile() proc <#removeBlockDeviceFile,Pathname>`_
    ## * `removeDeviceFile() proc <#removeDeviceFile,Pathname>`_
    # @see man 2 unlink
    file_utils.removeSymlink(self.path)
    return self



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - remove()
#-----------------------------------------------------------------------------------------------------------------------



proc remove*(self: Pathname): Pathname {.inline,discardable,raises: [IOError].} =
    ## Removes the FS-Entry, regardles of the type of the FS-Entry or it is a directory with content.
    ## Please be cautious if using this proc, and use one of the specific remove-Procs if possible.
    file_utils.remove(self.path)
    return self





#LATER #TODO: testen
#LATER proc isMountpoint*(self: Pathname) =
#LATER     ## @returns true if File-System-Entry exists and points to a Mountpoint.



#LATER #TODO: testen
#LATER proc rename*(self: Pathname) =
#LATER     ## Renames the given file.

















#TODO: testen
proc listDir*(self: Pathname, isAbsolute: bool = false): seq[Pathname] =
    ## Lists the files of the addressed directory as Pathnames.
    # Folgendes ist nicht GC:ARC-Kompatibel ...
    #return file_utils.dirEntries(self.path, isAbsolute).map( proc (pathStr: string): Pathname = Pathname.new(pathStr) )
    # Workaround (GC:ARC-Kompatibel) ...
    let dirEntries = file_utils.dirEntries(self.path, isAbsolute)
    result = newSeq[Pathname](dirEntries.len)
    for i in 0..<dirEntries.len:
        result[i] = Pathname.new(dirEntries[i])
    return result



#TODO: testen
proc listDirStrings*(self: Pathname, isAbsolute: bool = false): seq[string] {.inline.} =
    ## Lists the files of the addressed directory as plain Strings.
    return file_utils.dirEntries(self.path, isAbsolute)





proc newPathnames*(paths: varargs[string]) :seq[Pathname] =
    ## Constructs a List of Pathnames with all Pathname in the Parameter-List.
    ## @returns A list of Pathnames
    var pathnames: seq[Pathname] = newSeq[Pathname](paths.len)
    for i in 0..<paths.len:
        pathnames[i] = Pathname.new(paths[i])
    return @pathnames



proc pathnamesFromRoot*() :seq[Pathname] =
    ## Constructs a List of Pathnames containing all Filesystem-Roots per Entry
    ## @returns A list of Pathnames
    when defined(Windows):
        # Windows-Version ist noch in Arbeit (siehe unten)
        return newPathnames( toSeq(parentDirs("test/a/b", inclusive=false)) )
    else:
        return newPathnames("/")



proc toString*(pathnames :seq[Pathname]) :string =
    ## Converts a List of Pathnames to a String for User-Presentation-Purposes (for End-User).
    result = ""
    for pathname in pathnames:
        if result.len > 0:
            result = result & ", "
        result = result & "\"" & pathname.path & "\""
    result = "[" & result & "]"



proc `$`*(pathnames :seq[Pathname]) :string {.inline.} =
    ## Converts a List of Pathnames to a String.
    return pathnames.toString()



proc inspect*(pathnames :seq[Pathname]) :string =
    ## Converts a List of Pathnames to a String for Diagnostic-Purposes (for Developer).
    return "Pathnames(" & pathnames.toString() & ")"




### Noch mitten in der Entwicklung ...
#when defined(Windows):
#    proc winGetWindowsDirectory(lpBuffer: cstring, uSize :cuint): cuint {. importc: "GetWindowsDirectory", header: "<winbase.h>" .}
#    proc fromWindowsInstallDir*(class: typedesc[Pathname]) :Pathname =
#        ## Constructs a new Pathname pointing to the Windows-Installation Directory.
#        const PATH_MAX = 4096'u
#        const maxSize = PATH_MAX
#        var pathStr :string = newString(maxSize)
#        let realSize :cuint = winGetWindowsDirectory(pathStr, maxSize.cuint)
#        if realSize <= 0:
#            raiseOSError(osLastError())
#        pathStr[maxSize.int-1] = 0.char
#        pathStr[realSize.int-1] = 0.char
#        pathStr.setLen(realSize)
#        return result
#
#
### Noch mitten in der Entwicklung ...
#when defined(Windows):
#    proc winGetSystemWindowsDirectory(lpBuffer: cstring, uSize :cuint): cuint {. importc: "GetSystemWindowsDirectory", header: "<winbase.h>" .}
#    proc fromWindowsSystemDir*(class: typedesc[Pathname]) :Pathname =
#        ## Constructs a new Pathname pointing to the Windows-System Directory.
#        const PATH_MAX = 4096'u
#        const maxSize = PATH_MAX
#        var pathStr :string = newString(maxSize)
#        let realSize :cuint = winGetSystemWindowsDirectory(pathStr, maxSize.cuint)
#        if realSize <= 0:
#            raiseOSError(osLastError())
#        pathStr[maxSize.int-1] = 0.char
#        pathStr[realSize.int-1] = 0.char
#        pathStr.setLen(realSize)
#        return result
#
#
### Noch mitten in der Entwicklung ...
#when defined(Windows):
#    # @see https://msdn.microsoft.com/en-us/library/windows/desktop/aa364975(v=vs.85).aspx
#    proc winGetLogicalDriveStrings(nBufferLength :uint32, lpBuffer: cstring): uint32 {. importc: "GetLogicalDriveStrings", header: "<winbase.h.h>" .}
#    proc pathnamesFromWindowsDrives*() :string =
#        ## Constructs a new Pathname pointing to the Windows-System Directory.
#        const PATH_MAX = 4096'u
#        const maxSize = PATH_MAX
#        var pathStr :string = newString(maxSize)
#        let realSize = winGetLogicalDriveStrings(maxSize.uint32, pathStr)
#        if realSize <= 0:
#            raiseOSError(osLastError())
#        if realSize > maxSize:
#            raiseOSError(osLastError())  #TODO
#        pathStr[maxSize.int-1] = 0.char
#        pathStr[realSize.int-1] = 0.char
#        pathStr.setLen(realSize)
#        return result



when isMainModule:

    echo "Current Directory    : ", Pathname.fromCurrentWorkDir()
    echo "Application File     : ", Pathname.fromAppFile()
    echo "Application Directory: ", Pathname.fromAppDir()
    echo "Temp Directory       : ", Pathname.fromTempDir()
    echo "User Directory       : ", Pathname.fromUserHomeDir()
    echo "User Config-Directory: ", Pathname.fromUserConfigDir()

    echo "Root Directory       : ", Pathname.fromRootDir()
    echo "Root Directories     : ", pathnamesFromRoot()

    echo "Current Directory (inspect): ", Pathname.fromCurrentWorkDir().inspect()
    echo "Root Directories (inspect) : ", pathnamesFromRoot().inspect()


    echo "Current Dir-Content  : ", Pathname.fromCurrentWorkDir().listDir()

    #when defined(Windows):
    #    echo "Windows-Install Directory: ", Pathname.fromWindowsInstallDir()
    #    echo "Windows-System Directory : ", Pathname.fromWindowsSystemDir()
    #    echo "Windows-Drives           : ", pathnamesFromWindowsDrives()

#    proc main() =
#        echo file_utils.normalizePath("./../..")   #Fail -> ../..
#        echo file_utils.normalizePath("./../../")  #Fail -> ../..
#        echo file_utils.normalizePath("/../..")    #     -> /
#        echo file_utils.normalizePath("/../../")   #     -> /
#        echo file_utils.normalizePath("/home")
#        echo file_utils.normalizePath(".")
#        echo file_utils.normalizePath("./home")
#        echo file_utils.normalizePath("/./home")
#        echo file_utils.normalizePath("./././.")
#        echo file_utils.normalizePath("/./././.")
#        echo file_utils.normalizePath("./././home")
#        echo file_utils.normalizePath("/./././home")
#        echo file_utils.normalizePath("/./home")
#        echo file_utils.normalizePath("////home/test/.././../hello/././world////./what/..")
#        echo file_utils.normalizePath("////home/test/.././../hello/././world////./what/..///")
#        echo file_utils.normalizePath("////home/test/.././../hello/././world////./what/..///.")
#
#
#        let pathname = Pathname.fromTempDir()
#        echo pathname.toPathStr & ":"
#        for filepath in pathname.parent.listDir():
#            echo "- ", filepath.toPathStr()
#
#        #echo realpath("..")
#
#    main()
