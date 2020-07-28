###
# Pathname-FileType Implementation to provide a way to better differ the Type/Mode of a File-System-Entry.
#
# author:  Raimund Hübel <raimund.huebel@googlemail.com>
#
# ## See also:
# * `https://en.wikipedia.org/wiki/Unix_file_types`
###

when defined(Posix):
    import posix

when defined(Windows):
    import os
    import winlean
    const INVALID_FILE_ATTRIBUTES = -1'i32


type FileType* {.pure.} = enum
    ## Enum which tells the Type/Mode of the File in OS independent manner.
    NOT_EXISTING,
    UNKNOWN,
    REGULAR_FILE,
    DIRECTORY,
    SYMLINK,
    CHARACTER_DEVICE,
    BLOCK_DEVICE,
    SOCKET_FILE,
    PIPE_FILE



proc fromPathStr*(class: typedesc[FileType], pathStr: string): FileType =
    ## @return The FileType of File-System-Entry of given OS-dependent pathStr.
    if pathStr.len == 0:
        return FileType.NOT_EXISTING

    when defined(Posix):
        var res: posix.Stat

        if unlikely(posix.lstat(pathStr, res) < 0):
            return FileType.NOT_EXISTING

        if   posix.S_ISREG(res.st_mode):  return FileType.REGULAR_FILE
        elif posix.S_ISDIR(res.st_mode):  return FileType.DIRECTORY
        elif posix.S_ISLNK(res.st_mode):  return FileType.SYMLINK
        elif posix.S_ISBLK(res.st_mode):  return FileType.BLOCK_DEVICE
        elif posix.S_ISCHR(res.st_mode):  return FileType.CHARACTER_DEVICE
        elif posix.S_ISSOCK(res.st_mode): return FileType.SOCKET_FILE
        elif posix.S_ISFIFO(res.st_mode): return FileType.PIPE_FILE
        else:                             return FileType.UNKNOWN

    elif defined(Windows):
        let widePathStr = newWideCString(pathStr)

        let fileAttribs = winlean.getFileAttributesW(widePathStr)
        if fileAttribs == INVALID_FILE_ATTRIBUTES:
            return FileType.NOT_EXISTING

        result = FileType.UNKNOWN
        if   0 != (fileAttribs and winlean.FILE_ATTRIBUTE_DEVICE   ): result = FileType.UNKNOWN  # Device-Files not supported in Windows
        elif 0 != (fileAttribs and winlean.FILE_ATTRIBUTE_DIRECTORY): result = FileType.DIRECTORY
        elif 0 == (fileAttribs and winlean.FILE_ATTRIBUTE_DIRECTORY): result = FileType.REGULAR_FILE

        # Nachkorrektur, damit verhalten, ähnlich zu Posix-Variante.
        assert pathStr.len > 0
        if result == FileType.REGULAR_FILE and pathStr[pathStr.len-1] == os.DirSep:
            result = FileType.NOT_EXISTING

        return result

    else:
        return FileType.NOT_EXISTING



proc isExisting*(self: FileType): bool {.inline,noSideEffect.} =
    ## @returns true if the File-System-Entry is existing and reachable.
    ## @returns false otherwise
    return self != FileType.NOT_EXISTING



proc isNotExisting*(self: FileType): bool {.inline,noSideEffect.} =
    ## @returns true if the File-System-Entry is neither existing nor reachable.
    ## @returns false otherwise
    return self == FileType.NOT_EXISTING



proc isUnknownFileType*(self: FileType): bool {.inline,noSideEffect.} =
    ## @returns true if type the File-System-Entry is unknown.
    ## @returns false otherwise
    return self == FileType.UNKNOWN



proc isRegularFile*(self: FileType): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry is a regular file.
    ## @returns false otherwise
    return self == FileType.REGULAR_FILE



proc isDirectory*(self: FileType): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry is a directory.
    ## @returns false otherwise
    return self == FileType.DIRECTORY



proc isSymlink*(self: FileType): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry is a symlink.
    ## @returns false otherwise
    return self == FileType.SYMLINK



proc isDeviceFile*(self: FileType): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry is a device-file (either block- or character-device).
    ## @returns false otherwise
    return self == FileType.CHARACTER_DEVICE  or  self == FileType.BLOCK_DEVICE



proc isCharacterDeviceFile*(self: FileType): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry is a character-device-file.
    ## @returns false otherwise
    return self == FileType.CHARACTER_DEVICE



proc isBlockDeviceFile*(self: FileType): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry is a block-device-file.
    ## @returns false otherwise
    return self == FileType.BLOCK_DEVICE



proc isSocketFile*(self: FileType): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry is a unix socket file.
    ## @returns false otherwise
    return self == FileType.SOCKET_FILE



proc isPipeFile*(self: FileType): bool {.inline,noSideEffect.} =
    ## @returns true if File-System-Entry is a named pipe file.
    ## @returns false otherwise
    return self == FileType.PIPE_FILE


# & is automatically provided.
