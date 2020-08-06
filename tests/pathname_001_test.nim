###
# Test for Pathname-Module in Nim.
#
# Run Tests:
# ----------
#     $ nim compile --run tests/pathname_001_test
#
# :Author: Raimund Hübel <raimund.huebel@googlemail.com>
###


import pathname
import times

import unittest
import test_helper


suite "Pathname Tests 001":


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - readAll()
#-----------------------------------------------------------------------------------------------------------------------


    test "#readAll() from existing File":
        check "Hello World!\n" == Pathname.new(fixturePath("sample_file_000.txt")).readAll()


    test "#readAll() from non existing file-entry should fail":
        expect(IOError):
            discard Pathname.new(fixturePath("NOT_EXISTING")).readAll()


    test "#readAll() from Directory should fail":
        expect(IOError):
            discard Pathname.new(fixturePath("sample_dir")).readAll()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - read()
#-----------------------------------------------------------------------------------------------------------------------


    test "#read() from existing File":
        check "Hello World!\n" == Pathname.new(fixturePath("sample_file_000.txt")).read()


    test "#read() from non existing File should fail":
        expect(IOError):
            discard Pathname.new(fixturePath("NOT_EXISTING")).read()


    test "#read() from Directory should fail":
        expect(IOError):
            discard Pathname.new(fixturePath("sample_dir")).read()


    test "#read(length) from existing File":
        check "Hello" == Pathname.new(fixturePath("sample_file_000.txt")).read(5)


    test "#read(length) from non existing File should fail":
        expect(IOError):
            discard Pathname.new(fixturePath("NOT_EXISTING")).read(5)


    test "#read(length) from Directory should fail":
        expect(IOError):
            discard Pathname.new(fixturePath("sample_dir")).read(5)


    test "#read(length, offset) from existing File":
        check "World" == Pathname.new(fixturePath("sample_file_000.txt")).read(5, 6)


    test "#read(length, offset) from non existing File should fail":
        expect(IOError):
            discard Pathname.new(fixturePath("NOT_EXISTING")).read(5, 6)


    test "#read(length, offset) from Directory should fail":
        expect(IOError):
            discard Pathname.new(fixturePath("sample_dir")).read(5, 6)


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - open()
#-----------------------------------------------------------------------------------------------------------------------


    test "#open() from existing File":
        var file: File = Pathname.new(fixturePath("sample_dir/a_file")).open()
        file.close


    test "#open() from non existing File":
        expect(IOError):
            discard Pathname.new(fixturePath("NOT_EXISTING")).open()


    test "#open() from Directory should fail":
        expect(IOError):
            discard Pathname.new(fixturePath("sample_dir")).open()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - touch() - with non existing File-System-Entries
#-----------------------------------------------------------------------------------------------------------------------


    test "#touch() should create a regular File, if file-system-entry does not exist":
        let pathname = Pathname.new(fixturePath("sample_dir", "TEST_TOUCH_FILE")).remove()
        check false == pathname.isExisting()
        pathname.touch()
        check true == pathname.isRegularFile()
        pathname.remove()


    test "#touch(simple_file_path) should create a regular File, if file-system-entry does not exist":
        let pathname = Pathname.new(fixturePath())
        check pathname.join("TEST_TOUCH_FILE_00").remove().isNotExisting()
        pathname.touch("TEST_TOUCH_FILE_00")
        check pathname.join("TEST_TOUCH_FILE_00").isExisting()
        pathname.join("TEST_TOUCH_FILE_00").remove()


    test "#touch([deep_file_path,...]) should create a regular File, if file-system-entry does not exist":
        let pathname = Pathname.new(fixturePath())
        check pathname.join("sample_dir","TEST_TOUCH_FILE_01").remove().isNotExisting()
        pathname.touch(["sample_dir", "TEST_TOUCH_FILE_01"])
        check pathname.join("sample_dir","TEST_TOUCH_FILE_01").isExisting()
        pathname.join("sample_dir", "TEST_TOUCH_FILE_01").remove()


    test "#touch() should create a regular File, if file-system-entry does not exist, with correct file-times":
        let pathname = Pathname.new(fixturePath("TEST_TOUCH_FILE")).remove()
        defer:
            pathname.remove()
        # Check file-creation ...
        let time_begin = times.getTime()
        check false == pathname.isExisting()
        pathname.touch()
        check true == pathname.isRegularFile()
        let time_end    = times.getTime()
        # Check File-Times ...
        #debugEcho time_begin.toUnix(), " <= ", pathname.getLastAccessTime().toUnix(), " <= ", time_end.toUnix()
        #debugEcho time_begin.toUnix(), " <= ", pathname.getLastChangeTime.toUnix(), " <= ", time_end.toUnix()
        #debugEcho time_begin.toUnix(), " <= ", pathname.getLastStatusChangeTime.toUnix(), " <= ", time_end.toUnix()
        check time_begin <= time_end
        check pathname.getLastAccessTime()      .toUnix() >= time_begin.toUnix()
        check pathname.getLastAccessTime()      .toUnix() <= time_end.toUnix()
        check pathname.getLastChangeTime()      .toUnix() == pathname.getLastAccessTime().toUnix()
        check pathname.getLastStatusChangeTime().toUnix() == pathname.getLastAccessTime().toUnix()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - touch() - with existing File-System-Entries
#-----------------------------------------------------------------------------------------------------------------------


    test "#touch() should update time of existing regular file":
        let pathname = Pathname.new(fixturePath("touch_file_test.txt"))
        check pathname.isRegularFile()
        # Touch file, with timing ...
        let time_begin = times.getTime()
        pathname.touch()
        let time_end = times.getTime()
        check pathname.isRegularFile()
        # Check file-times ...
        #debugEcho time_begin.toUnix(), " <= ", pathname.getLastAccessTime()    .toUnix(), " <= ", time_end.toUnix()
        #debugEcho time_begin.toUnix(), " <= ", pathname.getLastChangeTime()    .toUnix(), " <= ", time_end.toUnix()
        #debugEcho time_begin.toUnix(), " <= ", pathname.getLastStatusChangeTime.toUnix(), " <= ", time_end.toUnix()
        check time_begin <= time_end
        check pathname.getLastAccessTime().toUnix() >= time_begin.toUnix()
        check pathname.getLastAccessTime().toUnix() <= time_end.toUnix()
        check pathname.getLastChangeTime().toUnix()     == pathname.getLastAccessTime().toUnix()
        check pathname.getLastStatusChangeTime.toUnix() == pathname.getLastAccessTime().toUnix()


    when defined(Posix):
        test "#touch() should update time of existing directory in posix":
            let pathname = Pathname.new(fixturePath("touch_directory_test.d"))
            check pathname.isDirectory()
            # Touch file, with timing ...
            let time_begin = times.getTime()
            pathname.touch()
            let time_end = times.getTime()
            check pathname.isDirectory()
            # Check file-times ...
            #debugEcho time_begin.toUnix(), " <= ", pathname.getLastAccessTime()    .toUnix(), " <= ", time_end.toUnix()
            #debugEcho time_begin.toUnix(), " <= ", pathname.getLastChangeTime()    .toUnix(), " <= ", time_end.toUnix()
            #debugEcho time_begin.toUnix(), " <= ", pathname.getLastStatusChangeTime.toUnix(), " <= ", time_end.toUnix()
            check time_begin <= time_end
            check pathname.getLastAccessTime().toUnix() >= time_begin.toUnix()
            check pathname.getLastAccessTime().toUnix() <= time_end.toUnix()
            check pathname.getLastChangeTime().toUnix()     == pathname.getLastAccessTime().toUnix()
            check pathname.getLastStatusChangeTime.toUnix() == pathname.getLastAccessTime().toUnix()


    when defined(Windows):
        test "#touch() can NOT update time of existing directory because it is NOT supported in Windows":
            let pathname = Pathname.new(fixturePath("touch_directory_test.d"))
            check pathname.isDirectory()
            # Touch file, with timing ...
            let access_time_before = pathname.getLastAccessTime()
            let change_time_before = pathname.getLastChangeTime()
            let status_time_before = pathname.getLastStatusChangeTime()
            pathname.touch()
            # Check file-times ...
            check access_time_before.toUnix() == pathname.getLastAccessTime().toUnix()
            check change_time_before.toUnix() == pathname.getLastChangeTime().toUnix()
            check status_time_before.toUnix() == pathname.getLastStatusChangeTime.toUnix()


    when not pathname.AreSymlinksSupported:
        test "#touch() symlinks are NOT supported for this Architecture":
            skip


    when pathname.AreSymlinksSupported:
        test "#touch() should update time of existing and valid symlink in posix":
            let pathname = Pathname.new(fixturePath("TEST_TOUCH_SYMLINK")).remove().createSymlinkTo("touch_file_test.txt")
            defer:
                pathname.remove()
            check pathname.isSymlink()
            # Touch file, with timing ...
            let time_begin = times.getTime()
            pathname.touch()
            let time_end = times.getTime()
            check pathname.isSymlink()
            # Check file-times ...
            #debugEcho time_begin.toUnix(), " <= ", pathname.getLastAccessTime()    .toUnix(), " <= ", time_end.toUnix()
            #debugEcho time_begin.toUnix(), " <= ", pathname.getLastChangeTime()    .toUnix(), " <= ", time_end.toUnix()
            #debugEcho time_begin.toUnix(), " <= ", pathname.getLastStatusChangeTime.toUnix(), " <= ", time_end.toUnix()
            check time_begin <= time_end
            check pathname.getLastAccessTime().toUnix() >= time_begin.toUnix()
            check pathname.getLastAccessTime().toUnix() <= time_end.toUnix()
            check pathname.getLastChangeTime().toUnix()     == pathname.getLastAccessTime().toUnix()
            check pathname.getLastStatusChangeTime.toUnix() == pathname.getLastAccessTime().toUnix()


    when not pathname.ArePipesSupported:
        test "#touch() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.ArePipesSupported:
        test "#touch() pipes/fifos - TODO: IMPLEMENT TEST":
            fail


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createFile()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createFile() should create a regular File":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_FILE")).remove()
        check false == pathname.isExisting()
        pathname.createFile()
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#createFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_FILE")).remove()
        let pathname2: Pathname = pathname.createFile()
        #echo "'", pathname, "'"
        #echo "'", pathname2, "'"
        check pathname2 == pathname
        pathname.removeRegularFile()


    test "#createFile() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_FILE")).remove()
        check false == pathname.isExisting()
        pathname.createFile()
        check true == pathname.isRegularFile()
        pathname.createFile()
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeFile()
#-----------------------------------------------------------------------------------------------------------------------


    test "#removeFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE"))
        let pathname2: Pathname = pathname.removeFile()
        check pathname2 == pathname


    test "#removeFile() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE")).remove().createRegularFile()
        check true == pathname.isRegularFile()
        pathname.removeFile()
        check false == pathname.isExisting()
        pathname.removeFile()
        check false == pathname.isExisting()


    test "#removeFile() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        check false == pathname.isExisting()
        pathname.removeFile()
        pathname.removeFile()
        check false == pathname.isExisting()


    test "#removeFile() should delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE")).remove().createRegularFile()
        check true == pathname.isRegularFile()
        pathname.removeFile()
        check false == pathname.isExisting()


    test "#removeFile() should NOT delete a directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE_WITH_DIRECTORY")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        try:
            pathname.removeFile()
            fail()
        except IOError:
            check true
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


    when not pathname.AreSymlinksSupported:
        test "#removeFile() symlinks are NOT supported for this Architecture":
            skip


    when pathname.AreSymlinksSupported:
        test "#removeFile() should delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            check true == pathname.isSymlink()
            pathname.removeFile()
            check false == pathname.isExisting()


    when not pathname.ArePipesSupported:
        test "#removeFile() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.ArePipesSupported:
        test "#removeFile() should delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE_WITH_FIFO")).remove().createPipeFile()
            check true == pathname.isPipeFile()
            pathname.removeFile()
            check false == pathname.isExisting()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createRegularFile()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createRegularFile() should create a regular File":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_REGULAR_FILE")).remove().removeRegularFile()
        check false == pathname.isExisting()
        pathname.createRegularFile()
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#createRegularFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_REGULAR_FILE")).remove().removeRegularFile()
        let pathname2: Pathname = pathname.createRegularFile()
        check pathname2 == pathname
        pathname.removeRegularFile()


    test "#createRegularFile() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_REGULAR_FILE")).remove().removeRegularFile()
        check false == pathname.isExisting()
        pathname.createRegularFile()
        check true == pathname.isRegularFile()
        pathname.createRegularFile()
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeRegularFile()
#-----------------------------------------------------------------------------------------------------------------------


    test "#removeRegularFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE"))
        let pathname2: Pathname = pathname.removeRegularFile()
        check pathname2 == pathname


    test "#removeRegularFile() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE")).remove().createRegularFile()
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()
        check false == pathname.isExisting()
        pathname.removeRegularFile()
        check false == pathname.isExisting()


    test "#removeRegularFile() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        check false == pathname.isExisting()
        pathname.removeRegularFile()
        pathname.removeRegularFile()
        check false == pathname.isExisting()


    test "#removeRegularFile() should delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE")).remove().createRegularFile()
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()
        check false == pathname.isExisting()


    test "#removeRegularFile() should NOT delete a directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE_WITH_DIRECTORY")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        try:
            pathname.removeRegularFile()
            fail()
        except IOError:
            check true
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


    when not pathname.AreSymlinksSupported:
        test "#removeRegularFile() symlinks are NOT supported for this Architecture":
            skip


    when pathname.AreSymlinksSupported:
        test "#removeRegularFile() should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            check true == pathname.isSymlink()
            try:
                pathname.removeRegularFile()
                fail()
            except IOError:
                check true
            check true == pathname.isSymlink()
            pathname.removeSymlink()


    when not pathname.ArePipesSupported:
        test "#removeRegularFile() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.ArePipesSupported:
        test "#removeRegularFile() should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE_WITH_PIPE")).remove().createPipeFile()
            check true == pathname.isPipeFile()
            try:
                pathname.removeRegularFile()
                fail()
            except IOError:
                check true
            check true == pathname.isPipeFile()
            pathname.removePipeFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createDirectory()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createDirectory() should create an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_DIRECTORY")).remove()
        check false == pathname.isExisting()
        pathname.createDirectory()
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


    test "#createDirectory() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_DIRECTORY")).remove()
        let pathname2: Pathname = pathname.createDirectory()
        check pathname2 == pathname
        pathname.removeEmptyDirectory()


    test "#createDirectory() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_DIRECTORY")).remove()
        check false == pathname.isExisting()
        pathname.createDirectory()
        check true == pathname.isDirectory()
        pathname.createDirectory()
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeDirectory()
#-----------------------------------------------------------------------------------------------------------------------


    test "#removeDirectory() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_EMPTY_DIR"))
        block:
            let pathname2: Pathname = pathname.removeDirectory()
            check pathname2 == pathname
        block:
            let pathname2: Pathname = pathname.removeDirectory(isRecursive=false)
            check pathname2 == pathname
        block:
            let pathname2: Pathname = pathname.removeDirectory(isRecursive=true)
            check pathname2 == pathname


    test "#removeDirectory() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeDirectory()
        check false == pathname.isExisting()
        pathname.removeDirectory()
        check false == pathname.isExisting()


    test "#removeDirectory() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        check false == pathname.isExisting()
        pathname.removeDirectory()
        pathname.removeDirectory(isRecursive=true)
        pathname.removeDirectory(isRecursive=false)
        check false == pathname.isExisting()


    test "#removeDirectory() should delete an empty directory by default":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_EMPTY_DIR")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeDirectory()
        check false == pathname.isExisting()


    test "#removeDirectory(isRecursive=false) should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_EMPTY_DIR")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeDirectory(isRecursive=false)
        check false == pathname.isExisting()


    test "#removeDirectory(isRecursive=true) should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_EMPTY_DIR")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeDirectory(isRecursive=true)
        check false == pathname.isExisting()


    test "#removeDirectory() should NOT delete a full directory by default":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FULL_DIR")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        let pathname2 = pathname.join("A_FILE").createRegularFile()
        check true == pathname2.isRegularFile()
        try:
            pathname.removeDirectory()
            fail()
        except IOError:
            check true
        check true == pathname.isDirectory()
        pathname.removeDirectoryTree()


    test "#removeDirectory(isRecursive=false) should NOT delete a full directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FULL_DIR")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        let pathname2 = pathname.join("A_FILE").createRegularFile()
        check true == pathname2.isRegularFile()
        try:
            pathname.removeDirectory(isRecursive=false)
            fail()
        except IOError:
            check true
        check true == pathname.isDirectory()
        pathname.removeDirectoryTree()


    test "#removeDirectory(isRecursive=true) should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FULL_DIR")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        let pathname2 = pathname.join("A_FILE").createRegularFile()
        check true == pathname2.isRegularFile()
        pathname.removeDirectory(isRecursive=true)
        check false == pathname.isExisting()


    test "#removeDirectory() should NOT delete a regular file by default":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FILE")).remove().createRegularFile()
        check true == pathname.isRegularFile()
        try:
            pathname.removeDirectory()
            fail()
        except IOError:
            check true
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#removeDirectory(isRecursive=false) should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FILE")).remove().createRegularFile()
        check true == pathname.isRegularFile()
        try:
            pathname.removeDirectory(isRecursive=false)
            fail()
        except IOError:
            check true
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#removeDirectory(isRecursive=true) should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FILE")).remove().createRegularFile()
        check true == pathname.isRegularFile()
        try:
            pathname.removeDirectory(isRecursive=true)
            fail()
        except IOError:
            check true
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()



    when not pathname.AreSymlinksSupported:
        test "#removeDirectory() symlinks are NOT supported for this Architecture":
            skip


    when pathname.AreSymlinksSupported:
        test "#removeDirectory() should NOT delete a symlink by default":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            check true == pathname.isSymlink()
            try:
                pathname.removeDirectory()
                fail()
            except IOError:
                check true
            check true == pathname.isSymlink()
            pathname.removeSymlink()


    when pathname.AreSymlinksSupported:
        test "#removeDirectory(isRecursive=false) should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            check true == pathname.isSymlink()
            try:
                pathname.removeDirectory(isRecursive=false)
                fail()
            except IOError:
                check true
            check true == pathname.isSymlink()
            pathname.removeSymlink()


    when pathname.AreSymlinksSupported:
        test "#removeDirectory(isRecursive=true) should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            check true == pathname.isSymlink()
            try:
                pathname.removeDirectory(isRecursive=true)
                fail()
            except IOError:
                check true
            check true == pathname.isSymlink()
            pathname.removeSymlink()


    when not pathname.ArePipesSupported:
        test "#removeDirectory() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.ArePipesSupported:
        test "#removeDirectory() should NOT delete a pipe/fifo by default":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FIFO")).remove().createPipeFile()
            check true == pathname.isPipeFile()
            try:
                pathname.removeDirectory()
                fail()
            except IOError:
                check true
            check true == pathname.isPipeFile()
            pathname.removePipeFile()


    when pathname.ArePipesSupported:
        test "#removeDirectory(isRecursive=false) should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FIFO")).remove().createPipeFile()
            check true == pathname.isPipeFile()
            try:
                pathname.removeDirectory(isRecursive=false)
                fail()
            except IOError:
                check true
            check true == pathname.isPipeFile()
            pathname.removePipeFile()


    when pathname.ArePipesSupported:
        test "#removeDirectory(isRecursive=true) should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FIFO")).remove().createPipeFile()
            check true == pathname.isPipeFile()
            try:
                pathname.removeDirectory(isRecursive=true)
                fail()
            except IOError:
                check true
            check true == pathname.isPipeFile()
            pathname.removePipeFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createEmptyDirectory()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createEmptyDirectory() should create an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_EMPTY_DIRECTORY")).remove()
        check false == pathname.isExisting()
        pathname.createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


    test "#createEmptyDirectory() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_EMPTY_DIRECTORY")).remove()
        let pathname2: Pathname = pathname.createEmptyDirectory()
        check pathname2 == pathname
        pathname.removeEmptyDirectory()


    test "#createEmptyDirectory() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_EMPTY_DIRECTORY")).remove()
        check false == pathname.isExisting()
        pathname.createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeEmptyDirectory()
#-----------------------------------------------------------------------------------------------------------------------


    test "#removeEmptyDirectory() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_EMPTY"))
        let pathname2: Pathname = pathname.removeEmptyDirectory()
        check pathname2 == pathname


    test "#removeEmptyDirectory() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_EMPTY")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()
        check false == pathname.isExisting()
        pathname.removeEmptyDirectory()
        check false == pathname.isExisting()


    test "#removeEmptyDirectory() should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_EMPTY")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()
        check false == pathname.isExisting()


    test "#removeEmptyDirectory() should NOT delete a full directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_FULL")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        let pathnameContent = pathname.join("A_FILE").createRegularFile()
        check true == pathnameContent.isRegularFile()
        try:
            pathname.removeEmptyDirectory()
            fail()
        except IOError:
            check true
        check true == pathname.isDirectory()
        pathname.removeDirectoryTree()


    test "#removeEmptyDirectory() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        check false == pathname.isExisting()
        pathname.removeEmptyDirectory()
        pathname.removeEmptyDirectory()
        check false == pathname.isExisting()


    test "#removeEmptyDirectory() should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_WITH_SYMLINK")).remove().createRegularFile()
        check true == pathname.isRegularFile()
        try:
            pathname.removeEmptyDirectory()
            fail()
        except IOError:
            check true
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    when not pathname.AreSymlinksSupported:
        test "#removeEmptyDirectory() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.AreSymlinksSupported:
        test "#removeEmptyDirectory() should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            check true == pathname.isSymlink()
            try:
                pathname.removeEmptyDirectory()
                fail()
            except IOError:
                check true
            check true == pathname.isSymlink()
            pathname.removeSymlink()


    when not pathname.ArePipesSupported:
        test "#removeEmptyDirectory() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.ArePipesSupported:
        test "#removeEmptyDirectory() should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_WITH_FIFO")).remove().createPipeFile()
            check true == pathname.isPipeFile()
            try:
                pathname.removeEmptyDirectory()
                fail()
            except IOError:
                check true
            check true == pathname.isPipeFile()
            pathname.removePipeFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeDirectoryTree()
#-----------------------------------------------------------------------------------------------------------------------


    test "#removeDirectoryTree() should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE_EMPTY")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeDirectoryTree()
        check false == pathname.isExisting()


    test "#removeDirectoryTree() should delete a full directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE_FULL")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        let pathnameContent = pathname.join("A_FILE").createRegularFile()
        check true == pathnameContent.isRegularFile()
        pathname.removeDirectoryTree()
        check false == pathname.isExisting()


    test "#removeDirectoryTree() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE"))
        let pathname2: Pathname = pathname.removeDirectoryTree()
        check pathname2 == pathname


    test "#removeDirectoryTree() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        check false == pathname.isExisting()
        pathname.removeDirectoryTree()
        pathname.removeDirectoryTree()
        check false == pathname.isExisting()


    test "#removeDirectoryTree() should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE")).remove().createRegularFile()
        check true == pathname.isRegularFile()
        try:
            pathname.removeDirectoryTree()
            fail()
        except IOError:
            check true
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    when not pathname.AreSymlinksSupported:
        test "#removeDirectoryTree() symlinks are NOT supported for this Architecture":
            skip


    when pathname.AreSymlinksSupported:
        test "#removeDirectoryTree() should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            check true == pathname.isSymlink()
            try:
                pathname.removeDirectoryTree()
                fail()
            except IOError:
                check true
            check true == pathname.isSymlink()
            pathname.removeSymlink()


    when not pathname.ArePipesSupported:
        test "#removeDirectoryTree() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.ArePipesSupported:
        test "#removeDirectoryTree() should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE_FIFO")).remove().createPipeFile()
            check true == pathname.isPipeFile()
            try:
                pathname.removeDirectoryTree()
                fail()
            except IOError:
                check true
            check true == pathname.isPipeFile()
            pathname.removePipeFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createSymlinkTo()
#-----------------------------------------------------------------------------------------------------------------------


    when not pathname.AreSymlinksSupported:
        test "#createSymlinkTo() symlinks are NOT supported for this Architecture":
            skip


    when not pathname.AreSymlinksSupported:
        test "#createSymlinkTo() should raise NotSupported-Error for this Architecture":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_TO")).remove()
            try:
                pathname.createSymlinkTo("NOT_EXISTING")
                fail
            except NotSupportedError:
                check true
            except Exception:
                fail


    when pathname.AreSymlinksSupported:
        test "#createSymlinkTo() should create a symlink":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_TO")).remove()
            check false == pathname.isExisting()
            pathname.createSymlinkTo("NOT_EXISTING")
            check true == pathname.isSymlink()
            pathname.removeSymlink()


    when pathname.AreSymlinksSupported:
        test "#createSymlinkTo() should return self for Method-Chaining":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_TO")).remove()
            let pathname2: Pathname = pathname.createSymlinkTo("NOT_EXISTING")
            check pathname2 == pathname
            pathname.removeSymlink()


    when pathname.AreSymlinksSupported:
        test "#createSymlinkTo() should NOT allow multiple calls":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_TO")).remove()
            check false == pathname.isExisting()
            pathname.createSymlinkTo("NOT_EXISTING")
            check true == pathname.isSymlink()
            try:
                pathname.createSymlinkTo("NOT_EXISTING")
                fail()
            except IOError:
                check true
            pathname.removeSymlink()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createSymlinkFrom()
#-----------------------------------------------------------------------------------------------------------------------


    when not pathname.AreSymlinksSupported:
        test "#createSymlinkFrom() symlinks are NOT supported for this Architecture":
            skip


    when not pathname.AreSymlinksSupported:
        test "#createSymlinkFrom() should raise NotSupported-Error for this Architecture":
            let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
            try:
                pathname.createSymlinkFrom("TEST_CREATE_SYMLINK_FROM")
                fail
            except NotSupportedError:
                check true
            except Exception:
                fail


    when pathname.AreSymlinksSupported:
        test "#createSymlinkFrom() should create a symlink":
            let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
            let pathnameSymlink = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_FROM")).remove()
            check false == pathnameSymlink.isExisting()
            pathname.createSymlinkFrom(fixturePath("TEST_CREATE_SYMLINK_FROM"))
            check true == pathnameSymlink.isSymlink()
            pathnameSymlink.removeSymlink()


    when pathname.AreSymlinksSupported:
        test "#createSymlinkFrom() should return self for Method-Chaining":
            let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
            let pathname2: Pathname = pathname.createSymlinkFrom(fixturePath("TEST_CREATE_SYMLINK_FROM"))
            check pathname2 == pathname
            Pathname.new(fixturePath("TEST_CREATE_SYMLINK_FROM")).removeSymlink()


    when pathname.AreSymlinksSupported:
        test "#createSymlinkFrom() should NOT allow multiple calls":
            let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
            let pathnameSymlink = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_FROM")).remove()
            check false == pathnameSymlink.isExisting()
            pathname.createSymlinkFrom(fixturePath("TEST_CREATE_SYMLINK_FROM"))
            check true == pathnameSymlink.isSymlink()
            try:
                pathname.createSymlinkFrom(fixturePath("TEST_CREATE_SYMLINK_FROM"))
                fail()
            except IOError:
                check true
            pathnameSymlink.removeSymlink()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeSymlink()
#-----------------------------------------------------------------------------------------------------------------------


    when not pathname.AreSymlinksSupported:
        test "#removeSymlink() symlinks are NOT supported for this Architecture":
            skip


    when not pathname.AreSymlinksSupported:
        test "#removeSymlink() should raise NotSupported-Error for this Architecture":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK")).remove()
            try:
                pathname.removeSymlink()
                fail
            except NotSupportedError:
                check true
            except Exception:
                fail


    when pathname.AreSymlinksSupported:
        test "#removeSymlink() should return self for Method-Chaining":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            let pathname2: Pathname = pathname.removeSymlink()
            check pathname2 == pathname


    when pathname.AreSymlinksSupported:
        test "#removeSymlink() should allow multiple calls":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            check true == pathname.isSymlink()
            pathname.removeSymlink()
            check false == pathname.isExisting()
            pathname.removeSymlink()
            check false == pathname.isExisting()


    when pathname.AreSymlinksSupported:
        test "#removeSymlink() should delete a pipe file":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK_WITH_PIPE")).remove().createSymlinkTo("NOT_EXISTING")
            check true == pathname.isSymlink()
            pathname.removeSymlink()
            check false == pathname.isExisting()


    when pathname.AreSymlinksSupported:
        test "#removeSymlink() should handle deletion of non existing file-entry":
            let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
            check false == pathname.isExisting()
            pathname.removeSymlink()
            pathname.removeSymlink()
            check false == pathname.isExisting()


    when pathname.AreSymlinksSupported:
        test "#removeSymlink() should NOT delete a regular file":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK_WITH_REGULAR_FILE")).remove().createRegularFile()
            check true == pathname.isRegularFile()
            try:
                pathname.removeSymlink()
                fail()
            except IOError:
                check true
            check true == pathname.isRegularFile()
            pathname.removeRegularFile()


    when pathname.AreSymlinksSupported:
        test "#removeSymlink() should NOT delete a directory":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK_WITH_DIRECTORY")).remove().createEmptyDirectory()
            check true == pathname.isDirectory()
            try:
                pathname.removeSymlink()
                fail()
            except IOError:
                check true
            check true == pathname.isDirectory()
            pathname.removeEmptyDirectory()


    when pathname.AreSymlinksSupported:
        test "#removeSymlink() should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK_WITH_FIFO")).remove().createPipeFile()
            check true == pathname.isPipeFile()
            try:
                pathname.removeSymlink()
                fail()
            except IOError:
                check true
            check true == pathname.isPipeFile()
            pathname.removePipeFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createPipeFile()
#-----------------------------------------------------------------------------------------------------------------------


    when not pathname.ArePipesSupported:
        test "#createPipeFile() pipes/fifos are NOT supported for this Architecture":
            skip


    when not pathname.ArePipesSupported:
        test "#createPipeFile() should raise NotSupported-Error for this Architecture":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_PIPE_FILE")).remove()
            try:
                pathname.createPipeFile()
                fail
            except NotSupportedError:
                check true
            except Exception:
                fail


    when pathname.ArePipesSupported:
        test "#createPipeFile() should create a named pipe":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_PIPE_FILE")).remove()
            check false == pathname.isExisting()
            pathname.createPipeFile()
            check true == pathname.isPipeFile()
            pathname.removePipeFile()


    when pathname.ArePipesSupported:
        test "#createPipeFile() should allow multiple calls":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_PIPE_FILE")).remove()
            check false == pathname.isExisting()
            pathname.createPipeFile()
            check true == pathname.isPipeFile()
            pathname.createPipeFile()
            check true == pathname.isPipeFile()
            pathname.removePipeFile()


    when pathname.ArePipesSupported:
        test "#createPipeFile() should return self for Method-Chaining":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_PIPE_FILE")).remove()
            let pathname2: Pathname = pathname.createPipeFile()
            check pathname2 == pathname
            pathname.removePipeFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removePipeFile()
#-----------------------------------------------------------------------------------------------------------------------


    when not pathname.ArePipesSupported:
        test "#removePipeFile() pipes/fifos are NOT supported for this Architecture":
            skip


    when not pathname.ArePipesSupported:
        test "#removePipeFile() should raise NotSupported-Error for this Architecture":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE")).remove()
            try:
                pathname.removePipeFile()
                fail
            except NotSupportedError:
                check true
            except Exception:
                fail


    when pathname.ArePipesSupported:
        test "#removePipeFile() should return self for Method-Chaining":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE"))
            let pathname2: Pathname = pathname.removePipeFile()
            check pathname2 == pathname


    when pathname.ArePipesSupported:
        test "#removePipeFile() should allow multiple calls":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE")).remove().createPipeFile()
            check true == pathname.isPipeFile()
            pathname.removePipeFile()
            check false == pathname.isExisting()
            pathname.removePipeFile()
            check false == pathname.isExisting()


    when pathname.ArePipesSupported:
        test "#removePipeFile() should delete a pipe file":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE")).remove().createPipeFile()
            check true == pathname.isPipeFile()
            pathname.removePipeFile()
            check false == pathname.isExisting()


    when pathname.ArePipesSupported:
        test "#removePipeFile() should handle deletion of non existing file-entry":
            let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
            check false == pathname.isExisting()
            pathname.removePipeFile()
            pathname.removePipeFile()
            check false == pathname.isExisting()


    when pathname.ArePipesSupported:
        test "#removePipeFile() should NOT delete a regular file":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_REGULAR")).remove().createRegularFile()
            check true == pathname.isRegularFile()
            try:
                pathname.removePipeFile()
                fail()
            except IOError:
                check true
            check true == pathname.isRegularFile()
            pathname.removeRegularFile()


    when pathname.ArePipesSupported:
        test "#removePipeFile() should NOT delete a directory":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_DIRECTORY")).remove().createEmptyDirectory()
            check true == pathname.isDirectory()
            try:
                pathname.removePipeFile()
                fail()
            except IOError:
                check true
            check true == pathname.isDirectory()
            pathname.removeEmptyDirectory()


    when pathname.ArePipesSupported:
        test "#removePipeFile() should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            check true == pathname.isSymlink()
            try:
                pathname.removePipeFile()
                fail()
            except IOError:
                check true
            check true == pathname.isSymlink()
            pathname.removeSymlink()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - remove()
#-----------------------------------------------------------------------------------------------------------------------


    test "#remove() should return self for Method-Chaining and be multiple callable":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        let pathname2 = pathname.remove()
        let pathname3 = pathname.remove().remove().remove()
        check pathname == pathname2
        check pathname == pathname3


    test "#remove() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        check false == pathname.isExisting()
        pathname.remove()
        check false == pathname.isExisting()


    test "#remove() should delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_REGULAR_FILE")).remove().createRegularFile()
        check true == pathname.isRegularFile()
        pathname.remove()
        check false == pathname.isExisting()


    test "#remove() should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_EMPTY_DIRECTORY")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.remove()
        check false == pathname.isExisting()


    test "#remove() should delete a full directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_FULL_DIRECTORY")).remove().createEmptyDirectory()
        check true == pathname.isDirectory()
        let pathname2 = pathname.join("A_FILE").createRegularFile()
        check true == pathname2.isRegularFile()
        pathname.remove()
        check false == pathname.isExisting()


    when not pathname.AreSymlinksSupported:
        test "#remove() symlinks are NOT supported for this Architecture":
            skip


    when pathname.AreSymlinksSupported:
        test "#remove() should delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            check true == pathname.isSymlink()
            pathname.remove()
            check false == pathname.isExisting()


    when not pathname.AreSymlinksSupported:
        test "#remove() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.ArePipesSupported:
        test "#remove() should delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_PIPE")).remove().createPipeFile()
            check true == pathname.isPipeFile()
            pathname.remove()
            check false == pathname.isExisting()
