###
# Pathname-FileStatus Implementation to provide a os-independent method to handle informations about
# file-system-entries.
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


import pathname/file_type

import times
export times

when defined(Posix):
    import posix



type FileStatus* = object
    ## Type which stores Information about an File-System-Entity.
    pathStr:             string
    fileType:            FileType
    fileSizeInBytes:     int64        ## Size of file in bytes
    userId:              int32
    groupId:             int32
    linkCount:           int32
    ioBlockSizeInBytes:  int32        ## Size of an IO-Block to use for optimal IO-Throughput
    ioBlockCount:        int32        ## Count of assigned IO-Blocks
    lastAccessTime:      times.Time   ## Time file was last accessed.
    lastWriteTime:       times.Time   ## Time file was last modified/written to.
    creationTime:        times.Time   ## Time file was created. Not supported on all systems!
    isHidden:            bool
    hasSetUidBit:        bool
    hasSetGidBit:        bool
    hasStickyBit:        bool



proc init*(fileStatus: var FileStatus) =
    ## Initializes the FileStatus to an empty state.
    fileStatus.pathStr            = ""
    fileStatus.fileType           = FileType.NOT_EXISTING
    fileStatus.fileSizeInBytes    = -1
    fileStatus.userId             = -1
    fileStatus.groupId            = -1
    fileStatus.ioBlockSizeInBytes = -1
    fileStatus.ioBlockCount       = -1
    fileStatus.lastAccessTime     = times.initTime(0, 0)
    fileStatus.lastWriteTime      = times.initTime(0, 0)
    fileStatus.creationTime       = times.initTime(0, 0)
    fileStatus.isHidden           = false
    fileStatus.hasSetUidBit       = false
    fileStatus.hasSetGidBit       = false
    fileStatus.hasStickyBit       = false



proc fromPathStr*(class: typedesc[FileStatus], pathStr: string): FileStatus =
    ## @return The FileStatus of File-System-Entry of given pathStr.
    result = FileStatus()
    result.init()
    result.pathStr = pathStr
    when defined(Posix):
        var res: posix.Stat

        if posix.lstat(result.pathStr, res) < 0:
            result.fileType = FileType.NOT_EXISTING
            return result

        ## isHidden ...
        result.isHidden = os.isHidden(result.pathStr)

        ## FileType ...
        if   posix.S_ISREG(res.st_mode):  result.fileType = FileType.REGULAR_FILE
        elif posix.S_ISDIR(res.st_mode):  result.fileType = FileType.DIRECTORY
        elif posix.S_ISLNK(res.st_mode):  result.fileType = FileType.SYMLINK
        elif posix.S_ISBLK(res.st_mode):  result.fileType = FileType.BLOCK_DEVICE
        elif posix.S_ISCHR(res.st_mode):  result.fileType = FileType.CHARACTER_DEVICE
        elif posix.S_ISSOCK(res.st_mode): result.fileType = FileType.SOCKET_FILE
        elif posix.S_ISFIFO(res.st_mode): result.fileType = FileType.PIPE_FILE
        else:                             result.fileType = FileType.UNKNOWN

        ## has...Bits ...
        result.hasSetUidBit = (res.st_mode.cint and posix.S_ISUID) == posix.S_ISUID
        result.hasSetGidBit = (res.st_mode.cint and posix.S_ISGID) == posix.S_ISGID
        result.hasStickyBit = (res.st_mode.cint and posix.S_ISVTX) == posix.S_ISVTX


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

        ## File-Times ...
        result.lastAccessTime = times.initTime(res.st_atim.tv_sec.int64, res.st_atim.tv_nsec.int)
        result.lastWriteTime  = times.initTime(res.st_mtim.tv_sec.int64, res.st_mtim.tv_nsec.int)
        result.creationTime   = times.initTime(res.st_ctim.tv_sec.int64, res.st_ctim.tv_nsec.int)

        return result

    else:
        return result



proc getPathStr*(self: FileStatus): string =
    ## @returns the PathStr of the File-System-Entry if available.
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
    ## @returns false otherwise
    return self.fileType != FileType.NOT_EXISTING



proc isNotExisting*(self: FileStatus): bool =
    ## @returns true if the File-System-Entry is neither existing nor reachable.
    ## @returns false otherwise
    return self.fileType == FileType.NOT_EXISTING



proc isUnknown*(self: FileStatus): bool =
    ## @returns true if type the File-System-Entry is of unknown type.
    ## @returns false otherwise
    return self.fileType == FileType.UNKNOWN



proc isRegularFile*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a regular file.
    ## @returns false otherwise
    return self.fileType == FileType.REGULAR_FILE



proc isDirectory*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a directory.
    ## @returns false otherwise
    return self.fileType == FileType.DIRECTORY



proc isSymlink*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a symlink.
    ## @returns false otherwise
    return self.fileType == FileType.SYMLINK



proc isDeviceFile*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a device-file (either block- or character-device).
    ## @returns false otherwise
    return self.fileType == FileType.CHARACTER_DEVICE  or  self.fileType == FileType.BLOCK_DEVICE



proc isCharacterDeviceFile*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a character-device-file.
    ## @returns false otherwise
    return self.fileType == FileType.CHARACTER_DEVICE



proc isBlockDeviceFile*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a block-device-file.
    ## @returns false otherwise
    return self.fileType == FileType.BLOCK_DEVICE



proc isSocketFile*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a unix socket file.
    ## @returns false otherwise
    return self.fileType == FileType.SOCKET_FILE



proc isPipeFile*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a named pipe file.
    ## @returns false otherwise
    return self.fileType == FileType.PIPE_FILE



proc isHidden*(self: FileStatus): bool =
    ## Returns true if the File-System-Entry directs to an existing hidden file/directory/etc.
    ## Returns false otherwise.
    ## See also:
    ## * `os.isHidden() proc <#os.isHidden,string>`_
    ## * `isHidden() proc <#isHidden,FileStatus>`_
    ## * `isVisible() proc <#isVisible,FileStatus>`_
    return self.fileType != FileType.NOT_EXISTING  and  self.isHidden



proc isVisible*(self: FileStatus): bool =
    ## Returns true if the File-System-Entry directs to an existing visible file/directory/etc (eg. is NOT hidden).
    ## Returns false otherwise.
    ## See also:
    ## * `os.isHidden() proc <#os.isHidden,string>`_
    ## * `isHidden() proc <#isHidden,FileStatus>`_
    ## * `isVisible() proc <#isVisible,FileStatus>`_
    return self.fileType != FileType.NOT_EXISTING  and  not self.isHidden



proc isZeroSizeFile*(self: FileStatus): bool =
    ## @returns true if File-System-Entry is a regular file and has a file-size of zero.
    ## @returns false otherwise
    return self.fileType == FileType.REGULAR_FILE  and  self.fileSizeInBytes == 0



proc hasSetUidBit*(self: FileStatus): bool =
    ## @returns true if File-System-Entry exists and has the Set-Uid-Bit set.
    ## @returns false otherwise
    return self.hasSetUidBit



proc hasSetGidBit*(self: FileStatus): bool =
    ## @returns true if File-System-Entry exists and has the Set-Gid-Bit set.
    ## @returns false otherwise
    return self.hasSetGidBit



proc hasStickyBit*(self: FileStatus): bool =
    ## @returns true if File-System-Entry exists and has the Sticky-Bit set.
    ## @returns false otherwise
    return self.hasStickyBit



#TODO: noch zu implementieren
proc isReadable*(self: FileStatus): bool =
    ## @returns true if File-System-Entry exists and is readable by the current process.
    ## @returns false otherwise
    return false



#TODO: noch zu implementieren
proc isWritable*(self: FileStatus): bool =
    ## @returns true if File-System-Entry exists and is writable by the current process.
    ## @returns false otherwise
    return false



#TODO: noch zu implementieren
proc isExecutable*(self: FileStatus): bool =
    ## @returns true if File-System-Entry exists and is executable for the current process.
    ## @returns false otherwise
    return false



#TODO: noch zu implementieren
proc isUserOwned*(self: FileStatus): bool =
    ## Returns true if the File-System-Entry exists and the effective userId of the
    ## current process is the owner of the file.
    ## @returns false otherwise
    return false



#TODO: noch zu implementieren
proc isGroupOwned*(self: FileStatus): bool =
    ## Returns true if the File-System-Entry exists and the effective groupId of the
    ## current process is the owner of the file.
    ## @returns false otherwise
    return false




#SPÄTER proc isEmpty*(self: FileStatus): bool {.inline.} =
#SPÄTER     ## @returns true if File-System-Entry either:
#SPÄTER     ## * is a File with zero-size
#SPÄTER     ## * or is Directory with child elements
#SPÄTER     ## @returns false otherwise
#SPÄTER     ## See also:
#SPÄTER     ## * `isEmpty() proc <#isEmpty,FileStatus>`_
#SPÄTER     ## * `isZeroSize() proc <#isZeroSize,FileStatus>`_
#SPÄTER     return self.isZeroSize()



#TODO: & is automatically provided.
