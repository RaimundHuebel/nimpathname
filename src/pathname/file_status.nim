###
# Pathname-FileStatus Implementation to provide a os-independent method to handle informations about
# file-system-entries.
#
# author:  Raimund Hübel <raimund.huebel@googlemail.com>
###


import pathname/file_type

when defined(Posix):
    import posix



type FileStatus* = object
    ## Type which stores Information about an File-System-Entity.
    pathStr:             string
    fileType:            FileType
    fileSizeInBytes:     int64     # Size of file in bytes
    userId:              int32
    groupId:             int32
    linkCount:           int32
    ioBlockSizeInBytes:  int32     # Size of an IO-Block to use for optimal IO-Throughput
    ioBlockCount:        int32     # Count of assigned IO-Blocks



proc init*(fileStatus: var FileStatus) =
    ## Initializes the FileStatus to an empty state.
    fileStatus.pathStr            = ""
    fileStatus.fileType           = FileType.NOT_EXISTING
    fileStatus.fileSizeInBytes    = -1
    fileStatus.userId             = -1
    fileStatus.groupId            = -1
    fileStatus.ioBlockSizeInBytes = -1
    fileStatus.ioBlockCount       = -1


proc fromPathStr*(class: typedesc[FileStatus], pathStr: string): FileStatus =
    ## @return The FileStatus of File-System-Entry of given pathStr.
    result = FileStatus()
    result.init()
    result.pathStr  = pathStr
    when defined(Posix):
        var res: posix.Stat

        if posix.lstat(result.pathStr, res) < 0:
            result.fileType = FileType.NOT_EXISTING
            return result

        ## FileType ...
        if   posix.S_ISREG(res.st_mode):  result.fileType = FileType.REGULAR_FILE
        elif posix.S_ISDIR(res.st_mode):  result.fileType = FileType.DIRECTORY
        elif posix.S_ISLNK(res.st_mode):  result.fileType = FileType.SYMLINK
        elif posix.S_ISBLK(res.st_mode):  result.fileType = FileType.BLOCK_DEVICE
        elif posix.S_ISCHR(res.st_mode):  result.fileType = FileType.CHARACTER_DEVICE
        else:                             result.fileType = FileType.UNKNOWN

        ## FileSize ...
        result.fileSizeInBytes = res.st_size.int64

        ## User-ID ...
        result.userId = res.st_uid.int32

        ## Group-ID ...
        result.groupId = res.st_gid.int32

        ## Count Hardlinks ...
        result.linkCount = res.st_nlink.int32

        ## IO-Block-Size ...
        result.ioBlockSizeInBytes = res.st_blksize.int32

        ## IO-Block-Count ...
        result.ioBlockCount = res.st_blocks.int32

        return result

    else:
        return result



proc getPathStr*(self: FileStatus): string =
    ## @returns the PathStr of the File-System-Entry.
    return self.pathStr



proc getFileSizeInBytes*(self: FileStatus): int64 =
    ## @returns the FileSize of the File-System-Entry in Bytes.
    ## @returns -1 if the FileSize could not be determined.
    return self.fileSizeInBytes


proc getIoBlockSizeInBytes*(self: FileStatus): int32 =
    ## @returns the Size of an IO-Block of the File-System-Entry in Bytes.
    ## @returns -1 if the BlockSize could not be determined.
    return self.ioBlockSizeInBytes


proc getUserId*(self: FileStatus): string =
    ## @returns the User-Id of the File-System-Entry.
    ## @returns -1 if the User-Id could not be determined.
    return self.pathStr



proc getGroupId*(self: FileStatus): string =
    ## @returns the Group-Id of the File-System-Entry.
    ## @returns -1 if the Group-Id could not be determined.
    return self.pathStr



proc isExisting*(self: FileStatus): bool =
    ## @returns true if the File-System-Entry is existing and reachable.
    return self.fileType != FileType.NOT_EXISTING



proc isNotExisting*(self: FileStatus): bool =
    ## @returns true if the File-System-Entry is neither existing nor reachable.
    return self.fileType == FileType.NOT_EXISTING



proc isUnknown*(self: FileStatus): bool =
    ## @returns true if type the File-System-Entry is of unknown type.
    return self.fileType == FileType.UNKNOWN



proc isRegularFile*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a regular file.
    return self.fileType == FileType.REGULAR_FILE



proc isDirectory*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a directory.
    return self.fileType == FileType.DIRECTORY



proc isSymlink*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a symlink.
    return self.fileType == FileType.SYMLINK



proc isDeviceFile*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a device-file (either block- or character-device).
    return self.fileType == FileType.CHARACTER_DEVICE  or  self.fileType == FileType.BLOCK_DEVICE



proc isCharacterDeviceFile*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a character-device-file.
    return self.fileType == FileType.CHARACTER_DEVICE



proc isBlockDeviceFile*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a block-device-file.
    return self.fileType == FileType.BLOCK_DEVICE


#TODO: & is automatically provided.
