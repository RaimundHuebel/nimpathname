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
#
# ## See also:
# * `https://ruby-doc.org/stdlib-2.7.0/libdoc/pathname/rdoc/Pathname.html`
# * `https://ruby-doc.org/core-2.7.0/File.html`
# * `https://ruby-doc.org/core-2.7.0/Dir.html`
# * `https://ruby-doc.org/core-2.7.0/FileTest.html`
###


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
import pathname/path_string_helpers


when defined(Posix):
    import posix


when defined(Windows):
    import sequtils


## Import/Export FileType-Implementation.
import pathname/file_type as file_type
export file_type


## Import/Export FileInfo-Implementation.
import pathname/file_status as file_status
export file_status

## Export os.FileInfo
export os.FileInfo


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
    return Pathname.new(joinPathComponents(basePath, pathComponent1, additionalPathComponents))


proc fromCurrentWorkDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Current Work Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromCurrentWorkDir()
    return Pathname.new(os.getCurrentDir())


proc fromCurrentWorkDir*(class: typedesc[Pathname], pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Constructs a new Pathname with the Current Work Directory as Path.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromCurrentWorkDir("run")
    ## @usage Pathname.fromCurrentWorkDir("run", "backups")
    return Pathname.new(joinPathComponents(os.getCurrentDir(), pathComponent1, additionalPathComponents))


proc fromAppFile*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the App File as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromAppFile()
    return Pathname.new(os.getAppFilename())


proc fromAppDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the App Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromAppDir()
    return Pathname.new(os.getAppDir())


proc fromAppDir*(class: typedesc[Pathname], pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Constructs a new Pathname with the App Directory as Path.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromAppDir("run")
    ## @usage Pathname.fromAppDir("run", "backups")
    return Pathname.new(joinPathComponents(os.getAppDir(), pathComponent1, additionalPathComponents))


proc fromTempDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Temp Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromTempDir()
    return Pathname.new(os.getTempDir())


proc fromTempDir*(class: typedesc[Pathname], pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Constructs a new Pathname with the Temp Directory as Path.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromTempDir("run")
    ## @usage Pathname.fromTempDir("run", "backups")
    return Pathname.new(joinPathComponents(os.getTempDir(), pathComponent1, additionalPathComponents))


proc fromRootDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Temp Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromRootDir()
    return Pathname.new("/")


proc fromRootDir*(class: typedesc[Pathname], pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Constructs a new Pathname with the Temp Directory as Path.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromRootDir("run")
    ## @usage Pathname.fromRootDir("run", "backups")
    return Pathname.new(joinPathComponents("/", pathComponent1, additionalPathComponents))


proc fromUserConfigDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Config Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromUserConfigDir()
    return Pathname.new(os.getConfigDir())


proc fromUserConfigDir*(class: typedesc[Pathname], pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Constructs a new Pathname with the Config Directory as Path.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromUserConfigDir("run")
    ## @usage Pathname.fromUserConfigDir("run", "backups")
    return Pathname.new(joinPathComponents(os.getConfigDir(), pathComponent1, additionalPathComponents))


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
    return Pathname.new(joinPathComponents(os.getHomeDir(), pathComponent1, additionalPathComponents))


proc fromEnvVar*(class: typedesc[Pathname], envVar: string): Option[Pathname] =
    ## Constructs a new Pathname with the value of the given EnvVar, may return none(Pathname).
    ## The usage of this constructor may need an explicit import of options-Module.
    ## @param envVar The name of the environment variable.
    ## @returns A some(Pathname) containing the Path of the given EnvVar if defined.
    ## @returns none(Pathname) if the given EnvVar does not exist.
    ## @usage Pathname.fromEnvVar("PROJECT_PATH")
    let envPathStr = os.getEnv(envVar)
    if unlikely( envPathStr.len == 0 and not os.existsEnv(envPathStr) ):
        return none(Pathname)
    return some(Pathname.new(envPathStr))


proc fromEnvVarOrDefault*(class: typedesc[Pathname], envVar: string, defaultPath: string): Pathname =
    ## Constructs a new Pathname with the value of the given EnvVar, may return defaultPath.
    ## @param envVar The name of the environment variable.
    ## @returns A Pathname containing the Path of the given EnvVar if defined or defaultPath if not.
    ## @usage Pathname.fromEnvVar("RUN_DIRECTORY", "/tmp/run")
    let envPathStr = os.getEnv(envVar)
    if unlikely( envPathStr.len == 0 and not os.existsEnv(envPathStr) ):
        return Pathname.new(defaultPath)
    return Pathname.new(envPathStr)


proc fromEnvVarOrNil*(class: typedesc[Pathname], envVar: string): Pathname =
    ## Constructs a new Pathname with the value of the given EnvVar, may return nil.
    ## @param envVar The name of the environment variable.
    ## @returns A Pathname containing the Path of the given EnvVar if defined.
    ## @returns nil if the given EnvVar does not exist.
    ## @usage Pathname.fromEnvVarOrNil("PROJECT_PATH")
    let envPathStr = os.getEnv(envVar)
    if unlikely( envPathStr.len == 0 and not os.existsEnv(envPathStr) ):
        return nil
    return Pathname.new(envPathStr)




proc toPathStr*(self :Pathname): string {.inline.} =
    ## Liefert das Verzeichnis des Pathnames als String.
    return self.path



proc isAbsolute*(self: Pathname): bool =
    ## Tells if the Pathname contains an absolute path.
    return isAbsolutePathString(self.path)



proc isRelative*(self: Pathname): bool =
    ## Tells if the Pathname contains an relative path.
    return not isAbsolutePathString(self.path)



proc parent*(self :Pathname): Pathname =
    ## Returns the Parent-Directory of the Pathname.
    #return Pathname.new(os.parentDir(self.path))
    #return Pathname.new(self.path & "/..")
    #return Pathname.new(normalizePathString(self.path & "/.."))
    #return Pathname.new(os.normalizedPath(os.parentDir(self.path)))
    #return Pathname.new(os.normalizedPath(self.path & "/.."))
    return Pathname.new(normalizePathString(self.path & "/.."))



proc join*(self: Pathname, pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Returns a new Pathname joined with the additional path components.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @alter
    #return aPathname.join("run")
    #return aPathname.join("run", "backups")
    return Pathname.new(joinPathComponents(self.path, pathComponent1, additionalPathComponents))



#TODO: safeJoin -> ein Path-Join der hochnavigation verbietet, gedacht für Pfadoperationen von unsicheren Quellen getriggert.


proc joinNormalized*(self: Pathname, pathComponent1: string, additionalPathComponents: varargs[string]): Pathname =
    ## Returns a new normalized Pathname joined with the additional path components.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @alternative .join(...).normalize()
    #return aPathname.joinNormalized("run")
    #return aPathname.joinNormalized("run", "backups")
    return Pathname.new(normalizePathString(joinPathComponents(self.path, pathComponent1, additionalPathComponents)))



proc normalize*(self: Pathname): Pathname =
    ## Returns clean pathname of self with consecutive slashes and useless dots removed.
    ## The filesystem is not accessed.
    ## @alias #cleanpath()
    ## @alias #normalize()
    ## @see https://ruby-doc.org/stdlib/libdoc/pathname/rdoc/Pathname.html#method-i-cleanpath
    let normalizedPathStr = normalizePathString(self.path)
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
    self.normalize()



proc dirname*(self: Pathname): Pathname {.inline.} =
    ## @returns the Directory-Part of the given Pathname as Pathname.
    return Pathname.new(path_string_helpers.extractDirname(self.path))



proc basename*(self: Pathname): Pathname {.inline.} =
    ## @returns the Filepart-Part of the given Pathname as Pathname.
    return Pathname.new(path_string_helpers.extractBasename(self.path))



proc extname*(self: Pathname): string {.inline.} =
    ## @returns the File-Extension-Part of the given Pathname as string.
    return path_string_helpers.extractExtension(self.path)



proc fileType*(self: Pathname): FileType =
    ## Returns the FileType of the current Pathname. And tells if the underlying File-System-Entry
    ## is existing, and if it is either a Regular File, Directory, Symlink, or Device-File.
    ## See also: fileInfo()
    ## See also: fileStatus()
    ## See also: fileType()
    return FileType.fromPathStr(self.path)



proc fileInfo*(self: Pathname): os.FileInfo {.inline.} =
    ## Returns an os.FileInfo of the current Pathname. Providing additional infos about the underlying File-System-Entry.
    ## The returned FileInfo-Structure is the standard-version of the nim-runtime. If some more functionality is
    ## needed see #fileStatus() which provides a more advanced interface to get information of the file.
    ## See also: fileInfo()
    ## See also: fileStatus()
    ## See also: fileType()
    ## See also: https://nim-lang.org/docs/os.html#FileInfo
    return os.getFileInfo(self.path, followSymlink = false)



proc fileStatus*(self: Pathname): FileStatus {.inline,noSideEffect.} =
    ## Returns the FileStatus of the current Pathname. Providing additional infos about the underlying File-System-Entry.
    ## The returned FileStatus is a custom implementation of the kind of os.FileInfo with extended functionality.
    ## See also: fileInfo()
    ## See also: fileStatus()
    ## See also: fileType()
    return FileStatus.fromPathStr(self.path)



proc isExisting*(self: Pathname): bool {.inline,noSideEffect.} =
    ## Returns true if the path directs to an existing file-system-entity like a file, directory, device, symlink, ...
    ## Returns false otherwise.
    ## See also:
    ## * `isExisting() proc <#isExisting,Pathname>`_
    ## * `isNotExisting() proc <#isNotExisting,Pathname>`_
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return self.fileType().isExisting()



proc isNotExisting*(self: Pathname): bool {.inline,noSideEffect.} =
    ## Returns true if the path DOES NOT direct to an existing and accessible file-system-entity.
    ## Returns false otherwise
    ## See also:
    ## * `isExisting() proc <#isExisting,Pathname>`_
    ## * `isNotExisting() proc <#isNotExisting,Pathname>`_
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return self.fileType().isNotExisting()



proc isUnknownFileType*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if type the File-System-Entry is of unknown type.
    ## @returns false otherwise
    return self.fileType().isUnknownFileType()



proc isRegularFile*(self: Pathname): bool {.inline,noSideEffect.} =
    ## Returns true if the path directs to a file, or a symlink that points at a file,
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return self.fileType().isRegularFile()



proc isDirectory*(self: Pathname): bool {.inline,noSideEffect.} =
    ## Returns true if the path directs to a directory, or a symlink that points at a directory,
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return self.fileType().isDirectory()



proc isSymlink*(self: Pathname): bool {.inline,noSideEffect.} =
    ## Returns true if the path directs to a symlink.
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return self.fileType().isSymlink()



proc isDeviceFile*(self: Pathname): bool {.inline,noSideEffect.} =
    ## Returns true if the path directs to a device-file (either block or character).
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return self.fileType().isDeviceFile()



proc isCharacterDeviceFile*(self: Pathname): bool {.inline,noSideEffect.} =
    ## Returns true if the path directs to a block-device-file.
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return self.fileType().isCharacterDeviceFile()



proc isBlockDeviceFile*(self: Pathname): bool {.inline,noSideEffect.} =
    ## Returns true if the path directs to a block-device-file.
    ## Returns false otherwise.
    ## See also: fileStatus()
    ## See also: fileType()
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    return self.fileType().isBlockDeviceFile()



proc isSocketFile*(self: Pathname): bool {.inline,noSideEffect.} =
    ## Returns true if the path directs to a unix socket file.
    ## Returns false otherwise.
    ## See also: fileStatus()
    ## See also: fileType()
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    return self.fileType().isSocketFile()



proc isPipeFile*(self: Pathname): bool {.inline,noSideEffect.} =
    ## Returns true if the path directs to a named pipe/fifo-file.
    ## Returns false otherwise.
    ## See also: fileStatus()
    ## See also: fileType()
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    return self.fileType().isPipeFile()



proc isHidden*(self: Pathname): bool {.inline,noSideEffect.} =
    ## Returns true if the path directs to an existing hidden file/directory/etc.
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    return self.fileStatus().isHidden()



proc isVisible*(self: Pathname): bool {.inline,noSideEffect.} =
    ## Returns true if the path directs to an existing visible file/directory/etc (eg. is NOT hidden).
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    return self.fileStatus().isVisible()



proc isZeroSizeFile*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if the path directs to an existing file with a file-size of zero.
    ## @returns false otherwise
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    return self.fileStatus().isZeroSizeFile()



proc getFileSizeInBytes*(self: Pathname): int64 {.inline,noSideEffect.} =
    ## @returns the FileSize of the File-System-Entry in Bytes.
    ## @returns -1 if the FileSize could not be determined.
    return self.fileStatus().getFileSizeInBytes()



proc getIoBlockSizeInBytes*(self: Pathname): int32 {.inline,noSideEffect.} =
    ## @returns the Size of an IO-Block of the File-System-Entry in Bytes.
    ## @returns -1 if the BlockSize could not be determined.
    return self.fileStatus().getIoBlockSizeInBytes()



proc getUserId*(self: Pathname): int32 {.inline,noSideEffect.} =
    ## @returns an int >= 0 containing the UserId which is assigned to the existing FileSystemEntry.
    ## @returns -1 otherwise
    return self.fileStatus().getUserId()



proc getGroupId*(self: Pathname): int32 {.inline,noSideEffect.} =
    ## @returns an int >= 0 containing the GroupId which is assigned to the existing FileSystemEntry.
    ## @returns -1 otherwise
    return self.fileStatus().getGroupId()



proc getCountHardlinks*(self: Pathname): int32 {.inline,noSideEffect.} =
    ## @returns the count of hardlinks of the File-System-Entry.
    ## @returns -1 if the count could not be determined.
    return self.fileStatus().getCountHardlinks()



proc hasSetUidBit*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and has the Set-Uid-Bit set.
    ## @returns false otherwise
    return self.fileStatus().hasSetUidBit()



proc hasSetGidBit*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and has the Set-Gid-Bit set.
    ## @returns false otherwise
    return self.fileStatus().hasSetGidBit()



proc hasStickyBit*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and has the Sticky-Bit set.
    ## @returns false otherwise
    return self.fileStatus().hasStickyBit()



proc getLastAccessTime*(self: Pathname): times.Time {.inline,noSideEffect.} =
    ## @returns the Time when the stated Path was last accessed.
    ## @returns 0.Time if the FileStat is in Error-State or the FileType does not support Prefered Block-Size.
    return self.fileStatus().getLastAccessTime()



proc getLastChangeTime*(self: Pathname): times.Time {.inline,noSideEffect.} =
    ## @returns the Time when the content of the stated Path was last changed.
    ## @returns 0.Time if the FileStat is in Error-State.
    return self.fileStatus().getLastChangeTime()



proc getLastStatusChangeTime*(self: Pathname): times.Time {.inline,noSideEffect.} =
    ## @returns the Time when the status of stated Path was last changed.
    ## @returns 0.Time if the FileStat is in Error-State.
    return self.fileStatus().getLastStatusChangeTime()



proc isUserOwned*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true
    ##     if the File-System-Entry exists and the effective userId of the
    ##     current process is the owner of the file.
    ## @returns false otherwise
    return self.fileStatus().isUserOwned()



proc isGroupOwned*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true
    ##     if the File-System-Entry exists and the effective groupId of the
    ##     current process is the owner of the file.
    ## @returns false otherwise
    return self.fileStatus().isGroupOwned()



proc isGroupMember*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if the named file exists and the effective user is member to the group of the the file.
    ## @returns false otherwise
    return self.fileStatus().isGroupMember()



proc isReadable*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and is readable by any means for the current process.
    ## @returns false otherwise
    return self.fileStatus().isReadable()



proc isReadableByUser*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and is readable by direct user ownership of the current process.
    ## @returns false otherwise
    return self.fileStatus().isReadableByUser()



proc isReadableByGroup*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and is readable by group ownership of the current process.
    ## @returns false otherwise
    return self.fileStatus().isReadableByGroup()



proc isReadableByOther*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and is readable by any other means of the current process.
    ## @returns false otherwise
    return self.fileStatus().isReadableByOther()



proc isWritable*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and is writable by any means for the current process.
    ## @returns false otherwise
    return self.fileStatus().isWritable()



proc isWritableByUser*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and is writable by direct user ownership of the current process.
    ## @returns false otherwise
    return self.fileStatus().isWritableByUser()



proc isWritableByGroup*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and is writable by group ownership of the current process.
    ## @returns false otherwise
    return self.fileStatus().isWritableByGroup()



proc isWritableByOther*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and is writable by any other means of the current process.
    ## @returns false otherwise
    return self.fileStatus().isWritableByOther()



proc isExecutable*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and is executable by any means for the current process.
    ## @returns false otherwise
    return self.fileStatus().isExecutable()



proc isExecutableByUser*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and is executable by direct user ownership of the current process.
    ## @returns false otherwise
    return self.fileStatus().isExecutableByUser()



proc isExecutableByGroup*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and is executable by group ownership of the current process.
    ## @returns false otherwise
    return self.fileStatus().isExecutableByGroup()



proc isExecutableByOther*(self: Pathname): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry exists and is executable by any other means of the current process.
    ## @returns false otherwise
    return self.fileStatus().isExecutableByOther()













#TODO: testen
proc listDir*(self: Pathname): seq[Pathname] =
    ## Lists the files of the addressed directory as Pathnames.
    var files: seq[Pathname] = @[]
    for file in walkDir(self.path):
        files.add(Pathname.new(file.path))
    return files



#TODO: testen
proc listDirStrings*(self: Pathname): seq[string] =
    ## Lists the files of the addressed directory as plain Strings.
    var files: seq[string] = @[]
    for file in walkDir(self.path):
        files.add(file.path)
    return files



proc toString*(self: Pathname): string  {.inline.} =
    ## Converts a Pathname to a String for User-Presentation-Purposes (for End-User).
    return self.path



proc `$`*(self :Pathname): string {.inline.} =
    ## Converts a Pathname to a String for User-Presentation-Purposes (for End-User).
    return self.toString()



proc inspect*(self: Pathname) :string =
    ## Converts a Pathname to a String for Diagnostic-Purposes (for Developer).
    return "Pathname(\"" & self.path & "\")"



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
#        echo normalizePathString("./../..")   #Fail -> ../..
#        echo normalizePathString("./../../")  #Fail -> ../..
#        echo normalizePathString("/../..")    #     -> /
#        echo normalizePathString("/../../")   #     -> /
#        echo normalizePathString("/home")
#        echo normalizePathString(".")
#        echo normalizePathString("./home")
#        echo normalizePathString("/./home")
#        echo normalizePathString("./././.")
#        echo normalizePathString("/./././.")
#        echo normalizePathString("./././home")
#        echo normalizePathString("/./././home")
#        echo normalizePathString("/./home")
#        echo normalizePathString("////home/test/.././../hello/././world////./what/..")
#        echo normalizePathString("////home/test/.././../hello/././world////./what/..///")
#        echo normalizePathString("////home/test/.././../hello/././world////./what/..///.")
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
