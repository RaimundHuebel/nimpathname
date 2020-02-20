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

when defined(Posix):
    import posix
    proc posix_group_member*(gid: posix.Gid): cint {.importc: "group_member", header: "<unistd.h>", noSideEffect.}



type FileStatus* = ref object
    ## Type which stores Information about an File-System-Entity.
    pathStr:           string
    fileType:          FileType
    isHidden:          bool
    when defined(Posix):
        posixFileStat: posix.Stat
    #elif defined(Windows):
    #    discard
    #else:
    #    discard



proc init*(fileStatus: var FileStatus) {.noSideEffect.} =
    ## Initializes the FileStatus to an empty state.
    fileStatus.pathStr  = ""
    fileStatus.fileType = FileType.NOT_EXISTING
    fileStatus.isHidden = false
    when defined(Posix):
        zeroMem(addr fileStatus.posixFileStat, sizeof(posix.Stat))
    else:
        echo "[WARN] FileStatus.init() is not implemented for current Architecture."
        return false



proc fromPathStr*(class: typedesc[FileStatus], pathStr: string): FileStatus {.noSideEffect.} =
    ## @return The FileStatus of File-System-Entry of given pathStr.
    result = FileStatus()
    result.init()
    result.pathStr = pathStr
    when defined(Posix):
        if unlikely(posix.lstat(result.pathStr, result.posixFileStat) < 0):
            result.fileType = FileType.NOT_EXISTING
            return result

        ## FileType ...
        if   posix.S_ISREG(result.posixFileStat.st_mode):  result.fileType = FileType.REGULAR_FILE
        elif posix.S_ISDIR(result.posixFileStat.st_mode):  result.fileType = FileType.DIRECTORY
        elif posix.S_ISLNK(result.posixFileStat.st_mode):  result.fileType = FileType.SYMLINK
        elif posix.S_ISBLK(result.posixFileStat.st_mode):  result.fileType = FileType.BLOCK_DEVICE
        elif posix.S_ISCHR(result.posixFileStat.st_mode):  result.fileType = FileType.CHARACTER_DEVICE
        elif posix.S_ISSOCK(result.posixFileStat.st_mode): result.fileType = FileType.SOCKET_FILE
        elif posix.S_ISFIFO(result.posixFileStat.st_mode): result.fileType = FileType.PIPE_FILE
        else:                                              result.fileType = FileType.UNKNOWN

        ## isHidden ...
        result.isHidden = os.isHidden(result.pathStr)

        return result

    else:
        return result



proc getPathStr*(self: FileStatus): string {.noSideEffect.} =
    ## @returns the PathStr of the File-System-Entry if available.
    ## @returns "" otherwise
    return self.pathStr



proc getFileType*(self: FileStatus): FileType  {.noSideEffect.} =
    ## @returns the FileType of the File-System-Entry if available.
    ## @returns FileType.NOT_EXISTING if either File-System-Entry does not exists or could not be accessed.
    return self.fileType



proc getFileSizeInBytes*(self: FileStatus): int64 {.noSideEffect.} =
    ## @returns the FileSize of the File-System-Entry in Bytes.
    ## @returns -1 if the FileSize could not be determined.
    if self.fileType == FileType.NOT_EXISTING:
        return -1
    when defined(Posix):
        return self.posixFileStat.st_size.int64
    else:
        echo "[WARN] FileStatus.getFileSizeInBytes() is not implemented for current Architecture."
        return false



proc getIoBlockSizeInBytes*(self: FileStatus): int32 {.noSideEffect.} =
    ## @returns the Size of an IO-Block of the File-System-Entry in Bytes.
    ## @returns -1 if the BlockSize could not be determined.
    if self.fileType == FileType.NOT_EXISTING:
        return -1
    when defined(Posix):
        return self.posixFileStat.st_blksize.int32
    else:
        echo "[WARN] FileStatus.getIoBlockSizeInBytes() is not implemented for current Architecture."
        return false



proc getIoBlockCount*(self: FileStatus): int32 {.noSideEffect.} =
    ## @returns the count of assigned IO-Blocks of the File-System-Entry.
    ## @returns -1 if the IoBlockCount could not be determined.
    if self.fileType == FileType.NOT_EXISTING:
        return -1
    when defined(Posix):
        return self.posixFileStat.st_blocks.int32
    else:
        echo "[WARN] FileStatus.getIoBlockCount() is not implemented for current Architecture."
        return false



proc getUserId*(self: FileStatus): int32 {.noSideEffect.} =
    ## @returns an int >= 0 containing the UserId which is assigned to the existing FileSystemEntry.
    ## @returns -1 otherwise
    if self.fileType == FileType.NOT_EXISTING:
        return -1
    when defined(Posix):
        return self.posixFileStat.st_uid.int32
    else:
        echo "[WARN] FileStatus.getUserId() is not implemented for current Architecture."
        return false



proc getGroupId*(self: FileStatus): int32 {.noSideEffect.} =
    ## @returns an int >= 0 containing the GroupId which is assigned to the existing FileSystemEntry.
    ## @returns -1 otherwise
    if self.fileType == FileType.NOT_EXISTING:
        return -1
    when defined(Posix):
        return self.posixFileStat.st_gid.int32
    else:
        echo "[WARN] FileStatus.getGroupId() is not implemented for current Architecture."
        return false



proc getCountHardlinks*(self: FileStatus): int32 {.noSideEffect.} =
    ## @returns the count of hardlinks of the File-System-Entry.
    ## @returns -1 if the count could not be determined.
    if self.fileType == FileType.NOT_EXISTING:
        return -1
    when defined(Posix):
        return self.posixFileStat.st_nlink.int32
    else:
        echo "[WARN] FileStatus.getCountHardlinks() is not implemented for current Architecture."
        return false



proc isExisting*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if the File-System-Entry is existing and reachable.
    ## @returns false otherwise
    return self.fileType != FileType.NOT_EXISTING



proc isNotExisting*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if the File-System-Entry is neither existing nor reachable.
    ## @returns false otherwise
    return self.fileType == FileType.NOT_EXISTING



proc isUnknownFileType*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if type the File-System-Entry is of unknown type.
    ## @returns false otherwise
    return self.fileType == FileType.UNKNOWN



proc isRegularFile*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry is a regular file.
    ## @returns false otherwise
    return self.fileType == FileType.REGULAR_FILE



proc isDirectory*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry is a directory.
    ## @returns false otherwise
    return self.fileType == FileType.DIRECTORY



proc isSymlink*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry is a symlink.
    ## @returns false otherwise
    return self.fileType == FileType.SYMLINK



proc isDeviceFile*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry is a device-file (either block- or character-device).
    ## @returns false otherwise
    return self.fileType == FileType.CHARACTER_DEVICE  or  self.fileType == FileType.BLOCK_DEVICE



proc isCharacterDeviceFile*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry is a character-device-file.
    ## @returns false otherwise
    return self.fileType == FileType.CHARACTER_DEVICE



proc isBlockDeviceFile*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry is a block-device-file.
    ## @returns false otherwise
    return self.fileType == FileType.BLOCK_DEVICE



proc isSocketFile*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry is a unix socket file.
    ## @returns false otherwise
    return self.fileType == FileType.SOCKET_FILE



proc isPipeFile*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry is a named pipe file.
    ## @returns false otherwise
    return self.fileType == FileType.PIPE_FILE



proc isHidden*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if the File-System-Entry directs to an existing hidden file/directory/etc.
    ## @returns false otherwise.
    ## See also:
    ## * `os.isHidden() proc <#os.isHidden,string>`_
    ## * `isHidden() proc <#isHidden,FileStatus>`_
    ## * `isVisible() proc <#isVisible,FileStatus>`_
    return self.fileType != FileType.NOT_EXISTING  and  self.isHidden



proc isVisible*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if the File-System-Entry directs to an existing visible file/directory/etc (eg. is NOT hidden).
    ## @returns false otherwise.
    ## See also:
    ## * `os.isHidden() proc <#os.isHidden,string>`_
    ## * `isHidden() proc <#isHidden,FileStatus>`_
    ## * `isVisible() proc <#isVisible,FileStatus>`_
    return self.fileType != FileType.NOT_EXISTING  and  not self.isHidden



proc isZeroSizeFile*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry is a regular file and has a file-size of zero.
    ## @returns false otherwise
    if self.fileType != FileType.REGULAR_FILE:
        return false
    when defined(Posix):
        return self.posixFileStat.st_size == 0
    else:
        echo "[WARN] FileStatus.isZeroSizeFile() is not implemented for current Architecture."
        return false



proc hasSetUidBit*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and has the Set-Uid-Bit set.
    ## @returns false otherwise
    return self.fileType != FileType.NOT_EXISTING  and  (self.posixFileStat.st_mode.cint and posix.S_ISUID) != 0



proc hasSetGidBit*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and has the Set-Gid-Bit set.
    ## @returns false otherwise
    return self.fileType != FileType.NOT_EXISTING  and  (self.posixFileStat.st_mode.cint and posix.S_ISGID) != 0



proc hasStickyBit*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and has the Sticky-Bit set.
    ## @returns false otherwise
    return self.fileType != FileType.NOT_EXISTING  and  (self.posixFileStat.st_mode.cint and posix.S_ISVTX) != 0



proc getLastAccessTime*(self: FileStatus): times.Time {.noSideEffect.} =
    ## @returns the Time when the stated Path was last accessed.
    ## @returns 0.Time if the FileStat is in Error-State or the FileType does not support Prefered Block-Size.
    if self.fileType == FileType.NOT_EXISTING:
        return times.initTime(0, 0)
    when defined(Posix):
        return times.initTime(self.posixFileStat.st_atim.tv_sec.int64, self.posixFileStat.st_atim.tv_nsec.int)
    else:
        echo "[WARN] FileStatus.getLastAccessTime() is not implemented for current Architecture."
        return false



proc getLastChangeTime*(self: FileStatus): times.Time {.noSideEffect.} =
    ## @returns the Time when the content of the stated Path was last changed.
    ## @returns 0.Time if the FileStat is in Error-State.
    if self.fileType == FileType.NOT_EXISTING:
        return times.initTime(0, 0)
    when defined(Posix):
        return times.initTime(self.posixFileStat.st_mtim.tv_sec.int64, self.posixFileStat.st_mtim.tv_nsec.int)
    else:
        echo "[WARN] FileStatus.getLastChangeTime() is not implemented for current Architecture."
        return false



proc getLastStatusChangeTime*(self: FileStatus): times.Time {.noSideEffect.} =
    ## @returns the Time when the status of stated Path was last changed.
    ## @returns 0.Time if the FileStat is in Error-State.
    if self.fileType == FileType.NOT_EXISTING:
        return times.initTime(0, 0)
    when defined(Posix):
        return times.initTime(self.posixFileStat.st_ctim.tv_sec.int64, self.posixFileStat.st_ctim.tv_nsec.int)
    else:
        echo "[WARN] FileStatus.getLastStatusChangeTime() is not implemented for current Architecture."
        return false



proc isUserOwned*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true
    ##     if the File-System-Entry exists and the effective userId of the
    ##     current process is the owner of the file.
    ## @returns false otherwise
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        return self.posixFileStat.st_uid == posix.geteuid()
    else:
        echo "[WARN] FileStatus.isUserOwned() is not implemented for current Architecture."
        return false



proc isGroupOwned*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true
    ##     if the File-System-Entry exists and the effective groupId of the
    ##     current process is the owner of the file.
    ## @returns false otherwise
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        return self.posixFileStat.st_gid == posix.getegid()
    else:
        echo "[WARN] FileStatus.isGroupOwned() is not implemented for current Architecture."
        return false



proc isGroupMember*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if the named file exists and the effective user is member to the group of the the file.
    ## @returns false otherwise
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        return posix_group_member(self.posixFileStat.st_gid) != 0
    else:
        echo "[WARN] FileStatus.isGroupMember() is not implemented for current Architecture."
        return false



#TODO: testen
proc isReadable*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and is readable by any means for the current process.
    ## @returns false otherwise
    ## @see https://ruby-doc.org/core-2.5.3/FileTest.html#method-i-readable-3F
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        result = false
        # is readable by other?
        result = result or ((self.posixFileStat.st_mode.cint and posix.S_IROTH) != 0)
        # is readable for current user?
        result = result or ((self.posixFileStat.st_mode.cint and posix.S_IRUSR) != 0 and self.posixFileStat.st_uid == posix.geteuid())
        # is readable for any group?
        result = result or ((self.posixFileStat.st_mode.cint and posix.S_IRGRP) != 0 and posix_group_member(self.posixFileStat.st_gid) != 0)
        return result
    else:
        echo "[WARN] FileStatus.isReadable() is not implemented for current Architecture."
        return false



#TODO: testen
proc isReadableByUser*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and is readable by direct user ownership of the current process.
    ## @returns false otherwise
    ## @see https://ruby-doc.org/core-2.5.3/FileTest.html#method-i-readable-3F
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        return ((self.posixFileStat.st_mode.cint and posix.S_IRUSR) != 0 and self.posixFileStat.st_uid == posix.geteuid())
    else:
        echo "[WARN] FileStatus.isReadableByUser() is not implemented for current Architecture."
        return false



#TODO: testen
proc isReadableByGroup*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and is readable by group ownership of the current process.
    ## @returns false otherwise
    ## @see https://ruby-doc.org/core-2.5.3/FileTest.html#method-i-readable-3F
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        return ((self.posixFileStat.st_mode.cint and posix.S_IRGRP) != 0 and posix_group_member(self.posixFileStat.st_gid) != 0)
    else:
        echo "[WARN] FileStatus.isReadableByGroup() is not implemented for current Architecture."
        return false



#TODO: testen
proc isReadableByOther*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and is readable by any other means of the current process.
    ## @returns false otherwise
    ## @see https://ruby-doc.org/core-2.5.3/FileTest.html#method-i-readable-3F
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        return ((self.posixFileStat.st_mode.cint and posix.S_IROTH) != 0)
    else:
        echo "[WARN] FileStatus.isReadableByOther() is not implemented for current Architecture."
        return false



#TODO: testen
proc isWritable*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and is writable by any means for the current process.
    ## @returns false otherwise
    ## @see https://ruby-doc.org/core-2.5.3/FileTest.html#method-i-writable-3F
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        result = false
        # is writable by other?
        result = result or ((self.posixFileStat.st_mode.cint and posix.S_IWOTH) != 0)
        # is writable for current user?
        result = result or ((self.posixFileStat.st_mode.cint and posix.S_IWUSR) != 0 and self.posixFileStat.st_uid == posix.geteuid())
        # is writable for any group?
        result = result or ((self.posixFileStat.st_mode.cint and posix.S_IWGRP) != 0 and posix_group_member(self.posixFileStat.st_gid) != 0)
        return result
    else:
        echo "[WARN] FileStatus.isWritable() is not implemented for current Architecture."
        return false



#TODO: testen
proc isWritableByUser*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and is writable by direct user ownership of the current process.
    ## @returns false otherwise
    ## @see https://ruby-doc.org/core-2.5.3/FileTest.html#method-i-writable-3F
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        return ((self.posixFileStat.st_mode.cint and posix.S_IWUSR) != 0 and self.posixFileStat.st_uid == posix.geteuid())
    else:
        echo "[WARN] FileStatus.isWritableByUser() is not implemented for current Architecture."
        return false



#TODO: testen
proc isWritableByGroup*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and is writable by group ownership of the current process.
    ## @returns false otherwise
    ## @see https://ruby-doc.org/core-2.5.3/FileTest.html#method-i-writable-3F
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        return ((self.posixFileStat.st_mode.cint and posix.S_IWGRP) != 0 and posix_group_member(self.posixFileStat.st_gid) != 0)
    else:
        echo "[WARN] FileStatus.isWritableByGroup() is not implemented for current Architecture."
        return false



#TODO: testen
proc isWritableByOther*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and is writable by any other means of the current process.
    ## @returns false otherwise
    ## @see https://ruby-doc.org/core-2.5.3/FileTest.html#method-i-writable-3F
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        return ((self.posixFileStat.st_mode.cint and posix.S_IWOTH) != 0)
    else:
        echo "[WARN] FileStatus.isWritableByOther() is not implemented for current Architecture."
        return false



#TODO: testen
proc isExecutable*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and is executable by any means for the current process.
    ## @returns false otherwise
    ## @see https://ruby-doc.org/core-2.5.3/FileTest.html#method-i-executable-3F
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        result = false
        # is executable by other?
        result = result or ((self.posixFileStat.st_mode.cint and posix.S_IXOTH) != 0)
        # is executable for current user?
        result = result or ((self.posixFileStat.st_mode.cint and posix.S_IXUSR) != 0 and self.posixFileStat.st_uid == posix.geteuid())
        # is executable for any group?
        result = result or ((self.posixFileStat.st_mode.cint and posix.S_IXGRP) != 0 and posix_group_member(self.posixFileStat.st_gid) != 0)
        return result
    else:
        echo "[WARN] FileStatus.isExecutable() is not implemented for current Architecture."
        return false



#TODO: testen
proc isExecutableByUser*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and is executable by direct user ownership of the current process.
    ## @returns false otherwise
    ## @see https://ruby-doc.org/core-2.5.3/FileTest.html#method-i-executable-3F
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        return ((self.posixFileStat.st_mode.cint and posix.S_IXUSR) != 0 and self.posixFileStat.st_uid == posix.geteuid())
    else:
        echo "[WARN] FileStatus.isExecutableByUser() is not implemented for current Architecture."
        return false



#TODO: testen
proc isExecutableByGroup*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and is executable by group ownership of the current process.
    ## @returns false otherwise
    ## @see https://ruby-doc.org/core-2.5.3/FileTest.html#method-i-executable-3F
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        return ((self.posixFileStat.st_mode.cint and posix.S_IXGRP) != 0 and posix_group_member(self.posixFileStat.st_gid) != 0)
    else:
        echo "[WARN] FileStatus.isExecutableByGroup() is not implemented for current Architecture."
        return false



#TODO: testen
proc isExecutableByOther*(self: FileStatus): bool {.noSideEffect.} =
    ## @returns true if File-System-Entry exists and is executable by any other means of the current process.
    ## @returns false otherwise
    ## @see https://ruby-doc.org/core-2.5.3/FileTest.html#method-i-executable-3F
    if self.fileType == FileType.NOT_EXISTING:
        return false
    when defined(Posix):
        return ((self.posixFileStat.st_mode.cint and posix.S_IXOTH) != 0)
    else:
        echo "[WARN] FileStatus.isExecutableByOther() is not implemented for current Architecture."
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
