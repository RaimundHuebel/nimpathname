###
# Pathname-FileUtils Implementation to provide a os-independent method to handle File-System.
#
# Author:  Raimund Hübel <raimund.huebel@googlemail.com>
#
# ## See also:
# * `https://ruby-doc.org/stdlib-2.7.0/libdoc/pathname/rdoc/Pathname.html`
# * `https://ruby-doc.org/core-2.7.0/File.html`
# * `https://ruby-doc.org/core-2.7.0/Dir.html`
# * `https://ruby-doc.org/core-2.7.0/FileTest.html`
# * `https://en.wikipedia.org/wiki/Unix_file_types`
# * `https://de.wikipedia.org/wiki/Unix-Dateirechte`
# * `https://de.wikipedia.org/wiki/Setuid`
# * `https://de.wikipedia.org/wiki/Setgid`
# * `https://de.wikipedia.org/wiki/Sticky_Bit`
###


{. experimental: "codeReordering" .}


import os
import options
import times
import strutils
#import sequtils
import pathname/private/common_path_helpers


when defined(Posix):
    import posix


when defined(Windows):
    import winlean
    import sequtils


## Import/Export FileType-Implementation.
import pathname/file_type as file_type
export file_type


## Import/Export FileInfo-Implementation.
import pathname/file_status as file_status
export file_status

## Export os.FileInfo
export os.FileInfo



## Support-Matrix ...
const AreSymlinksSupported*:    bool = defined(Posix)
const ArePipesSupported*:       bool = defined(Posix)
const AreDeviceFilesSupported*: bool = defined(Posix)




## Error to indicate, that the Feature is not supported for the current architecture.
type NotSupportedError* = object of CatchableError




proc getRootDirPath*(): string =
    ## Constructs a new Pathname with the Root Directory Path.
    ## In Windows the first drive containing system/ will be returned. Otherwise the first.
    ## @returns A Path-String.
    ## @usage file_utils.getRootDirPath()
    when defined(Posix):
        return "/"
    elif defined(Windows):
        return "C:"
    else:
        raise newException(IOError, "file_utils.getRootDirPath() is NOT supported for current architecture")


proc getCurrentWorkDirPath*(): string =
    ## Returns a Pathstring with the absolute Current Work Directory Path.
    ## @returns A Path-String.
    ## @usage file_utils.getCurrentWorkDirPath()
    return os.getCurrentDir()


proc getAppFilePath*(): string =
    ## Returns a Pathstring with the absolute App File Path.
    ## @returns A Path-String.
    ## @usage file_utils.getAppFilePath()
    return os.getAppFilename()


proc getAppDirPath*(): string =
    ## Returns a Pathstring with the absolute App Directory Path.
    ## @returns A Path-String.
    ## @usage file_utils.getAppDirPath()
    return os.getAppDir()


proc getTempDirPath*(): string =
    ## Returns a Pathstring with the absolute Temp Directory.
    ## @returns A Path-String.
    ## @usage file_utils.getTempDirPath()
    return os.getTempDir()


proc getUserConfigDirPath*(): string =
    ## Returns a Pathstring with the absolute User Config Directory Path.
    ## @returns A Path-String.
    ## @usage file_utils.getUserConfigDirPath()
    return os.getConfigDir()


proc getEnvVarPath*(envVar: string): Option[string] =
    ## Returns a Pathstring with the value of the given EnvVar, may return none(Pathstr).
    ## The usage of this may need an explicit import of options-Module.
    ## @param envVar The name of the environment variable.
    ## @returns A some(Pathstr) containing the Path of the given EnvVar if defined (returns an empty String if EnvVar is defined but Empty).
    ## @returns none(Pathstr) if the given EnvVar does not exist.
    ## @usage file_utils.getEnvVarPath("PROJECT_PATH")
    let envPathStr = os.getEnv(envVar)
    if unlikely( envPathStr.len == 0 and not os.existsEnv(envPathStr) ):
        return none(string)
    return some(envPathStr)


proc getEnvVarOrDefaultPath*(envVar: string, defaultPath: string): string =
    ## Returns a Pathstring with the value of the given EnvVar, may return defaultPath.
    ## @param envVar The name of the environment variable.
    ## @returns A Pathstring containing the Path of the given EnvVar if defined or defaultPath if not.
    ## @usage file_utils.getEnvVarOrDefaultPath("RUN_DIRECTORY", "/tmp/run")
    let envPathStr = os.getEnv(envVar)
    if unlikely( envPathStr.len == 0 and not os.existsEnv(envPathStr) ):
        return defaultPath
    return envPathStr


proc getNimbleDirPath*(additionalPathComponents: varargs[string]): string =
    ## Returns a Pathstring with the absolute Default-Nimble-Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage file_utils.getNimbleDirPath()
    ## @usage file_utils.getNimbleDirPath("bin")
    ## @usage file_utils.getNimbleDirPath("pkgs")
    return file_utils.joinPath(os.getHomeDir(), ".nimble", additionalPathComponents)


proc joinPath*(basePath: string, pathComponents: openArray[string]): string =
    ## Constructs a new PathStr, from a base-path and additional path-components.
    ## @param path The Directory which shall be listed.
    ## @param pathComponents Further additional Path-Components
    ## @returns A string containing the joined Path.
    ## @usage file_utils.joinPath("/a/sample/path", @["run", "exports]")
    # Building Path-Components-Array
    var resultPathComponents = newSeq[string](pathComponents.len + 1)
    resultPathComponents[0] = basePath
    for idx in (0..<pathComponents.len):
        resultPathComponents[idx+1] = pathComponents[idx]
    # Pfadkomponenten intelligent zusammenführen ...
    result = file_utils.internJoinPath(resultPathComponents)
    return result


proc joinPath*(basePath: string, pathComponent1: string, additionalPathComponents: varargs[string]): string =
    ## Constructs a new PathStr, from a base-path and additional path-components.
    ## @param path The Directory which shall be listed.
    ## @param pathComponent1 The first mandatory Path-Component
    ## @param additionalPathComponents Further additional Path-Components
    ## @returns A string containing the joined Path.
    ## @usage joinPathComponents("/a/sample/path", "run")
    ## @usage joinPathComponents("/a/sample/path", "run", "exports")
    # Building Path-Components-Array
    var resultPathComponents = newSeq[string](additionalPathComponents.len + 2)
    resultPathComponents[0] = basePath
    resultPathComponents[1] = pathComponent1
    for idx in (0..<additionalPathComponents.len):
        resultPathComponents[idx+2] = additionalPathComponents[idx]
    # Pfadkomponenten intelligent zusammenführen ...
    result = file_utils.internJoinPath(resultPathComponents)
    return result


proc internJoinPath(pathComponents: var openArray[string]): string =
    ## Führt ein join der Pfad-Komponenten durch, wobei doppelte Pfadseperatoren zusammengefasst werden.
    let hasLeadingPathSep:  bool = pathComponents[ 0].startsWith(os.DirSep)
    #let hasTrailingPathSep: bool = pathComponents[^1].endsWith(os.DirSep)
    # Remove Trailing /
    for idx in (0..<pathComponents.len):
        var pc: string = pathComponents[idx]
        while pc.endsWith(os.DirSep):
            pc = pc[0..^2]
        pathComponents[idx] = pc
    # Remove Leading /
    for idx in (0..<pathComponents.len):
        var pc: string = pathComponents[idx]
        while pc.startsWith(os.DirSep):
            pc = pc[1..^1]
        pathComponents[idx] = pc
    result = pathComponents.join($os.DirSep)
    if hasLeadingPathSep and not result.startsWith(os.DirSep):
        result = os.DirSep & result
    #result = normalizePathString(result) # DON'T DO IT!
    return result




#TODO: testen
proc isAbsolutePathPosix*(pathStr: string): bool =
    ## Gibt an ob es sich um ein absoluten Pfad unter Posix-Systemen handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    ## @usage file_utils.isAbsolutePathPosix()
    if unlikely(pathStr.len == 0):
        return false
    return pathStr[0] == '/'



#TODO: testen
proc isAbsolutePathWindows*(pathStr: string): bool =
    ## Gibt an ob es sich um ein absoluten Pfad unter Windows/Dos-Systemen handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    ## @usage file_utils.isAbsolutePathWindows()
    if unlikely(pathStr.len == 0):
        return false
    result = false
    #result = result  or ( pathStr.len >= 1  and  pathStr[0] in { '/', '\\' } )
    result = result  or ( pathStr.len == 2  and  pathStr[0] in {'a'..'z', 'A'..'Z'}  and  pathStr[1] == ':' )
    result = result  or ( pathStr.len >= 3  and  pathStr[0] in {'a'..'z', 'A'..'Z'}  and  pathStr[1] == ':'  and  pathStr[2] == '\\' )
    return result


#TODO: testen
proc isAbsolutePathMacOs*(pathStr: string): bool =
    ## Gibt an ob es sich um ein absoluten Pfad unter MacOs-Systemen handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    ## @usage file_utils.isAbsolutePathMacOs()
    if unlikely(pathStr.len == 0):
        return false
    # according to https://perldoc.perl.org/File/Spec/Mac.html `:a` is a relative path
    return pathStr[0] != ':'



#TODO: testen
proc isAbsolutePathRiscOs*(pathStr: string): bool =
    ## Gibt an ob es sich um ein absoluten Pfad unter RiscOs-Systemen handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    ## @usage file_utils.isAbsolutePathRiscOs()
    if unlikely(pathStr.len == 0):
        return false
    return pathStr[0] == '$'



#TODO: testen
proc isAbsolutePath*(pathStr: string): bool {.inline.} =
    ## Gibt an ob es sich um ein absoluten Pfad im aktuellen Betriebssystem handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    ## @usage file_utils.isAbsolutePath()
    when os.doslikeFileSystem:
        return isAbsolutePathWindows(pathStr)
    elif defined(macos):
        return isAbsolutePathMacOs(pathStr)
    elif defined(RISCOS):
        return isAbsolutePathRiscOs(pathStr)
    elif defined(Posix):
        return isAbsolutePathPosix(pathStr)






#TODO: testen
proc normalizePath*(pathStr: string): string =
    ## Normalisiert ein Pfadnamen auf die kürzeste Darstellung.
    ## @see https://nim-lang.org/docs/os.html#normalizedPath
    ## @see https://www.linuxjournal.com/content/normalizing-path-names-bash
    ## @see https://ruby-doc.org/stdlib/libdoc/pathname/rdoc/Pathname.html#method-i-cleanpath
    ## @see https://ruby-doc.org/stdlib/libdoc/pathname/rdoc/Pathname.html#method-i-realpath
    if pathStr.len == 0: return "."
    if pathStr == ".":   return "."
    if pathStr == "..":  return ".."

    when defined(Posix):
        if pathStr == "/":   return "/"

        let isAbsolutePath = isAbsolutePathPosix(pathStr)

        var pathComponents = strutils.split(pathStr, '/')
        var pathLength: int = 0
        var currPos   : int = 0

        while likely(currPos < pathComponents.len):
            assert( currPos < pathComponents.len )
            assert( pathLength <= currPos )
            assert( pathLength >= 0 )
            assert( currPos    >= 0 )

            let currComponent: string = pathComponents[currPos]
            if currComponent == "" or currComponent == ".":
                # Aktuelles Pfad-Element kodiert: Aktueller Pfad
                # => Ignoriere aktuelles Pfad-Element
                # => akt. Pfad-Element überspringen == tue nix
                # currPos += 1
                discard

            elif isAbsolutePath and currComponent == "..":
                # Aktuelles Pfad-Element kodiert: Eltern-Pfad innerhalb eines absoluten Pfades ...
                # => reduziere akzeptierte Pfadliste um letztes Element
                    pathLength = max(0, pathLength - 1)

            elif not isAbsolutePath and currComponent == "..":
                # Aktuelles Pfad-Element kodiert: Eltern-Pfad innerhalb eines relativen Pfades ...
                if pathLength == 0 or pathComponents[pathLength-1] == "..":
                    # wenn akzeptierte Pfadliste leer ist oder mit ".." endet.
                    # => füge ".." ans Ende der akzeptierten Pfadliste hinzu,
                    pathComponents[pathLength] = ".."
                    pathLength += 1
                else:
                    # ... entferne das letzte Pfadelement aus der aktiven Pfadliste,
                    # wenn die akzeptierte Pfadliste weder leer ist oder mit ".." endet.
                    pathLength = max(0, pathLength - 1)

            else:
                # Aktuelles Pfad-Element kodiert: Verzeichnis/Datei
                # => aktuelles Pfad-Element in die Liste aufnehmen.
                # => Wenn currPos == pathLength dann nur pathLength um 1 erhöhen
                #    sonst aktuelles Element ans Ende der aktzeptierten Pfadliste hängen.
                pathComponents[pathLength] = pathComponents[currPos] # Tut nichts wenn currPos == pathLength
                pathLength += 1

            # Nächstes Element bearbeiten
            currPos += 1

        # pathComponents auf Ergebnis-Pfad redurzieren ...
        pathComponents.setLen(pathLength)

        #var result: string
        if isAbsolutePath:
            # Wenn es ursprünglich ein absoluter Pfad war, dann "/" wieder hinzufügen ...
            result = "/" & pathComponents.join("/")
        elif pathComponents.len > 0:
            # Wenn es ein relativer Pfad war, gebe diesen einfach zurück.
            result = pathComponents.join("/")
        else:
            # Wenn es auf ein leeren Pfad endet, dann ist es der aktuelle Pfad.
            result = "."

        return result

    elif defined(Windows):
        let isAbsolutePath = isAbsolutePathWindows(pathStr)

        var pathComponents = strutils.split(pathStr, '\\')
        var pathLength: int = 0
        var currPos   : int = 0

        if isAbsolutePath:
            pathLength = 1
            currPos    = 1

        while likely(currPos < pathComponents.len):
            assert( currPos < pathComponents.len )
            assert( pathLength <= currPos )
            assert( pathLength >= 0 )
            assert( currPos    >= 0 )

            let currComponent: string = pathComponents[currPos]
            if currComponent == "" or currComponent == ".":
                # Aktuelles Pfad-Element kodiert: Aktueller Pfad
                # => Ignoriere aktuelles Pfad-Element
                # => akt. Pfad-Element überspringen == tue nix
                # currPos += 1
                discard

            elif isAbsolutePath and currComponent == "..":
                # Aktuelles Pfad-Element kodiert: Eltern-Pfad innerhalb eines absoluten Pfades ...
                # => reduziere akzeptierte Pfadliste um letztes Element
                    pathLength = max(1, pathLength - 1)

            elif not isAbsolutePath and currComponent == "..":
                # Aktuelles Pfad-Element kodiert: Eltern-Pfad innerhalb eines relativen Pfades ...
                if pathLength == 0 or pathComponents[pathLength-1] == "..":
                    # wenn akzeptierte Pfadliste leer ist oder mit ".." endet.
                    # => füge ".." ans Ende der akzeptierten Pfadliste hinzu,
                    pathComponents[pathLength] = ".."
                    pathLength += 1
                else:
                    # ... entferne das letzte Pfadelement aus der aktiven Pfadliste,
                    # wenn die akzeptierte Pfadliste weder leer ist oder mit ".." endet.
                    pathLength = max(0, pathLength - 1)

            else:
                # Aktuelles Pfad-Element kodiert: Verzeichnis/Datei
                # => aktuelles Pfad-Element in die Liste aufnehmen.
                # => Wenn currPos == pathLength dann nur pathLength um 1 erhöhen
                #    sonst aktuelles Element ans Ende der aktzeptierten Pfadliste hängen.
                pathComponents[pathLength] = pathComponents[currPos] # Tut nichts wenn currPos == pathLength
                pathLength += 1

            # Nächstes Element bearbeiten
            currPos += 1

        # pathComponents auf Ergebnis-Pfad reduzieren ...
        pathComponents.setLen(pathLength)

        #var result: string
        if pathComponents.len == 0:
            # Wenn es auf ein leeren Pfad endet, dann ist es der aktuelle Pfad.
            result = "."
        else:
            # Es ist irrelevant, ob absolut oder relativ, da bereits gehändelt. Daher gebe Pfad einfach zurück.
            result = pathComponents.join("\\")

        return result

    else:
        # os.normalizePath(...) is available since Nim v0.19.0, may have incorrect on some edge cases.
        return os.normalizedPath(pathStr)



proc parentPath*(pathStr: string): string =
    ## Returns the Parent-Directory of the Pathname.
    ## @usage file_utils.parentPath("/home/user/test.exe")
    #return os.parentDir(self.path)
    #return self.path & "/.."
    #return file_utils.normalizePath(self.path & "/..")
    #return os.normalizedPath(os.parentDir(self.path))
    #return os.normalizedPath(self.path & "/..")
    return file_utils.normalizePath(pathStr & os.DirSep & "..")



proc extractDirname*(pathStr: string): string {.inline.} =
    ## @returns the Directory-Part of the given string.
    return common_path_helpers.extractDirname(pathStr)



proc extractBasename*(pathStr: string): string {.inline.} =
    ## @returns the Basename-Part of the given string.
    return common_path_helpers.extractBasename(pathStr)



proc extractExtension*(pathStr: string): string {.inline.} =
    ## @returns the File-Extension-Part of the given string.
    return common_path_helpers.extractExtension(pathStr)



proc getFileType*(pathStr: string): FileType {.inline.} =
    ## Returns the FileType of the current Pathstr. And tells if the underlying File-System-Entry
    ## is existing, and if it is either a Regular File, Directory, Symlink, or Device-File.
    ## See also: fileInfo()
    ## See also: fileStatus()
    ## See also: fileType()
    return FileType.fromPathStr(pathStr)



proc getFileInfo*(pathStr: string): os.FileInfo {.inline.} =
    ## Returns an os.FileInfo of the current Pathstr. Providing additional infos about the underlying File-System-Entry.
    ## The returned FileInfo-Structure is the standard-version of the nim-runtime. If some more functionality is
    ## needed see #fileStatus() which provides a more advanced interface to get information of the file.
    ## See also: fileInfo()
    ## See also: fileStatus()
    ## See also: fileType()
    ## See also: https://nim-lang.org/docs/os.html#FileInfo
    return os.getFileInfo(pathStr, followSymlink = false)



proc getFileStatus*(pathStr: string): FileStatus {.inline.} =
    ## Returns the FileStatus of the current Pathname. Providing additional infos about the underlying File-System-Entry.
    ## The returned FileStatus is a custom implementation of the kind of os.FileInfo with extended functionality.
    ## See also: fileInfo()
    ## See also: fileStatus()
    ## See also: fileType()
    return FileStatus.fromPathStr(pathStr)



proc isExisting*(pathStr: string): bool =
    ## Returns true if the path directs to an existing file-system-entity like a file, directory, device, symlink, ...
    ## Returns false otherwise.
    ## See also:
    ## * `isExisting() proc <#isExisting,Pathname>`_
    ## * `isNotExisting() proc <#isNotExisting,Pathname>`_
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.getFileType(pathStr).isExisting()



proc isNotExisting*(pathStr: string): bool =
    ## Returns true if the path DOES NOT direct to an existing and accessible file-system-entity.
    ## Returns false otherwise
    ## See also:
    ## * `isExisting() proc <#isExisting,Pathname>`_
    ## * `isNotExisting() proc <#isNotExisting,Pathname>`_
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.getFileType(pathStr).isNotExisting()



proc isUnknownFileType*(pathStr: string): bool =
    ## @returns true if type the File-System-Entry is of unknown type.
    ## @returns false otherwise
    return file_utils.getFileType(pathStr).isUnknownFileType()



proc isRegularFile*(pathStr: string): bool =
    ## Returns true if the path directs to a file, or a symlink that points at a file,
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.getFileType(pathStr).isRegularFile()



proc isDirectory*(pathStr: string): bool =
    ## Returns true if the path directs to a directory, or a symlink that points at a directory,
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.getFileType(pathStr).isDirectory()



proc isSymlink*(pathStr: string): bool =
    ## Returns true if the path directs to a symlink.
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.getFileType(pathStr).isSymlink()



proc isDeviceFile*(pathStr: string): bool =
    ## Returns true if the path directs to a device-file (either block or character).
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.getFileType(pathStr).isDeviceFile()



proc isCharacterDeviceFile*(pathStr: string): bool =
    ## Returns true if the path directs to a block-device-file.
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    ## * `fileInfo() proc <#fileInfo,Pathname>`_
    return file_utils.getFileType(pathStr).isCharacterDeviceFile()



proc isBlockDeviceFile*(pathStr: string): bool =
    ## Returns true if the path directs to a block-device-file.
    ## Returns false otherwise.
    ## See also: fileStatus()
    ## See also: fileType()
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    return file_utils.getFileType(pathStr).isBlockDeviceFile()



proc isSocketFile*(pathStr: string): bool =
    ## Returns true if the path directs to a unix socket file.
    ## Returns false otherwise.
    ## See also: fileStatus()
    ## See also: fileType()
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    return file_utils.getFileType(pathStr).isSocketFile()



proc isPipeFile*(pathStr: string): bool =
    ## Returns true if the path directs to a named pipe/fifo-file.
    ## Returns false otherwise.
    ## See also: fileStatus()
    ## See also: fileType()
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    ## * `fileType() proc <#fileType,Pathname>`_
    return file_utils.getFileType(pathStr).isPipeFile()




proc isHidden*(pathStr: string): bool =
    ## Returns true if the path directs to an existing hidden file/directory/etc.
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    return file_utils.getFileStatus(pathStr).isHidden()



proc isVisible*(pathStr: string): bool =
    ## Returns true if the path directs to an existing visible file/directory/etc (eg. is NOT hidden).
    ## Returns false otherwise.
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    return file_utils.getFileStatus(pathStr).isVisible()



proc isZeroSizeFile*(pathStr: string): bool =
    ## @returns true if the path directs to an existing file with a file-size of zero.
    ## @returns false otherwise
    ## See also:
    ## * `fileStatus() proc <#fileStatus,Pathname>`_
    return file_utils.getFileStatus(pathStr).isZeroSizeFile()



proc getFileSizeInBytes*(pathStr: string): int64 =
    ## @returns the FileSize of the File-System-Entry in Bytes.
    ## @returns -1 if the FileSize could not be determined.
    return file_utils.getFileStatus(pathStr).fileSizeInBytes()



proc getIoBlockSizeInBytes*(pathStr: string): int64 =
    ## @returns the Size of an IO-Block of the File-System-Entry in Bytes.
    ## @returns -1 if the BlockSize could not be determined.
    return file_utils.getFileStatus(pathStr).ioBlockSizeInBytes()



proc getIoBlockCount*(pathStr: string): int64 =
    ## @returns the count of assigned IO-Blocks of the File-System-Entry.
    ## @returns -1 if the IoBlockCount could not be determined.
    return file_utils.getFileStatus(pathStr).ioBlockCount()



proc getUserId*(pathStr: string): int32 =
    ## @returns an int >= 0 containing the UserId which is assigned to the existing FileSystemEntry.
    ## @returns -1 otherwise
    return file_utils.getFileStatus(pathStr).userId()



proc getGroupId*(pathStr: string): int32 =
    ## @returns an int >= 0 containing the GroupId which is assigned to the existing FileSystemEntry.
    ## @returns -1 otherwise
    return file_utils.getFileStatus(pathStr).groupId()



proc getCountHardlinks*(pathStr: string): int32 =
    ## @returns the count of hardlinks of the File-System-Entry.
    ## @returns -1 if the count could not be determined.
    return file_utils.getFileStatus(pathStr).countHardlinks()



proc hasSetUidBit*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and has the Set-Uid-Bit set.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).hasSetUidBit()



proc hasSetGidBit*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and has the Set-Gid-Bit set.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).hasSetGidBit()



proc hasStickyBit*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and has the Sticky-Bit set.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).hasStickyBit()



proc getLastAccessTime*(pathStr: string): times.Time =
    ## @returns the Time when the stated Path was last accessed.
    ## @returns 0.Time if the FileStat is in Error-State or the FileType does not support Prefered Block-Size.
    return file_utils.getFileStatus(pathStr).getLastAccessTime()



proc getLastChangeTime*(pathStr: string): times.Time =
    ## @returns the Time when the content of the stated Path was last changed.
    ## @returns 0.Time if the FileStat is in Error-State.
    return file_utils.getFileStatus(pathStr).getLastChangeTime()



proc getLastStatusChangeTime*(pathStr: string): times.Time =
    ## @returns the Time when the status of stated Path was last changed.
    ## @returns 0.Time if the FileStat is in Error-State.
    return file_utils.getFileStatus(pathStr).getLastStatusChangeTime()



proc isUserOwned*(pathStr: string): bool =
    ## @returns true
    ##     if the File-System-Entry exists and the effective userId of the
    ##     current process is the owner of the file.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isUserOwned()



proc isGroupOwned*(pathStr: string): bool =
    ## @returns true
    ##     if the File-System-Entry exists and the effective groupId of the
    ##     current process is the owner of the file.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isGroupOwned()



proc isGroupMember*(pathStr: string): bool =
    ## @returns true if the named file exists and the effective user is member to the group of the the file.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isGroupMember()



proc isReadable*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and is readable by any means for the current process.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isReadable()



proc isReadableByUser*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and is readable by direct user ownership of the current process.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isReadableByUser()



proc isReadableByGroup*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and is readable by group ownership of the current process.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isReadableByGroup()



proc isReadableByOther*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and is readable by any other means of the current process.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isReadableByOther()



proc isWritable*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and is writable by any means for the current process.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isWritable()



proc isWritableByUser*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and is writable by direct user ownership of the current process.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isWritableByUser()



proc isWritableByGroup*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and is writable by group ownership of the current process.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isWritableByGroup()



proc isWritableByOther*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and is writable by any other means of the current process.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isWritableByOther()



proc isExecutable*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and is executable by any means for the current process.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isExecutable()



proc isExecutableByUser*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and is executable by direct user ownership of the current process.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isExecutableByUser()



proc isExecutableByGroup*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and is executable by group ownership of the current process.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isExecutableByGroup()



proc isExecutableByOther*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and is executable by any other means of the current process.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isExecutableByOther()



proc isMountpoint*(pathStr: string): bool =
    ## @returns true if File-System-Entry exists and is a mountpoint.
    ## @returns false otherwise
    return file_utils.getFileStatus(pathStr).isMountpoint()


proc readAll*(pathStr: string): string {.raises: [IOError].} =
    ## @returns Returns ALL data from the current File (Regular, Character Devices, Pipes).
    ## @raises An IOError if the file could not be read.
    return io.readFile(pathStr)


proc read*(pathStr: string): string {.inline,raises: [IOError].} =
    ## @returns Returns ALL data from the current File (Regular, Character Devices, Pipes).
    ## @raises An IOError if the file could not be read.
    return file_utils.readAll(pathStr)


proc read*(pathStr: string, length: Natural, offset: int64 = -1): string {.raises: [IOError].} =
    ## @returns Returns length bytes of data from the current File (Regular, Character Devices, Pipes).
    ## @raises An IOError if the file could not be read.
    var file: File
    if offset < -1:
        raise newException(IOError, "Invalid offset: " & $offset)
    if not file.open(pathStr, FileMode.fmRead):
        raise newException(IOError, "Cannot open: '" & pathStr & "'")
    try:
        if offset >= 0:
            file.setFilePos(offset, FileSeekPos.fspSet)
        result = newString(length)
        let countReaded: int = file.readBuffer(addr(result[0]), length)
        result.setLen(countReaded)
    finally:
        file.close()
    return result



proc open*(pathStr: string, mode: FileMode = FileMode.fmRead; bufSize: int = -1): File {.raises: [IOError].} =
    ## Opens the given File-System-Entry with given mode (default: Readonly) .
    ## @raises An IOError if something went wrong.
    var file: File
    if not file.open(pathStr, mode, bufSize):
        when defined(Posix):
            raise newException(system.IOError, "Cannot open: '" & pathStr & "', CAUSE: '" & $posix.strerror(posix.errno) & "'")
        else:
            raise newException(system.IOError, "Cannot open: '" & pathStr & "'")
    return file




proc touch*(pathStr: string, mode: uint32 = 0o664): void {.raises: [IOError].} =
    ## Updates modification time (mtime) and access time (atime) of file(s) in list.
    ## If no File/Directory exists, they will get created.
    ## @raises An IOError if something went wrong.
    ## The difference to #createFile is, that #touch does not throw an error if the target is not a regular file.
    # Create Regular-File if not already existing ...
    var fileType = file_utils.getFileType(pathStr)
    if not fileType.isExisting():
        when defined(Posix):
            let fileHandle = posix.open(pathStr, posix.O_CREAT or posix.O_WRONLY, mode)
            if fileHandle < 0:
                raise newException(
                    system.IOError,
                    "Failed to touch file '" & pathStr & "' (CAUSE: '" & $posix.strerror(posix.errno) & "')"
                )
            discard posix.close(fileHandle)
            assert(file_utils.getFileType(pathStr).isExisting())
        else:
            file_utils.open(pathStr, FileMode.fmAppend, 0).close()
            assert(file_utils.getFileType(pathStr).isExisting())
            return

    # Update access and modification timestamps ...
    fileType = file_utils.getFileType(pathStr)
    assert(fileType.isExisting())
    when defined(Posix):

        if posix.utimes(pathStr, nil) != 0:
            raise newException(
                system.IOError,
                "Failed to update access and modification timestamps of '" & pathStr & "', CAUSE: '" & $posix.strerror(posix.errno) & "'"
            )
        return

    elif defined(Windows):

        if not fileType.isRegularFile():
            debugEcho "[WARN] touch() update of access/change-time of directories is NOT supported in Windows."
            return

        # see https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilea
        # see https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-setfiletime
        # see https://docs.microsoft.com/en-us/windows/win32/fileio/file-access-rights-constants
        let widePathStr = newWideCString(pathStr)
        let fileHandle = winlean.createFileW(
            widePathStr,
            0x00000100, # == winlean.FILE_WRITE_ATTRIBUTES,
            0,
            nil,
            winlean.OPEN_EXISTING,
            winlean.FILE_ATTRIBUTE_NORMAL,
            winlean.Handle(0)
        )
        if fileHandle == winlean.INVALID_HANDLE_VALUE:
            let lastError = winlean.getLastError()
            raise newException(
                system.IOError,
                "Failed to update access and modification time of '" & pathStr & "', CAUSE: 'could not open (" & $lastError & ")'"
            )
        defer:
            discard winlean.closeHandle(fileHandle)
        let currWinFileTime: FILETIME = winlean.toFILETIME(times.toWinTime(times.getTime()))
        let isSetTimeFailed: bool = winlean.setFileTime(fileHandle, nil, unsafeAddr currWinFileTime, unsafeAddr currWinFileTime) == 0
        if isSetTimeFailed:
            let lastError = winlean.getLastError()
            raise newException(
                system.IOError,
                "Failed to update access and modification time of '" & pathStr & "', CAUSE: 'could not set time (" & $lastError & ")'"
            )
        return

    else:

        debugEcho "[WARN] touch() update of file-access/change-time NOT supported for the current architecture."
        return



#-----------------------------------------------------------------------------------------------------------------------
# FileUtils - createFile()/removeFile()
#-----------------------------------------------------------------------------------------------------------------------



proc createFile*(pathStr: string, mode: uint32 = 0o664): void {.raises: [IOError].} =
    ## Creates an empty regular File.
    ## If the fs-entry already exists and it is a regular file nothing happens.
    ## If the fs-entry already exists but is not a regular file an IOError is raised.
    ## @raises An IOError if the fs-entry already exists but is not a regular file.
    ## The difference to #touch is, that #touch does not throw an error if the target is not a regular file.
    ## Alias:
    ## * `createFile() proc <#createFile,Pathname>`_
    ## * `createRegularFile() proc <#createRegularFile,Pathname>`_
    file_utils.createRegularFile(pathStr, mode)
    assert(file_utils.getFileType(pathStr).isRegularFile())



proc removeFile*(pathStr: string): void {.raises: [IOError].} =
    ## Removes a file but no directories like regular-, fifo-, link-, device-files.
    ## This proc differs from removeRegularFile(), that it removes every file based type (regular, link, pipe, devices).
    ## @raises An IOError if the referenced FS-Entry is existing but is not a regular file, link, pipe, or device.
    ## @raises An IOError if the referenced FS-Entry could not be removed (due permissions).
    # @see https://stackoverflow.com/questions/15335223/what-happens-when-unlink-a-directory/15335559#15335559
    # @see man 2 unlink
    let fileType = file_utils.getFileType(pathStr)
    if fileType.isNotExisting():
        return
    assert(fileType.isExisting())
    if fileType.isDirectory():
        raise newException(system.IOError, "Cannot remove '" & pathStr & "' because it is a directory")
    assert(not fileType.isDirectory())
    when defined(Posix):
        if posix.unlink(pathStr) != 0 and posix.errno != posix.ENOENT:
            raise newException(
                system.IOError,
                "Failed to remove file '" & pathStr & "', CAUSE: '" & $posix.strerror(posix.errno) & "'"
            )
    else:
        try:
            os.removeFile(pathStr)
        except CatchableError as e:
            raise newException(
                system.IOError,
                "Failed to remove file '" & pathStr & "' (CAUSE: '" & e.msg & "')"
            )
    assert(not file_utils.getFileType(pathStr).isExisting())



#-----------------------------------------------------------------------------------------------------------------------
# FileUtils - createRegularFile()/removeRegularFile()
#-----------------------------------------------------------------------------------------------------------------------



proc createRegularFile*(pathStr: string, mode: uint32 = 0o664): void {.raises: [IOError].} =
    ## Creates an empty regular File.
    ## If the fs-entry already exists and it is a regular file nothing happens.
    ## If the fs-entry already exists but is not a regular file an IOError is raised.
    ## @raises An IOError if the fs-entry already exists but is not a regular file.
    ## The difference to #touch is, that #touch does not throw an error if the target is not a regular file.
    let fileType = file_utils.getFileType(pathStr)
    if fileType.isRegularFile():
        return
    assert(not fileType.isRegularFile())
    if fileType.isExisting():
        raise newException(system.IOError, "Cannot create regular file' " & pathStr & "' (does already exist as non regular file)")
    assert(fileType.isNotExisting())
    when defined(Posix):
        let fileHandle = posix.open(pathStr, posix.O_CREAT or posix.O_WRONLY, mode)
        if fileHandle < 0:
            raise newException(
                system.IOError,
                "Failed to create file '" & pathStr & "' (CAUSE: '" & $posix.strerror(posix.errno) & "')"
            )
        discard posix.close(fileHandle)
    else:
        file_utils.open(pathStr, FileMode.fmAppend, 0).close()
    assert(file_utils.getFileType(pathStr).isRegularFile())



proc removeRegularFile*(pathStr: string): void {.discardable,raises: [IOError].} =
    ## Removes a regular file and only that.
    ## @raises An IOError if the referenced FS-Entry is existing but is not a regular file, or could not be deleted.
    # @see https://stackoverflow.com/questions/15335223/what-happens-when-unlink-a-directory/15335559#15335559
    # @see man 2 unlink
    let fileType = file_utils.getFileType(pathStr)
    if fileType.isNotExisting():
        return
    assert(fileType.isExisting())
    if not fileType.isRegularFile():
        raise newException(system.IOError, "Cannot remove '" & pathStr & "' because it is not a regular file")
    assert(fileType.isRegularFile())
    when defined(Posix):
        if posix.unlink(pathStr) != 0 and posix.errno != posix.ENOENT:
            raise newException(
                system.IOError,
                "Failed to remove regular file '" & pathStr & "', CAUSE: '" & $posix.strerror(posix.errno) & "'"
            )
    else:
        try:
            os.removeFile(pathStr)
        except CatchableError as e:
            raise newException(
                system.IOError,
                "Failed to remove file '" & pathStr & "' (CAUSE: '" & e.msg & "')"
            )
    assert(not file_utils.getFileType(pathStr).isExisting())



#-----------------------------------------------------------------------------------------------------------------------
# FileUtils - createDirectory() / removeDirectory() / rmDir()
#-----------------------------------------------------------------------------------------------------------------------


proc createDirectory*(pathStr: string, mode: uint32 = 0o777): void {.raises: [IOError],inline.} =
    ## Creates an empty Directory.
    ## If the fs-entry already exists and it is a directory nothing happens.
    ## If the fs-entry already exists but is not a directory an IOError is raised.
    ## @param mode The unix-Mode (OPTIONAL, default: ugo=rwx respecting the umask)
    ## @raises An IOError if the fs-entry already exists but is not a directory or the directory could not be created.
    ## Alias:
    ## * `createDirectory() proc <#createDirectory,Pathname>`_
    ## * `createEmptyDirectory() proc <#createEmptyDirectory,Pathname>`_
    file_utils.createEmptyDirectory(pathStr, mode)
    assert(file_utils.getFileType(pathStr).isDirectory())



proc removeDirectory*(pathStr: string, isRecursive: bool = false): void {.raises: [IOError].} =
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
    if isRecursive:
        file_utils.removeDirectoryTree(pathStr)
    else:
        file_utils.removeEmptyDirectory(pathStr)
    assert(not file_utils.getFileType(pathStr).isExisting())



#-----------------------------------------------------------------------------------------------------------------------
# FileUtils - createEmptyDirecotry()/removeEmptyDirectory()
#-----------------------------------------------------------------------------------------------------------------------



proc createEmptyDirectory*(pathStr: string, mode: uint32 = 0o777): void {.raises: [IOError].} =
    ## Creates an empty Directory.
    ## If the fs-entry already exists and it is a directory nothing happens.
    ## If the fs-entry already exists but is not a directory an IOError is raised.
    ## @raises An IOError if the fs-entry already exists but is not a directory or the directory could not be created.
    ## Alias:
    ## * `createDirectory() proc <#createDirectory,Pathname>`_
    ## * `createEmptyDirectory() proc <#createEmptyDirectory,Pathname>`_
    # @see man 2 mkdir
    let fileType = file_utils.getFileType(pathStr)
    if fileType.isDirectory():
        return
    assert(not fileType.isDirectory())
    if fileType.isExisting():
        raise newException(system.IOError, "Cannot create directory '" & pathStr & "' (does already exist as non directory)")
    assert(fileType.isNotExisting())
    when defined(Posix):
        if unlikely( posix.mkdir(pathStr, mode) != 0 ):
            raise newException(
                system.IOError,
                "Failed to create directory '" & pathStr & "' (CAUSE: '" & $posix.strerror(posix.errno) & "')"
            )
    else:
        try:
            os.createDir(pathStr)
        except CatchableError as e:
            raise newException(
                system.IOError,
                "Failed to create directory '" & pathStr & "' (CAUSE: '" & e.msg & "')"
            )
    assert(file_utils.getFileType(pathStr).isDirectory())



proc removeEmptyDirectory*(pathStr: string): void {.raises: [IOError].} =
    ## Removes an empty directory and only that.
    ## @raises An IOError if the referenced FS-Entry is existing but is not an empty directory, or could not be deleted.
    ## See also:
    ## * `removeDirectory() proc <#removeDirectory,Pathname>`_
    ## * `removeEmptyDirectory() proc <#removeEmptyDirectory,Pathname>`_
    ## * `removeDirectoryTree() proc <#removeDirectoryTree,Pathname>`_
    # @see https://stackoverflow.com/questions/15335223/what-happens-when-unlink-a-directory/15335559#15335559
    # @see man 2 rmdir
    let fileType = file_utils.getFileType(pathStr)
    if fileType.isNotExisting():
        return
    assert(fileType.isExisting())
    if not fileType.isDirectory():
        raise newException(system.IOError, "Cannot remove '" & pathStr & "' because it is not a directory")
    assert(fileType.isDirectory())
    when defined(Posix):
        if unlikely( posix.rmdir(pathStr) != 0 ):
            raise newException(
                system.IOError,
                "Failed to remove directory '" & pathStr & "', CAUSE: '" & $posix.strerror(posix.errno) & "'"
            )
    elif defined(Windows):
        # see https://github.com/nim-lang/Nim/blob/version-1-2/lib/pure/os.nim#L2183
        let widePathStr = newWideCString(pathStr)
        let res = winlean.removeDirectoryW(widePathStr)
        if unlikely( res == 0 ):
            let lastError = winlean.getLastError()
            var isError = true
            isError = isError and lastError.int32 !=  2
            isError = isError and lastError.int32 !=  3
            isError = isError and lastError.int32 != 18
            if unlikely( isError ):
                # TODO: lastError in eine Message umwandeln
                raise newException(
                    system.IOError,
                    "Failed to remove directory '" & pathStr & "', CAUSE: '" & $lastError & "'"
                )
    else:
        raise newException(
            system.IOError,
            "removeEmptyDirectory is NOT supported for the current architecture"
        )
    assert(not file_utils.getFileType(pathStr).isExisting())




#-----------------------------------------------------------------------------------------------------------------------
# FileUtils - removeDirectoryTree()
#-----------------------------------------------------------------------------------------------------------------------



proc removeDirectoryTree*(pathStr: string): void {.raises: [IOError].} =
    ## Removes a directory with all its contents (eg. recursively).
    ## Please be cautious if using this proc.
    ## @see `os.removeDir() proc <#os.removeDir,string>`_
    let fileType = file_utils.getFileType(pathStr)
    if fileType.isNotExisting():
        return
    assert(fileType.isExisting())
    if not fileType.isDirectory():
        raise newException(system.IOError, "Cannot remove '" & pathStr & "' (CAUSE: 'Not a directory')")
    assert(fileType.isDirectory())
    try:
        os.removeDir(pathStr)
    except CatchableError as e:
        raise newException(
            system.IOError,
            "Failed to remove directory tree '" & pathStr & "' (CAUSE: '" & e.msg & "')"
        )
    assert(not file_utils.getFileType(pathStr).isExisting())




#-----------------------------------------------------------------------------------------------------------------------
# FileUtils - createPipeFile()/removePipeFile()
#-----------------------------------------------------------------------------------------------------------------------



proc createPipeFile*(pathStr: string, mode: uint32 = 0o660): void {.raises: [IOError,NotSupportedError].} =
    ## Creates a named Pipe (aka Fifo). May not be supported on some platforms.
    ## If the fs-entry already exists and it is a named pipe nothing happens.
    ## If the fs-entry already exists but is not a named pipe an IOError is raised.
    ## @param mode The unix-Mode (OPTIONAL, default: ug=rw,o= respecting the active umask)
    ## @raises An IOError if the fs-entry already exists but is not a named pipe.
    ## @raises An IOError if the fs-entry could not be created.
    ## Alias:
    ## * `createPipeFile() proc <#createPipeFile,Pathname>`_
    ## * `createFifo() proc <#createFifo,Pathname>`_
    # @see man 3 mkfifo
    when file_utils.ArePipesSupported:
        let fileType = file_utils.getFileType(pathStr)
        if fileType.isExisting():
            raise newException(system.IOError, "Cannot create named pipe '" & pathStr & "' (file does already exist)")
        assert(fileType.isNotExisting())
        when defined(Posix):
            if posix.mkfifo(pathStr, mode) != 0:
                raise newException(
                    system.IOError,
                    "Failed to create named pipe '" & pathStr & "' (CAUSE: '" & $posix.strerror(posix.errno) & "')"
                )
            assert(file_utils.getFileType(pathStr).isPipeFile())
        else:
            raise newException(
                file_utils.NotSupportedError,
                "createPipeFile is NOT supported for the current architecture"
            )
    else:
        raise newException(
            file_utils.NotSupportedError,
            "createPipeFile() is NOT supported for the current architecture"
        )



proc removePipeFile*(pathStr: string): void {.raises: [IOError,NotSupportedError].} =
    ## Removes a named pipe file and only that. May not be supported on some platforms.
    ## @raises An IOError if the referenced FS-Entry is existing but is not a pipe file, or could not be deleted.
    ## Alias:
    ## * `removePipeFile() proc <#removePipeFile,Pathname>`_
    ## * `removeFifo() proc <#removeFifo,Pathname>`_
    # @see https://stackoverflow.com/questions/15335223/what-happens-when-unlink-a-directory/15335559#15335559
    # @see man 2 unlink
    when file_utils.ArePipesSupported:
        let fileType = file_utils.getFileType(pathStr)
        if fileType.isNotExisting():
            return
        assert(fileType.isExisting())
        if not fileType.isPipeFile():
            raise newException(system.IOError, "Cannot remove '" & pathStr & "' because it is not a pipe file")
        assert(fileType.isPipeFile())
        when defined(Posix):
            if posix.unlink(pathStr) != 0 and posix.errno != posix.ENOENT:
                raise newException(
                    system.IOError,
                    "Failed to remove pipe file '" & pathStr & "', CAUSE: '" & $posix.strerror(posix.errno) & "'"
                )
            assert(not file_utils.getFileType(pathStr).isExisting())
        else:
            raise newException(
                file_utils.NotSupportedError,
                "removePipeFile is NOT supported for the current architecture"
            )
    else:
        raise newException(
            file_utils.NotSupportedError,
            "removePipeFile is NOT supported for the current architecture"
        )



#-----------------------------------------------------------------------------------------------------------------------
# FileUtils - createFifo()/removeFifo() (alias from createPipeFile()/removePipeFile())
#-----------------------------------------------------------------------------------------------------------------------



proc createFifo*(pathStr: string, mode: uint32 = 0o660): void {.inline,raises: [IOError,NotSupportedError].} =
    ## Creates a named Pipe (aka Fifo). May not be supported on some platforms.
    ## If the fs-entry already exists and it is a named pipe nothing happens.
    ## If the fs-entry already exists but is not a named pipe an IOError is raised.
    ## @param mode The unix-Mode (OPTIONAL, default: ug=rw,o= respecting the active umask)
    ## @raises An IOError if the fs-entry already exists but is not a named pipe.
    ## @raises An IOError if the fs-entry could not be created.
    ## Alias:
    ## * `createPipeFile() proc <#createPipeFile,Pathname>`_
    ## * `createFifo() proc <#createFifo,Pathname>`_
    # @see man 3 mkfifo
    file_utils.createPipeFile(pathStr, mode)
    assert(file_utils.getFileType(pathStr).isPipeFile())



proc removeFifo*(pathStr: string): void {.inline,raises: [IOError,NotSupportedError].} =
    ## Removes a named pipe file and only that. May not be supported on some platforms.
    ## @raises An IOError if the referenced FS-Entry is existing but is not a pipe file, or could not be deleted.
    ## Alias:
    ## * `removePipeFile() proc <#removePipeFile,Pathname>`_
    ## * `removeFifo() proc <#removeFifo,Pathname>`_
    file_utils.removePipeFile(pathStr)
    assert(not file_utils.getFileType(pathStr).isExisting())



#-----------------------------------------------------------------------------------------------------------------------
# FileUtils - createCharacterDeviceFile() / removeCharacterDeviceFile()
#-----------------------------------------------------------------------------------------------------------------------



#TODO: Testen ...
proc createCharacterDeviceFile*(pathStr: string, major: uint8, minor: uint8, mode: uint32 = 0o600): void {.raises: [IOError,NotSupportedError].} =
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
    when file_utils.AreDeviceFilesSupported:
        let fileType = file_utils.getFileType(pathStr)
        if fileType.isExisting():
            raise newException(system.IOError, "Cannot create character device file '" & pathStr & "' (file does already exist)")
        assert(fileType.isNotExisting())
        when defined(Posix):
            proc posixMakeDev(major: uint, minor: uint): Dev {.importc: "makedev",header: "<sys/sysmacros.h>", sideEffect.}
            let dev = posixMakeDev(major, minor) and Dev(posix.S_IFCHR)
            if posix.mknod(pathStr, mode, dev) != 0:
                let errorNumber = posix.errno;
                if file_utils.getFileType(pathStr).isExisting():
                    discard posix.unlink(pathStr)
                raise newException(
                    system.IOError,
                    "Failed to create character device file '" & pathStr & "' (CAUSE: '" & $posix.strerror(errorNumber) & "')"
                )
            # mknod scheint irgendeine Art von Fehler aufzuweisen, so dass eine normale Datei erstellt wird,
            # statt ein Fehler zu liefern, wenn der User keine ausreichenden Privilegien besitzt ...
            let fileTypeAfter = file_utils.getFileType(pathStr)
            if fileTypeAfter.isExisting() and not fileTypeAfter.isBlockDeviceFile():
                discard posix.unlink(pathStr)
                raise newException(
                    system.IOError,
                    "Failed to create block device file '" & pathStr & "' (CAUSE: 'block device file was not properly created')"
                )
            assert(file_utils.getFileType(pathStr).isCharacterDeviceFile())
        else:
            raise newException(
                file_utils.NotSupportedError,
                "createCharacterDeviceFile() is NOT supported for the current architecture"
            )
    else:
        raise newException(
            file_utils.NotSupportedError,
            "createCharacterDeviceFile() is NOT supported for the current architecture"
        )



#TODO: Testen ...
proc removeCharacterDeviceFile*(pathStr: string): void {.raises: [IOError,NotSupportedError].} =
    ## Removes a character-device-file and only that.
    ## @raises An IOError if the referenced FS-Entry is existing but is not a character-device-file, or could not be deleted.
    ## See also:
    ## * `removeCharacterDeviceFile() proc <#removeCharacterDeviceFile,Pathname>`_
    ## * `removeBlockDeviceFile() proc <#removeBlockDeviceFile,Pathname>`_
    ## * `removeDeviceFile() proc <#removeDeviceFile,Pathname>`_
    # @see man 2 unlink
    when file_utils.AreDeviceFilesSupported:
        let fileType = file_utils.getFileType(pathStr)
        if fileType.isNotExisting():
            return
        assert(fileType.isExisting())
        if not fileType.isCharacterDeviceFile():
            raise newException(system.IOError, "Cannot remove '" & pathStr & "' because it is not a character device file")
        assert(fileType.isCharacterDeviceFile())
        when defined(Posix):
            if posix.unlink(pathStr) != 0 and posix.errno != posix.ENOENT:
                raise newException(
                    system.IOError,
                    "Failed to remove character device file '" & pathStr & "', CAUSE: '" & $posix.strerror(posix.errno) & "'"
                )
            assert(not file_utils.getFileType(pathStr).isExisting())
        else:
            raise newException(
                file_utils.NotSupportedError,
                "removeCharacterDeviceFile() is NOT supported for the current architecture"
            )
    else:
        raise newException(
            file_utils.NotSupportedError,
            "removeCharacterDeviceFile() is NOT supported for the current architecture"
        )



#-----------------------------------------------------------------------------------------------------------------------
# FileUtils - createBlockDeviceFile()/removeCharacterDeviceFile()
#-----------------------------------------------------------------------------------------------------------------------



#TODO: Testen ...
proc createBlockDeviceFile*(pathStr: string, major: uint8, minor: uint8, mode: uint32 = 0o600): void {.raises: [IOError,NotSupportedError].} =
    ## Creates a block-device-file (only unix/linux).
    ## If the fs-entry already exists and it is a block-device-file, nothing happens.
    ## If the fs-entry already exists but is not a block-device file an IOError is raised.
    ## @param mode The unix-Mode (OPTIONAL, default: u=rw,go= respecting the active umask)
    ## @param major The Major-Number of the Device-File
    ## @param minor The Minor-Number of the Device-File
    ## @raises An IOError if the fs-entry already exists but is not a device-file.
    ## @raises An IOError if the fs-entry could not be created.
    ## See also:
    ## * `createCharacterDeviceFile() proc <#createCharacterDeviceFile,Pathname>`_
    ## * `createBlockDeviceFile() proc <#createBlockDeviceFile,Pathname>`_
    # @see man 2 mknod
    # @see man 3 makedev
    when file_utils.AreDeviceFilesSupported:
        let fileType = file_utils.getFileType(pathStr)
        if fileType.isExisting():
            raise newException(system.IOError, "Cannot create block device file'" & pathStr & "' (file does already exist)")
        assert(fileType.isNotExisting())
        when defined(Posix):
            proc posixMakeDev(major: uint, minor: uint): Dev {.importc: "makedev",header: "<sys/sysmacros.h>", sideEffect.}
            let dev = posixMakeDev(major, minor) and Dev(posix.S_IFBLK)
            if posix.mknod(pathStr, mode, dev) != 0:
                let errorNumber = posix.errno;
                if file_utils.getFileType(pathStr).isExisting():
                    discard posix.unlink(pathStr)
                raise newException(
                    system.IOError,
                    "Failed to create block device file '" & pathStr & "' (CAUSE: '" & $posix.strerror(errorNumber) & "')"
                )
            # mknod scheint irgendeine Art von Fehler aufzuweisen, so dass eine normale Datei erstellt wird,
            # statt ein Fehler zu liefern, wenn der User keine ausreichenden Privilegien besitzt ...
            let fileTypeAfter = file_utils.getFileType(pathStr)
            if fileTypeAfter.isExisting() and not fileTypeAfter.isBlockDeviceFile():
                discard posix.unlink(pathStr)
                raise newException(
                    system.IOError,
                    "Failed to create block device file '" & pathStr & "' (CAUSE: 'block device file was not properly created')"
                )
            assert(file_utils.getFileType(pathStr).isBlockDeviceFile())
        else:
            raise newException(
                file_utils.NotSupportedError,
                "createBlockDeviceFile() is NOT supported for the current architecture"
            )
    else:
        raise newException(
            file_utils.NotSupportedError,
            "createBlockDeviceFile() is NOT supported for the current architecture"
        )



#TODO: Testen ...
proc removeBlockDeviceFile*(pathStr: string): void {.raises: [IOError,NotSupportedError].} =
    ## Removes a character-device-file and only that.
    ## @raises An IOError if the referenced FS-Entry is existing but is not a character-device-file, or could not be deleted.
    ## See also:
    ## * `removeCharacterDeviceFile() proc <#removeCharacterDeviceFile,Pathname>`_
    ## * `removeBlockDeviceFile() proc <#removeBlockDeviceFile,Pathname>`_
    ## * `removeDeviceFile() proc <#removeDeviceFile,Pathname>`_
    # @see man 2 unlink
    when file_utils.AreDeviceFilesSupported:
        let fileType = FileStatus.fromPathStr(pathStr)
        if fileType.isNotExisting():
            return
        assert(fileType.isExisting())
        if not fileType.isBlockDeviceFile():
            raise newException(system.IOError, "Cannot remove '" & pathStr & "' because it is not a block device file")
        assert(fileType.isBlockDeviceFile())
        when defined(Posix):
            if posix.unlink(pathStr) != 0 and posix.errno != posix.ENOENT:
                raise newException(
                    system.IOError,
                    "Failed to remove block device file '" & pathStr & "', CAUSE: '" & $posix.strerror(posix.errno) & "'"
                )
            assert(not file_utils.getFileType(pathStr).isExisting())
        else:
            raise newException(
                file_utils.NotSupportedError,
                "removeBlockDeviceFile() is NOT supported for the current architecture"
            )
    else:
        raise newException(
            file_utils.NotSupportedError,
            "removeBlockDeviceFile() is NOT supported for the current architecture"
        )



#-----------------------------------------------------------------------------------------------------------------------
# FileUtils - removeDeviceFile()
#-----------------------------------------------------------------------------------------------------------------------



#TODO: Testen ...
proc removeDeviceFile*(pathStr: string): void {.raises: [IOError,NotSupportedError].} =
    ## Removes a device-file (block- and character) and only that.
    ## @raises An IOError if the referenced FS-Entry is existing but is not a device-file, or could not be deleted.
    ## See also:
    ## * `removeCharacterDeviceFile() proc <#removeCharacterDeviceFile,Pathname>`_
    ## * `removeBlockDeviceFile() proc <#removeBlockDeviceFile,Pathname>`_
    ## * `removeDeviceFile() proc <#removeDeviceFile,Pathname>`_
    # @see man 2 unlink
    when file_utils.AreDeviceFilesSupported:
        let fileType = file_utils.getFileType(pathStr)
        if fileType.isNotExisting():
            return
        assert(fileType.isExisting())
        if not fileType.isDeviceFile():
            raise newException(system.IOError, "Cannot remove '" & pathStr & "' because it is not a device file")
        assert(fileType.isDeviceFile())
        when defined(Posix):
            if posix.unlink(pathStr) != 0 and posix.errno != posix.ENOENT:
                raise newException(
                    system.IOError,
                    "Failed to remove device file '" & pathStr & "', CAUSE: '" & $posix.strerror(posix.errno) & "'"
                )
            assert(not file_utils.getFileType(pathStr).isExisting())
        else:
            raise newException(
                file_utils.NotSupportedError,
                "removeDeviceFile() is NOT supported for the current architecture"
            )
    else:
        raise newException(
            file_utils.NotSupportedError,
            "removeDeviceFile() is NOT supported for the current architecture"
        )



#-----------------------------------------------------------------------------------------------------------------------
# FileUtils - createSymlink() / removeSymlink()
#-----------------------------------------------------------------------------------------------------------------------



proc createSymlink*(srcPath: string, dstPath: string): void {.raises: [IOError,NotSupportedError].} =
    ## Creates a Symlink dstPath pointing to srcPath.
    ## @raises An IOError if the fs-entry already exists.
    when file_utils.ArePipesSupported:
        if file_utils.getFileType(dstPath).isExisting():
            raise newException(system.IOError, "Cannot create symlink '" & dstPath & "' -> '" & srcPath & "' (does already exist)")
        try:
            os.createSymlink(srcPath, dstPath)
        except CatchableError as e:
            raise newException(
                system.IOError,
                "Failed to create symlink '" & dstPath & "' -> '" & srcPath & "' (CAUSE: '" & e.msg & "')"
            )
        assert(file_utils.getFileType(dstPath).isSymlink())
    else:
        raise newException(
            file_utils.NotSupportedError,
            "createSymlink() is NOT supported for the current architecture"
        )



proc removeSymlink*(pathStr: string): void {.raises: [IOError,NotSupportedError].} =
    ## Removes a symlink and only that.
    ## @raises An IOError if the referenced FS-Entry is existing but is not a symlink, or could not be deleted.
    # @see man 2 unlink
    when file_utils.ArePipesSupported:
        let fileType = file_utils.getFileType(pathStr)
        if fileType.isNotExisting():
            return
        assert(fileType.isExisting())
        if not fileType.isSymlink():
            raise newException(system.IOError, "Cannot remove '" & pathStr & "' because it is not a symlink")
        assert(fileType.isSymlink())
        when defined(Posix):
            if posix.unlink(pathStr) != 0 and posix.errno != posix.ENOENT:
                raise newException(
                    system.IOError,
                    "Failed to remove symlink '" & pathStr & "', CAUSE: '" & $posix.strerror(posix.errno) & "'"
                )
            assert(not file_utils.getFileType(pathStr).isExisting())
        else:
            raise newException(
                file_utils.NotSupportedError,
                "removeSymlink is NOT supported for the current architecture"
            )
    else:
        raise newException(
            file_utils.NotSupportedError,
            "removeSymlink is NOT supported for the current architecture"
        )



#-----------------------------------------------------------------------------------------------------------------------
# FileUtils - remove()
#-----------------------------------------------------------------------------------------------------------------------


#TODO: Testen ...
proc remove*(pathStr: string): void {.raises: [IOError].} =
    ## Removes the FS-Entry, regardles of the type of the FS-Entry or it is a directory with content.
    ## Please be cautious if using this proc, and use one of the specific remove-Procs if possible.
    let fileType = file_utils.getFileType(pathStr)

    if fileType.isNotExisting():
        return

    elif fileType.isDirectory():
        try:
            os.removeDir(pathStr)
        except CatchableError as e:
            raise newException(
                system.IOError,
                "Failed to remove directory '" & pathStr & "' (CAUSE: '" & e.msg & "')"
            )
        return

    elif fileType.isRegularFile() or fileType.isDeviceFile() or fileType.isSymlink() or fileType.isPipeFile() or fileType.isSocketFile():
        when defined(Posix):
            if posix.unlink(pathStr) != 0 and posix.errno != posix.ENOENT:
                raise newException(
                    system.IOError,
                    "Failed to remove file '" & pathStr & "', CAUSE: '" & $posix.strerror(posix.errno) & "'"
                )
            return
        else:
            try:
                os.removeFile(pathStr)
            except CatchableError as e:
                raise newException(
                    system.IOError,
                    "Failed to remove file '" & pathStr & "' (CAUSE: '" & e.msg & "')"
                )

    else:
        raise newException(
            system.IOError,
            "Failed to remove '" & pathStr & "', CAUSE: 'Filetype not supported: " & $fileType & "'"
        )
    assert(not file_utils.getFileType(pathStr).isExisting())




#-----------------------------------------------------------------------------------------------------------------------
# FileUtils - dirEntries()
#-----------------------------------------------------------------------------------------------------------------------



#TODO: testen
proc dirEntries*(pathStr: string, isAbsolute: bool = false): seq[string] =
    ## Lists the files of the addressed directory as plain Strings.
    let fileType = file_utils.getFileType(pathStr)
    if not fileType.isDirectory():
        raise newException(system.IOError, "Cannot list directory '" & pathStr & "' because it is not a directory or does not exist")
    assert(fileType.isDirectory())
    for file in walkDir(pathStr, relative = not isAbsolute):
        result.add(file.path)
    return result
