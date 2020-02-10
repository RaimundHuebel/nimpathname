###
# Pathname-FileType Implementation to provide a way to better differ the Type/Mode of a File-System-Entry.
#
# author:  Raimund Hübel <raimund.huebel@googlemail.com>
###

when defined(Posix):
    import posix


type FileType* {.pure.} = enum
    ## Enum which tells the Type/Mode of the File in OS independent manner.
    NOT_EXISTING,
    UNKNOWN,
    REGULAR_FILE,
    DIRECTORY,
    SYMLINK,
    CHARACTER_DEVICE,
    BLOCK_DEVICE



proc fromPathStr*(class: typedesc[FileType], pathStr: string): FileType =
    ## @return The FileType of File-System-Entry of given OS-dependent pathStr.
    when defined(Posix):
        var res: posix.Stat

        if posix.lstat(pathStr, res) < 0:
            return FileType.NOT_EXISTING

        if   posix.S_ISREG(res.st_mode):  return FileType.REGULAR_FILE
        elif posix.S_ISDIR(res.st_mode):  return FileType.DIRECTORY
        elif posix.S_ISLNK(res.st_mode):  return FileType.SYMLINK
        elif posix.S_ISBLK(res.st_mode):  return FileType.BLOCK_DEVICE
        elif posix.S_ISCHR(res.st_mode):  return FileType.CHARACTER_DEVICE
        else:                             return FileType.UNKNOWN

    else:
        return FileType.NOT_EXISTING



proc isExisting*(self: FileType): bool =
    ## @returns true if the File-System-Entry is existing and reachable.
    return self != FileType.NOT_EXISTING



proc isNotExisting*(self: FileType): bool =
    ## @returns true if the File-System-Entry is neither existing nor reachable.
    return self == FileType.NOT_EXISTING



proc isUnknown*(self: FileType): bool =
    ## @returns true if type the File-System-Entry is unknown.
    return self == FileType.UNKNOWN



proc isRegularFile*(self: FileType): bool =
    ## @returns true if File-System-Entry is a regular file.
    return self == FileType.REGULAR_FILE



proc isDirectory*(self: FileType): bool =
    ## @returns true if File-System-Entry is a directory.
    return self == FileType.DIRECTORY



proc isSymlink*(self: FileType): bool =
    ## @returns true if File-System-Entry is a symlink.
    return self == FileType.SYMLINK



proc isDeviceFile*(self: FileType): bool =
    ## @returns true if File-System-Entry is a device-file (either block- or character-device).
    return self == FileType.CHARACTER_DEVICE  or  self == FileType.BLOCK_DEVICE



proc isCharacterDeviceFile*(self: FileType): bool =
    ## @returns true if File-System-Entry is a character-device-file.
    return self == FileType.CHARACTER_DEVICE



proc isBlockDeviceFile*(self: FileType): bool =
    ## @returns true if File-System-Entry is a block-device-file.
    return self == FileType.BLOCK_DEVICE

# & is automatically provided.
