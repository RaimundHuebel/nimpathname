###
# Helpers to support implementation of Pathname.
#
# author:  Raimund Hübel <raimund.huebel@googlemail.com>
###



import os



#TODO: testen
proc extractDirname*(pathStr: string): string =
    ## @returns the Directory-Part of the given string.
    var endPos: int = pathStr.len
    if endPos == 0:
        return "."
    # '/' die am Ende stehen ignorieren.
    while endPos > 0 and pathStr[endPos-1] == os.DirSep:
        endPos -= 1
    # Bei Posix-Pfaden prüfen ob es sich um den Root-Pfand handelt, dann early return ...
    when defined(Posix):
        if endPos == 0  and  pathStr.len > 0  and  pathStr[0] == '/':
            return "/"
    # Bei Windows-Pfaden prüfen ob es sich um ein Laufwerksbuchstaben handelt, dann early return ...
    when defined(Windows):
        if endPos == 2  and  pathStr[0] in {'a'..'z', 'A'..'Z'}  and  pathStr[1] == ':':
            return pathStr[0..endPos-1]
    # Basename ignorieren.
    while endPos > 0 and pathStr[endPos-1] != os.DirSep:
        endPos -= 1
    # '/' die vor Basenamen stehen ignorieren.
    while endPos > 0 and pathStr[endPos-1] == os.DirSep:
        endPos -= 1
    assert( endPos >= 0 )
    assert( endPos <= pathStr.len )
    var resultDirnameStr: string
    if endPos > 0:
        resultDirnameStr = pathStr[0..endPos-1]
    else: # if endPos == 0
        # Kein Dirname vorhanden ...
        if pathStr.len > 0 and pathStr[0] == os.DirSep:
            # Bei absoluten Pfad die '/' am Anfang wieder herstellen.
            endPos += 1
            while endPos < pathStr.len and pathStr[endPos] == os.DirSep:
                endPos += 1
            resultDirnameStr = pathStr[0..endPos-1]
        else:
            resultDirnameStr = "."
    return resultDirnameStr



#TODO: testen
proc extractBasename*(pathStr: string): string =
    ## @returns the Basename-Part of the given string.
    if unlikely(pathStr.len == 0):
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
        resultBasenameStr = system.substr(pathStr, startPos, endPos-1)
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
            resultExtnameStr = system.substr(pathStr, startPos, endPos-1)
        else:
            resultExtnameStr = ""
    elif startPos == endPos:
        resultExtnameStr = ""
    else:
        echo "extractExtension - wtf - startPos >= endPos"
        resultExtnameStr = ""
    return resultExtnameStr






#LATER #TODO: testen
#LATER proc trimTrailingPathSeperators*(pathStr: string): string =
#LATER     ## @returns The Path-String with trailing Path-Seperators removed.
#LATER     var endPos: int = pathStr.len
#LATER     if endPos == 0:
#LATER         return "."
#LATER     # '/' die am Ende stehen ignorieren.
#LATER     while endPos > 0 and pathStr[endPos-1] == '/':
#LATER         endPos -= 1
#LATER     assert( endPos >= 0 )
#LATER     assert( endPos <= pathStr.len )
#LATER     var resultDirnameStr: string
#LATER     if endPos > 0:
#LATER         resultDirnameStr = system.substr(pathStr, 0, endPos - 1)
#LATER     elif endPos == 0:
#LATER         # Kein Dirname vorhanden ...
#LATER         if pathStr.len > 0 and pathStr[0] == '/':
#LATER             # Bei absoluten Pfad die '/' am Anfang wieder herstellen.
#LATER             #DEPRECATED resultDirnameStr = "/"
#LATER             endPos += 1
#LATER             while endPos < pathStr.len and pathStr[endPos] == '/':
#LATER                 endPos += 1
#LATER             resultDirnameStr = system.substr(pathStr, 0, endPos - 1)
#LATER         else:
#LATER             resultDirnameStr = "."
#LATER     else:
#LATER         echo "trimTrailingPathSeperators - wtf - endPos < 0"
#LATER         resultDirnameStr = "."
#LATER     return resultDirnameStr





#LATER #TODO: testen
#LATER proc pathEntriesAscending*(pathStr: string): seq[string] =
#LATER     ## @returns The Path-Strings in ascending order until the root-dir.
#LATER     ## @example "/a/b/c/" -> @["/a/b/c", "/a/b", "/a", "/"]
#LATER     var currPathStr = path_string_helpers.trimTrailingPathSeperators(pathStr)
#LATER     result = @[currPathStr]
#LATER     currPathStr = extractDirname(currPathStr)
#LATER     while currPathStr != result[^1]:
#LATER         result.add(currPathStr)
#LATER         currPathStr = extractDirname(currPathStr)
#LATER     return result



#LATER #TODO: testen
#LATER proc pathEntriesDescending*(pathStr: string): seq[string] =
#LATER     ## @returns The Path-Strings in descending order from root-dir.
#LATER     ## @example "/a/b/c/" -> @["/", "/a", "/a/b", "/a/b/c"]
#LATER     var pathEntries: seq[string] = pathEntriesAscending(pathStr)
#LATER     algorithm.reverse(pathEntries)
#LATER     return pathEntries
