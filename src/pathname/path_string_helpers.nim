###
# Helpers to support implementation of Pathname.
#
# author:  Raimund Hübel <raimund.huebel@googlemail.com>
###



import os

when defined(Posix):
    import strutils



#TODO: testen
proc extractDirname*(pathStr: string): string =
    ## @returns the Directory-Part of the given string.
    var endPos: int = pathStr.len
    if endPos == 0:
        return "."
    # '/' die am Ende stehen ignorieren.
    while endPos > 0 and pathStr[endPos-1] == '/':
        endPos -= 1
    # Basename ignorieren.
    while endPos > 0 and pathStr[endPos-1] != '/':
        endPos -= 1
    # '/' die vor Basenamen stehen ignorieren.
    while endPos > 0 and pathStr[endPos-1] == '/':
        endPos -= 1
    assert( endPos >= 0 )
    assert( endPos <= pathStr.len )
    var resultDirnameStr: string
    if endPos > 0:
        resultDirnameStr = substr(pathStr, 0, endPos - 1)
    elif endPos == 0:
        # Kein Dirname vorhanden ...
        if pathStr.len > 0 and pathStr[0] == '/':
            # Bei absoluten Pfad die '/' am Anfang wieder herstellen.
            #DEPRECATED resultDirnameStr = "/"
            endPos += 1
            while endPos < pathStr.len and pathStr[endPos] == '/':
                endPos += 1
            resultDirnameStr = substr(pathStr, 0, endPos - 1)
        else:
            resultDirnameStr = "."
    else:
        echo "extractDirname - wtf - endPos < 0"
        resultDirnameStr = "."
    return resultDirnameStr



#TODO: testen
proc extractBasename*(pathStr: string): string =
    ## @returns the Basename-Part of the given string.
    if pathStr.len == 0:
        return pathStr
    var endPos: int = pathStr.len
    # '/' die am Ende stehen ignorieren.
    while endPos > 0 and pathStr[endPos-1] == '/':
        endPos -= 1
    # Denn Anfang des Basenamen ermitteln.
    var startPos: int = endPos
    while startPos > 0 and pathStr[startPos-1] != '/':
        startPos -= 1
    assert( startPos >= 0 )
    assert( endPos   >= 0 )
    assert( startPos <= pathStr.len )
    assert( endPos   <= pathStr.len )
    assert( startPos <= endPos )
    var resultBasenameStr: string
    if startPos < endPos:
        resultBasenameStr = substr(pathStr, startPos, endPos-1)
    elif startPos == endPos:
        if pathStr[startPos] == '/':
            resultBasenameStr = "/"
        else:
            resultBasenameStr = ""
    else:
        echo "extractBasename - wtf - startPos >= endPos"
        resultBasenameStr = ""
    return resultBasenameStr



#TODO: testen
proc extractExtension*(pathStr: string): string =
    ## @returns the File-Extension-Part of the given string.
    var endPos: int = pathStr.len
    # '/' die am Ende stehen ignorieren.
    while endPos > 0 and pathStr[endPos-1] == '/':
        endPos -= 1
    # Wenn nichts vorhanden, oder am Ende ein '.' ist, dann fast exit.
    if endPos == 0 or pathStr[endPos-1] == '.':
        return ""
    # Denn Anfang der Extension ermitteln.
    var startPos: int = endPos
    while startPos > 0 and pathStr[startPos-1] != '/' and pathStr[startPos-1] != '.':
        startPos -= 1
    # '.' die evtl. mehrfach vor der Extension stehen konsumieren.
    while startPos > 0 and pathStr[startPos-1] == '.':
        startPos -= 1
    ## auf ersten Punkt navigieren ...
    #while startPos < endPos and pathStr[startPos] == '.':
    #    startPos += 1
    assert( startPos >= 0 )
    assert( endPos   >= 0 )
    assert( startPos <= pathStr.len )
    assert( endPos   <= pathStr.len )
    assert( startPos <= endPos )
    var resultExtnameStr: string
    if startPos < endPos:
        if startPos > 0 and pathStr[startPos-1] != '/':
            # Alle '.' am Anfang eines Pfad-Items konsumieren (startPos zeigt auf ersten Punkt).
            while startPos < endPos and pathStr[startPos+1] == '.':
                startPos += 1
            resultExtnameStr = substr(pathStr, startPos, endPos-1)
        else:
            resultExtnameStr = ""
    elif startPos == endPos:
        resultExtnameStr = ""
    else:
        echo "extractExtension - wtf - startPos >= endPos"
        resultExtnameStr = ""
    return resultExtnameStr



#TODO: testen
proc isAbsolutePathStringPosix*(pathstr: string): bool =
    ## Gibt an ob es sich um ein absoluten Pfad unter Posix-Systemen handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    if pathstr.len == 0: return false
    return pathstr[0] == '/'



#TODO: testen
proc isAbsolutePathStringWindows*(pathstr: string): bool =
    ## Gibt an ob es sich um ein absoluten Pfad unter Windows/Dos-Systemen handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    if pathstr.len == 0: return false
    return (
        ( pathstr.len >= 1  and  pathstr[0] in { '/', '\\' } ) or
        ( pathstr.len == 2  and  pathstr[0] in {'a'..'z', 'A'..'Z'}  and  pathstr[1] == ':' ) or
        ( pathstr.len >= 3  and  pathstr[0] in {'a'..'z', 'A'..'Z'}  and  pathstr[1] == ':'  and  pathstr[2] == '/' )
    )



#TODO: testen
proc isAbsolutePathStringMacOs*(pathstr: string): bool =
    ## Gibt an ob es sich um ein absoluten Pfad unter MacOs-Systemen handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    if pathstr.len == 0: return false
    # according to https://perldoc.perl.org/File/Spec/Mac.html `:a` is a relative path
    return pathstr[0] != ':'



#TODO: testen
proc isAbsolutePathStringRiscOs*(pathstr: string): bool =
    ## Gibt an ob es sich um ein absoluten Pfad unter RiscOs-Systemen handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    if pathstr.len == 0: return false
    return pathstr[0] == '$'



#TODO: testen
proc isAbsolutePathString*(pathstr: string): bool {.inline.} =
    ## Gibt an ob es sich um ein absoluten Pfad im aktuellen Betriebssystem handelt.
    ## @see https://nim-lang.org/docs/os.html#isAbsolute%2Cstring
    when os.doslikeFileSystem:
        return isAbsolutePathStringWindows(pathstr)
    elif defined(macos):
        return isAbsolutePathStringMacOs(pathstr)
    elif defined(RISCOS):
        return isAbsolutePathStringRiscOs(pathstr)
    elif defined(posix):
        return isAbsolutePathStringPosix(pathstr)



#TODO: testen
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

        var pathComponents = strutils.split(pathStr, '/')
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



#TODO: testen
proc joinPathComponents*(basePath: string, pathComponent1: string, additionalPathComponents: varargs[string]): string =
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
    # Remove Trailing /
    for idx in (0..<resultPathComponents.len-1):
        var pc: string = resultPathComponents[idx]
        while pc.endsWith(os.DirSep):
            pc = pc[0..^2]
        resultPathComponents[idx] = pc
    # Remove Leading /
    for idx in (1..<resultPathComponents.len):
        var pc: string = resultPathComponents[idx]
        while pc.startsWith(os.DirSep):
            pc = pc[1..^1]
        resultPathComponents[idx] = pc
    result = resultPathComponents.join($os.DirSep)
    #result = normalizePathString(result) # NO
    return result

