###
# Learn Nim by Practice.
#
# license: MIT
# author:  Raimund Hübel <raimund.huebel@googlemail.com>
#
# ## compile and run + tooling:
#
#   ## Seperated compile and run steps ...
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
# ## See Also:
# - https://nim-lang.org/docs/docgen.html
# - https://nim-lang.org/documentation.html
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
import strutils

when defined(Posix):
    import posix


## Import: realpath (@see module posix)
when defined(Posix):

    const PATH_MAX = 4096'u
    proc posixRealpath(name: cstring, resolved: cstring): cstring {. importc: "realpath", header: "<stdlib.h>" .}

else:
    # TODO: Support other Plattforms ...
    {.fatal: "The current plattform is not supported by utils.file_stat!".}


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


type FileType* {.pure.} = enum
    UNKNOWN = 0,
    REGULAR_FILE,
    DIRECTORY,
    SYMLINK,
    CHARACTER_DEVICE,
    BLOCK_DEVICE

proc isUnknown*(self: FileType): bool =
    return self == FileType.UNKNOWN

proc isRegularFile*(self: FileType): bool =
    return self == FileType.REGULAR_FILE

proc isDirectory*(self: FileType): bool =
    return self == FileType.DIRECTORY

proc isSymLink*(self: FileType): bool =
    return self == FileType.SYMLINK

proc isDeviceFile*(self: FileType): bool =
    return self == FileType.CHARACTER_DEVICE  or  self == FileType.BLOCK_DEVICE

proc isCharacterDeviceFile*(self: FileType): bool =
    return self == FileType.CHARACTER_DEVICE

proc isBlockDeviceFile*(self: FileType): bool =
    return self == FileType.BLOCK_DEVICE




proc isAbsolutePathStringPosix(pathstr: string): bool =
    ## Gibt an ob es sich um ein absoluten Pfad unter Posix-Systemen handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    if pathstr.len == 0: return false
    return pathstr[0] == '/'


proc isAbsolutePathStringWindows(pathstr: string): bool =
    ## Gibt an ob es sich um ein absoluten Pfad unter Windows/Dos-Systemen handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    if pathstr.len == 0: return false
    return (
        ( pathstr.len >= 1  and  pathstr[0] in { '/', '\\' } ) or
        ( pathstr.len == 2  and  pathstr[0] in {'a'..'z', 'A'..'Z'}  and  pathstr[1] == ':' ) or
        ( pathstr.len >= 3  and  pathstr[0] in {'a'..'z', 'A'..'Z'}  and  pathstr[1] == ':'  and  pathstr[2] == '/' )
    )


proc isAbsolutePathStringMacOs(pathstr: string): bool =
    ## Gibt an ob es sich um ein absoluten Pfad unter MacOs-Systemen handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    if pathstr.len == 0: return false
    # according to https://perldoc.perl.org/File/Spec/Mac.html `:a` is a relative path
    return pathstr[0] != ':'


proc isAbsolutePathStringRiscOs(pathstr: string): bool =
    ## Gibt an ob es sich um ein absoluten Pfad unter RiscOs-Systemen handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    if pathstr.len == 0: return false
    return pathstr[0] == '$'


proc isAbsolutePathString(pathstr: string): bool {.inline.} =
    ## Gibt an ob es sich um ein absoluten Pfad im aktuellen Betriebssystem handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    when doslikeFileSystem:
        return isAbsolutePathStringWindows(pathstr)
    elif defined(macos):
        return isAbsolutePathStringMacOs(pathstr)
    elif defined(RISCOS):
        return isAbsolutePathStringRiscOs(pathstr)
    elif defined(posix):
        return isAbsolutePathStringPosix(pathstr)



proc normalizePathString*(pathstr: string): string =
    ## Normalisiert ein Pfadnamen auf die kürzeste Darstellung.
    ## @see https://nim-lang.org/docs/os.html#normalizedPath
    ## @see https://www.linuxjournal.com/content/normalizing-path-names-bash
    ## @see https://ruby-doc.org/stdlib/libdoc/pathname/rdoc/Pathname.html#method-i-cleanpath
    ## @see https://ruby-doc.org/stdlib/libdoc/pathname/rdoc/Pathname.html#method-i-realpath
    if pathstr.len == 0:
        return "."

    when defined(Posix):
        let isAbsolutePath = isAbsolutePathStringPosix(pathstr)

        var pathComponents = pathStr.split('/')
        var pathLength :int = 0
        var currPos    :int = 0

        while currPos < pathComponents.len:
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
            # Wenn es ein relativer Pfad war, und dieser Elemente hat dann gebe diesen einfach zurück.
            result = pathComponents.join("/")
        else:
            # Wenn es ein relativer Pfad war, und dieser keine Elemente hat, dann gebe aktuellen Pfad zurück.
            result = "."

        return result

    elif defined(Windows):
        # os.normalizePath(...) is available since Nim v0.19.0, may have incorrect results.
        return os.normalizedPath(pathstr)

    else:
        # os.normalizePath(...) is available since Nim v0.19.0, may have incorrect results.
        return os.normalizedPath(pathstr)




type Pathname* = ref object
    ## Class for presenting Paths to files and directories,
    ## including a rich fluent API to support easy Development.
    path :string



proc new*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Current Directory as Path.
    ## @returns An Pathname-Instance.
    ## @usage Pathname.new()
    return Pathname(path: os.getCurrentDir())


proc new*(class: typedesc[Pathname], path: string): Pathname =
    ## Constructs a new Pathname.
    ## @param path The Directory which shall be listed.
    ## @returns An Pathname-Instance.
    ## @usage Pathname.new("/a/sample/path")
    return Pathname(path: path)


proc fromCurrentDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Current Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromCurrentDir()
    return Pathname.new(os.getCurrentDir())


proc fromAppDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the App Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromAppDir()
    return Pathname.new(os.getAppDir())


proc fromAppFile*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the App File as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromAppFile()
    return Pathname.new(os.getAppFilename())


proc fromTempDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Temp Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromTempDir()
    return Pathname.new(os.getTempDir())


proc fromRootDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Temp Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromRootDir()
    return Pathname.new("/")


proc fromUserConfigDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Config Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromUserConfigDir()
    return Pathname.new(os.getConfigDir())


proc fromUserHomeDir*(class: typedesc[Pathname]): Pathname =
    ## Constructs a new Pathname with the Config Directory as Path.
    ## @returns A Pathname-Instance.
    ## @usage Pathname.fromUserHomeDir()
    return Pathname.new(os.getHomeDir())



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



proc dirname*(self: Pathname): Pathname =
    ## Returns the Directory-Part of the Pathname as Pathname.
    var endPos: int = self.path.len
    # '/' die am Ende stehen ignorieren.
    while endPos > 0 and self.path[endPos-1] == '/':
        endPos -= 1
    # Basename ignorieren.
    while endPos > 0 and self.path[endPos-1] != '/':
        endPos -= 1
    # '/' die vor Basenamen stehen ignorieren.
    while endPos > 0 and self.path[endPos-1] == '/':
        endPos -= 1
    assert( endPos >= 0 )
    assert( endPos <= self.path.len )
    var resultDirnameStr: string
    if endPos > 0:
        resultDirnameStr = substr(self.path, 0, endPos - 1)
    elif endPos == 0:
        # Kein Dirname vorhanden ...
        if self.path.len > 0 and self.path[0] == '/':
            # Bei absoluten Pfad die '/' am Anfang wieder herstellen.
            #DEPRECATED resultDirnameStr = "/"
            endPos += 1
            while endPos < self.path.len and self.path[endPos] == '/':
                endPos += 1
            resultDirnameStr = substr(self.path, 0, endPos - 1)
        else:
            resultDirnameStr = "."
    else:
        echo "Pathname.dirname - wtf - endPos < 0"; quit(1)
    return Pathname.new(resultDirnameStr)



proc basename*(self: Pathname): Pathname =
    if self.path.len == 0:
        return self
    ## Returns the Filepart-Part of the Pathname as Pathname.
    var endPos: int = self.path.len
    # '/' die am Ende stehen ignorieren.
    while endPos > 0 and self.path[endPos-1] == '/':
        endPos -= 1
    # Denn Anfang des Basenamen ermitteln.
    var startPos: int = endPos
    while startPos > 0 and self.path[startPos-1] != '/':
        startPos -= 1
    assert( startPos >= 0 )
    assert( endPos   >= 0 )
    assert( startPos <= self.path.len )
    assert( endPos   <= self.path.len )
    assert( startPos <= endPos )
    var resultBasenameStr: string
    if startPos < endPos:
        resultBasenameStr = substr(self.path, startPos, endPos-1)
    elif startPos == endPos:
        if self.path[startPos] == '/':
            resultBasenameStr = "/"
        else:
            resultBasenameStr = ""
    else:
        echo "Pathname.basename - wtf - startPos >= endPos"; quit(1)
    return Pathname.new(resultBasenameStr)



proc extname*(self: Pathname): string =
    ## Returns the File-Extension-Part of the Pathname as string.
    var endPos: int = self.path.len
    # '/' die am Ende stehen ignorieren.
    while endPos > 0 and self.path[endPos-1] == '/':
        endPos -= 1
    # Wenn nichts vorhanden, oder am Ende ein '.' ist, dann fast exit.
    if endPos == 0 or self.path[endPos-1] == '.':
        return ""
    # Denn Anfang der Extension ermitteln.
    var startPos: int = endPos
    while startPos > 0 and self.path[startPos-1] != '/' and self.path[startPos-1] != '.':
        startPos -= 1
    # '.' die evtl. mehrfach vor der Extension stehen konsumieren.
    while startPos > 0 and self.path[startPos-1] == '.':
        startPos -= 1
    ## auf ersten Punkt navigieren ...
    #while startPos < endPos and self.path[startPos] == '.':
    #    startPos += 1
    assert( startPos >= 0 )
    assert( endPos   >= 0 )
    assert( startPos <= self.path.len )
    assert( endPos   <= self.path.len )
    assert( startPos <= endPos )
    var resultExtnameStr: string
    if startPos < endPos:
        if startPos > 0 and self.path[startPos-1] != '/':
            # Alle '.' am Anfang eines Pfad-Items konsumieren (startPos zeigt auf ersten Punkt).
            while startPos < endPos and self.path[startPos+1] == '.':
                startPos += 1
            resultExtnameStr = substr(self.path, startPos, endPos-1)
        else:
            resultExtnameStr = ""
    elif startPos == endPos:
        resultExtnameStr = ""
    else:
        echo "Pathname.extname - wtf - startPos >= endPos"; quit(1)
    return resultExtnameStr



proc fileType*(self: Pathname): FileType =
    when defined(posix):
        var res: posix.Stat

        if posix.lstat(self.path, res) <= 0:  return FileType.UNKNOWN

        if posix.S_ISREG(res.st_mode):    return FileType.REGULAR_FILE
        elif posix.S_ISDIR(res.st_mode):  return FileType.DIRECTORY
        elif posix.S_ISBLK(res.st_mode):  return FileType.BLOCK_DEVICE
        elif posix.S_ISCHR(res.st_mode):  return FileType.CHARACTER_DEVICE
        else:                             return FileType.UNKNOWN

    else:
        return false



proc isRegularFile*(self: Pathname): bool =
    ## Returns true if the path directs to a file, or a symlink that points at a file,
    ## Returns false otherwise.
    return os.existsFile(self.path)


proc isDirectory*(self: Pathname): bool =
    ## Returns true if the path directs to a directory, or a symlink that points at a directory,
    ## Returns false otherwise.
    return os.existsDir(self.path)


proc isSymlink*(self: Pathname): bool =
    ## Returns true if the path directs to a symlink.
    ## Returns false otherwise.
    return os.symlinkExists(self.path)


proc isDeviceFile*(self: Pathname): bool =
    ## Returns true if the path directs to a device-file (either block or character).
    ## Returns false otherwise.
    when defined(posix):
        # Siehe: https://github.com/nim-lang/Nim/blob/version-1-0/lib/pure/os.nim#L963
        var res: posix.Stat
        return (
            posix.lstat(self.path, res) >= 0 and
            (posix.S_ISBLK(res.st_mode)  or posix.S_ISCHR(res.st_mode))
        )
    else:
        return false


proc isCharacterDeviceFile*(self: Pathname): bool =
    ## Returns true if the path directs to a block-device-file.
    ## Returns false otherwise.
    when defined(posix):
        # Siehe: https://github.com/nim-lang/Nim/blob/version-1-0/lib/pure/os.nim#L963
        var res: posix.Stat
        return posix.lstat(self.path, res) >= 0 and posix.S_ISCHR(res.st_mode)
    else:
        return false


proc isBlockDeviceFile*(self: Pathname): bool =
    ## Returns true if the path directs to a block-device-file.
    ## Returns false otherwise.
    when defined(posix):
        # Siehe: https://github.com/nim-lang/Nim/blob/version-1-0/lib/pure/os.nim#L963
        var res: posix.Stat
        return posix.lstat(self.path, res) >= 0 and posix.S_ISBLK(res.st_mode)
    else:
        return false


proc isExisting*(self: Pathname): bool =
    ## Returns true if the path directs to an existing file-system-entity like a file, directory, device, symlink, ...
    ## Returns false otherwise.
    result = false
    result = result or self.isRegularFile()
    result = result or self.isDirectory()
    result = result or self.isSymlink()
    result = result or self.isDeviceFile()
    return result




proc listDir*(self: Pathname): seq[Pathname] =
    ## Lists the files of the addressed directory as Pathnames.
    var files: seq[Pathname] = @[]
    for file in walkDir(self.path):
        files.add(Pathname.new(file.path))
    return files



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



proc inspect*(self :Pathname) :string =
    ## Converts a Pathname to a String for Diagnostic-Purposes (for Developer).
    return "Pathname(\"" & self.path & "\")"





proc newPathnames*(paths :varargs[string]) :seq[Pathname] =
    var pathnames: seq[Pathname] = newSeq[Pathname](paths.len)
    for i in 0..<paths.len:
        pathnames[i] = Pathname.new(paths[i])
    return @pathnames



proc pathnamesFromRoot*() :seq[Pathname] =
    ## Constructs a List of Pathnames containing all Filesystem-Roots per Entry
    ## @returns A list of Pathnames
    when defined(Windows):
        # WIndows-Version ist noch in Arbeit (siehe unten)
        return newPathnames( os.parentDirs("test/a/b", inclusive=false) )
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




## Noch mitten in der Entwicklung ...
when defined(Windows):
    proc winGetWindowsDirectory(lpBuffer: cstring, uSize :cuint): cuint {. importc: "GetWindowsDirectory", header: "<winbase.h>" .}
    proc fromWindowsInstallDir*(class: typedesc[Pathname]) :Pathname =
        ## Constructs a new Pathname pointing to the Windows-Installation Directory.
        const PATH_MAX = 4096'u
        const maxSize = PATH_MAX
        var pathStr :string = newString(maxSize)
        let realSize :cuint = winGetWindowsDirectory(pathStr, maxSize.cuint)
        if realSize <= 0:
            raiseOSError(osLastError())
        pathStr[maxSize.int-1] = 0.char
        pathStr[realSize.int-1] = 0.char
        pathStr.setLen(realSize)
        return result


## Noch mitten in der Entwicklung ...
when defined(Windows):
    proc winGetSystemWindowsDirectory(lpBuffer: cstring, uSize :cuint): cuint {. importc: "GetSystemWindowsDirectory", header: "<winbase.h>" .}
    proc fromWindowsSystemDir*(class: typedesc[Pathname]) :Pathname =
        ## Constructs a new Pathname pointing to the Windows-System Directory.
        const PATH_MAX = 4096'u
        const maxSize = PATH_MAX
        var pathStr :string = newString(maxSize)
        let realSize :cuint = winGetSystemWindowsDirectory(pathStr, maxSize.cuint)
        if realSize <= 0:
            raiseOSError(osLastError())
        pathStr[maxSize.int-1] = 0.char
        pathStr[realSize.int-1] = 0.char
        pathStr.setLen(realSize)
        return result


## Noch mitten in der Entwicklung ...
when defined(Windows):
    # @see https://msdn.microsoft.com/en-us/library/windows/desktop/aa364975(v=vs.85).aspx
    proc winGetLogicalDriveStrings(nBufferLength :uint32, lpBuffer: cstring): uint32 {. importc: "GetLogicalDriveStrings", header: "<winbase.h.h>" .}
    proc pathnamesFromWindowsDrives*() :string =
        ## Constructs a new Pathname pointing to the Windows-System Directory.
        const PATH_MAX = 4096'u
        const maxSize = PATH_MAX
        var pathStr :string = newString(maxSize)
        let realSize = winGetLogicalDriveStrings(maxSize.uint32, pathStr)
        if realSize <= 0:
            raiseOSError(osLastError())
        if realSize > maxSize:
            raiseOSError(osLastError())  #TODO
        pathStr[maxSize.int-1] = 0.char
        pathStr[realSize.int-1] = 0.char
        pathStr.setLen(realSize)
        return result



when isMainModule:

    echo "Current Directory    : ", Pathname.fromCurrentDir()
    echo "Application File     : ", Pathname.fromAppFile()
    echo "Application Directory: ", Pathname.fromAppDir()
    echo "Temp Directory       : ", Pathname.fromTempDir()
    echo "User Directory       : ", Pathname.fromUserHomeDir()
    echo "User Config-Directory: ", Pathname.fromUserConfigDir()

    echo "Root Directory       : ", Pathname.fromRootDir()
    echo "Root Directories     : ", pathnamesFromRoot()

    echo "Current Directory (inspect): ", Pathname.fromCurrentDir().inspect()
    echo "Root Directories (inspect) : ", pathnamesFromRoot().inspect()


    echo "Current Dir-Content  : ", Pathname.fromCurrentDir().listDir()

    when defined(Windows):
        echo "Windows-Install Directory: ", Pathname.fromWindowsInstallDir()
        echo "Windows-System Directory : ", Pathname.fromWindowsSystemDir()
        echo "Windows-Drives           : ", pathnamesFromWindowsDrives()

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
