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
        check pathname.isNotExisting()
        pathname.touch()
        check pathname.isRegularFile()
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
            check pathname.removeRegularFile().isNotExisting()
        # Check file-creation ...
        let time_begin = times.getTime()
        check pathname.isNotExisting()
        pathname.touch()
        check pathname.isRegularFile()
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
        test "#touch() should update time of existing and valid symlink-target in posix":
            let pathname = Pathname.new(fixturePath("TEST_TOUCH_SYMLINK")).remove().createSymlinkTo("touch_file_test.txt")
            defer:
                check pathname.removeSymlink().isNotExisting()
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
        test "#touch() should update time of existing pipes/fifos":
            let pathname = Pathname.new(fixturePath("TEST_TOUCH_PIPE")).createPipeFile()
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname.isPipeFile()
            # Touch file, with timing ...
            let time_begin = times.getTime()
            pathname.touch()
            let time_end = times.getTime()
            check pathname.isPipeFile()
            # Check file-times ...
            #debugEcho time_begin.toUnix(), " <= ", pathname.getLastAccessTime()    .toUnix(), " <= ", time_end.toUnix()
            #debugEcho time_begin.toUnix(), " <= ", pathname.getLastChangeTime()    .toUnix(), " <= ", time_end.toUnix()
            #debugEcho time_begin.toUnix(), " <= ", pathname.getLastStatusChangeTime.toUnix(), " <= ", time_end.toUnix()
            check time_begin <= time_end
            check pathname.getLastAccessTime().toUnix() >= time_begin.toUnix()
            check pathname.getLastAccessTime().toUnix() <= time_end.toUnix()
            check pathname.getLastChangeTime().toUnix()     == pathname.getLastAccessTime().toUnix()
            check pathname.getLastStatusChangeTime.toUnix() == pathname.getLastAccessTime().toUnix()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createFile()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createFile() should create a regular File":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_FILE")).remove()
        defer:
            check pathname.removeRegularFile().isNotExisting()
        check pathname.isNotExisting()
        pathname.createFile()
        check pathname.isRegularFile()


    test "#createFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_FILE")).remove()
        let pathname2: Pathname = pathname.createFile()
        defer:
            check pathname.removeRegularFile().isNotExisting()
        #echo "'", pathname, "'"
        #echo "'", pathname2, "'"
        check pathname2 == pathname


    test "#createFile() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_FILE")).remove()
        defer:
            check pathname.removeRegularFile().isNotExisting()
        check pathname.isNotExisting()
        pathname.createFile()
        check pathname.isRegularFile()
        pathname.createFile()
        check pathname.isRegularFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeFile()
#-----------------------------------------------------------------------------------------------------------------------


    test "#removeFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE"))
        let pathname2: Pathname = pathname.removeFile()
        check pathname2 == pathname


    test "#removeFile() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE")).remove().createRegularFile()
        check pathname.isRegularFile()
        pathname.removeFile()
        check pathname.isNotExisting()
        pathname.removeFile()
        check pathname.isNotExisting()


    test "#removeFile() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
        check pathname.isNotExisting()
        pathname.removeFile()
        pathname.removeFile()
        check pathname.isNotExisting()


    test "#removeFile() should delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE")).remove().createRegularFile()
        check pathname.isRegularFile()
        pathname.removeFile()
        check pathname.isNotExisting()


    test "#removeFile() should NOT delete a directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE_WITH_DIRECTORY")).remove().createEmptyDirectory()
        defer:
            check pathname.removeEmptyDirectory().isNotExisting()
        check pathname.isDirectory()
        try:
            pathname.removeFile()
            fail()
        except IOError:
            check true
        check pathname.isDirectory()


    when not pathname.AreSymlinksSupported:
        test "#removeFile() symlinks are NOT supported for this Architecture":
            skip


    when pathname.AreSymlinksSupported:
        test "#removeFile() should delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            check pathname.isSymlink()
            pathname.removeFile()
            check pathname.isNotExisting()


    when not pathname.ArePipesSupported:
        test "#removeFile() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.ArePipesSupported:
        test "#removeFile() should delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE_WITH_FIFO")).remove().createPipeFile()
            check pathname.isPipeFile()
            pathname.removeFile()
            check pathname.isNotExisting()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createRegularFile()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createRegularFile() should create a regular File":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_REGULAR_FILE")).remove().removeRegularFile()
        defer:
            check pathname.removeRegularFile().isNotExisting()
        check pathname.isNotExisting()
        pathname.createRegularFile()
        check pathname.isRegularFile()


    test "#createRegularFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_REGULAR_FILE")).remove().removeRegularFile()
        let pathname2: Pathname = pathname.createRegularFile()
        defer:
            check pathname.removeRegularFile().isNotExisting()
        check pathname2 == pathname


    test "#createRegularFile() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_REGULAR_FILE")).remove().removeRegularFile()
        defer:
            check pathname.removeRegularFile().isNotExisting()
        check pathname.isNotExisting()
        pathname.createRegularFile()
        check pathname.isRegularFile()
        pathname.createRegularFile()
        check pathname.isRegularFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeRegularFile()
#-----------------------------------------------------------------------------------------------------------------------


    test "#removeRegularFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE"))
        let pathname2: Pathname = pathname.removeRegularFile()
        check pathname2 == pathname


    test "#removeRegularFile() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE")).remove().createRegularFile()
        check pathname.isRegularFile()
        pathname.removeRegularFile()
        check pathname.isNotExisting()
        pathname.removeRegularFile()
        check pathname.isNotExisting()


    test "#removeRegularFile() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
        check pathname.isNotExisting()
        pathname.removeRegularFile()
        pathname.removeRegularFile()
        check pathname.isNotExisting()


    test "#removeRegularFile() should delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE")).remove().createRegularFile()
        check pathname.isRegularFile()
        pathname.removeRegularFile()
        check pathname.isNotExisting()


    test "#removeRegularFile() should NOT delete a directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE_WITH_DIRECTORY")).remove().createEmptyDirectory()
        defer:
            check pathname.removeEmptyDirectory().isNotExisting()
        check pathname.isDirectory()
        try:
            pathname.removeRegularFile()
            fail()
        except IOError:
            check true
        check pathname.isDirectory()


    when not pathname.AreSymlinksSupported:
        test "#removeRegularFile() symlinks are NOT supported for this Architecture":
            skip


    when pathname.AreSymlinksSupported:
        test "#removeRegularFile() should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            defer:
                check pathname.removeSymlink().isNotExisting()
            check pathname.isSymlink()
            try:
                pathname.removeRegularFile()
                fail()
            except IOError:
                check true
            check pathname.isSymlink()


    when not pathname.ArePipesSupported:
        test "#removeRegularFile() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.ArePipesSupported:
        test "#removeRegularFile() should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE_WITH_PIPE")).remove().createPipeFile()
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname.isPipeFile()
            try:
                pathname.removeRegularFile()
                fail()
            except IOError:
                check true
            check pathname.isPipeFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createDirectory()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createDirectory() should create an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_DIRECTORY")).remove()
        defer:
            check pathname.removeEmptyDirectory().isNotExisting()
        check pathname.isNotExisting()
        pathname.createDirectory()
        check pathname.isDirectory()


    test "#createDirectory() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_DIRECTORY")).remove()
        let pathname2: Pathname = pathname.createDirectory()
        defer:
            check pathname.removeEmptyDirectory().isNotExisting()
        check pathname2 == pathname


    test "#createDirectory() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_DIRECTORY")).remove()
        defer:
            check pathname.removeEmptyDirectory().isNotExisting()
        check pathname.isNotExisting()
        pathname.createDirectory()
        check pathname.isDirectory()
        pathname.createDirectory()
        check pathname.isDirectory()


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
        check pathname.isDirectory()
        pathname.removeDirectory()
        check pathname.isNotExisting()
        pathname.removeDirectory()
        check pathname.isNotExisting()


    test "#removeDirectory() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
        check pathname.isNotExisting()
        pathname.removeDirectory()
        pathname.removeDirectory(isRecursive=true)
        pathname.removeDirectory(isRecursive=false)
        check pathname.isNotExisting()


    test "#removeDirectory() should delete an empty directory by default":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_EMPTY_DIR")).remove().createEmptyDirectory()
        check pathname.isDirectory()
        pathname.removeDirectory()
        check pathname.isNotExisting()


    test "#removeDirectory(isRecursive=false) should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_EMPTY_DIR")).remove().createEmptyDirectory()
        check pathname.isDirectory()
        pathname.removeDirectory(isRecursive=false)
        check pathname.isNotExisting()


    test "#removeDirectory(isRecursive=true) should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_EMPTY_DIR")).remove().createEmptyDirectory()
        check pathname.isDirectory()
        pathname.removeDirectory(isRecursive=true)
        check pathname.isNotExisting()


    test "#removeDirectory() should NOT delete a full directory by default":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FULL_DIR")).remove().createEmptyDirectory()
        let pathname2 = pathname.join("A_FILE").createRegularFile()
        defer:
            check pathname.removeDirectoryTree().isNotExisting()
        check pathname.isDirectory()
        check pathname2.isRegularFile()
        try:
            pathname.removeDirectory()
            fail()
        except IOError:
            check true
        check pathname.isDirectory()


    test "#removeDirectory(isRecursive=false) should NOT delete a full directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FULL_DIR")).remove().createEmptyDirectory()
        let pathname2 = pathname.join("A_FILE").createRegularFile()
        defer:
            check pathname.removeDirectoryTree().isNotExisting()
        check pathname.isDirectory()
        check pathname2.isRegularFile()
        try:
            pathname.removeDirectory(isRecursive=false)
            fail()
        except IOError:
            check true
        check pathname.isDirectory()


    test "#removeDirectory(isRecursive=true) should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FULL_DIR")).remove().createEmptyDirectory()
        let pathname2 = pathname.join("A_FILE").createRegularFile()
        check pathname.isDirectory()
        check pathname2.isRegularFile()
        pathname.removeDirectory(isRecursive=true)
        check pathname.isNotExisting()


    test "#removeDirectory() should NOT delete a regular file by default":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FILE")).remove().createRegularFile()
        defer:
            check pathname.removeRegularFile().isNotExisting()
        check pathname.isRegularFile()
        try:
            pathname.removeDirectory()
            fail()
        except IOError:
            check true
        check pathname.isRegularFile()


    test "#removeDirectory(isRecursive=false) should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FILE")).remove().createRegularFile()
        defer:
            check pathname.removeRegularFile().isNotExisting()
        check pathname.isRegularFile()
        try:
            pathname.removeDirectory(isRecursive=false)
            fail()
        except IOError:
            check true
        check pathname.isRegularFile()


    test "#removeDirectory(isRecursive=true) should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FILE")).remove().createRegularFile()
        defer:
            check pathname.removeRegularFile().isNotExisting()
        check pathname.isRegularFile()
        try:
            pathname.removeDirectory(isRecursive=true)
            fail()
        except IOError:
            check true
        check pathname.isRegularFile()


    when not pathname.AreSymlinksSupported:
        test "#removeDirectory() symlinks are NOT supported for this Architecture":
            skip


    when pathname.AreSymlinksSupported:
        test "#removeDirectory() should NOT delete a symlink by default":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            defer:
                check pathname.removeSymlink().isNotExisting()
            check pathname.isSymlink()
            try:
                pathname.removeDirectory()
                fail()
            except IOError:
                check true
            check pathname.isSymlink()


    when pathname.AreSymlinksSupported:
        test "#removeDirectory(isRecursive=false) should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            defer:
                check pathname.removeSymlink().isNotExisting()
            check pathname.isSymlink()
            try:
                pathname.removeDirectory(isRecursive=false)
                fail()
            except IOError:
                check true
            check pathname.isSymlink()


    when pathname.AreSymlinksSupported:
        test "#removeDirectory(isRecursive=true) should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            defer:
                check pathname.removeSymlink().isNotExisting()
            check pathname.isSymlink()
            try:
                pathname.removeDirectory(isRecursive=true)
                fail()
            except IOError:
                check true
            check pathname.isSymlink()


    when not pathname.ArePipesSupported:
        test "#removeDirectory() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.ArePipesSupported:
        test "#removeDirectory() should NOT delete a pipe/fifo by default":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FIFO")).remove().createPipeFile()
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname.isPipeFile()
            try:
                pathname.removeDirectory()
                fail()
            except IOError:
                check true
            check pathname.isPipeFile()


    when pathname.ArePipesSupported:
        test "#removeDirectory(isRecursive=false) should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FIFO")).remove().createPipeFile()
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname.isPipeFile()
            try:
                pathname.removeDirectory(isRecursive=false)
                fail()
            except IOError:
                check true
            check pathname.isPipeFile()


    when pathname.ArePipesSupported:
        test "#removeDirectory(isRecursive=true) should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FIFO")).remove().createPipeFile()
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname.isPipeFile()
            try:
                pathname.removeDirectory(isRecursive=true)
                fail()
            except IOError:
                check true
            check pathname.isPipeFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createEmptyDirectory()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createEmptyDirectory() should create an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_EMPTY_DIRECTORY")).remove()
        defer:
            check pathname.removeEmptyDirectory().isNotExisting()
        check pathname.isNotExisting()
        pathname.createEmptyDirectory()
        check pathname.isDirectory()


    test "#createEmptyDirectory() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_EMPTY_DIRECTORY")).remove()
        let pathname2: Pathname = pathname.createEmptyDirectory()
        defer:
            check pathname.removeEmptyDirectory().isNotExisting()
        check pathname2 == pathname


    test "#createEmptyDirectory() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_EMPTY_DIRECTORY")).remove()
        defer:
            check pathname.removeEmptyDirectory().isNotExisting()
        check pathname.isNotExisting()
        pathname.createEmptyDirectory()
        check pathname.isDirectory()
        pathname.createEmptyDirectory()
        check pathname.isDirectory()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeEmptyDirectory()
#-----------------------------------------------------------------------------------------------------------------------


    test "#removeEmptyDirectory() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_EMPTY"))
        let pathname2: Pathname = pathname.removeEmptyDirectory()
        check pathname2 == pathname


    test "#removeEmptyDirectory() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_EMPTY")).remove().createEmptyDirectory()
        check pathname.isDirectory()
        pathname.removeEmptyDirectory()
        check pathname.isNotExisting()
        pathname.removeEmptyDirectory()
        check pathname.isNotExisting()


    test "#removeEmptyDirectory() should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_EMPTY")).remove().createEmptyDirectory()
        check pathname.isDirectory()
        pathname.removeEmptyDirectory()
        check pathname.isNotExisting()


    test "#removeEmptyDirectory() should NOT delete a full directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_FULL")).remove().createEmptyDirectory()
        defer:
            check pathname.removeDirectoryTree().isNotExisting()
        check pathname.isDirectory()
        let pathnameContent = pathname.join("A_FILE").createRegularFile()
        check pathnameContent.isRegularFile()
        try:
            pathname.removeEmptyDirectory()
            fail()
        except IOError:
            check true
        check pathname.isDirectory()


    test "#removeEmptyDirectory() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
        check pathname.isNotExisting()
        pathname.removeEmptyDirectory()
        pathname.removeEmptyDirectory()
        check pathname.isNotExisting()


    test "#removeEmptyDirectory() should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_WITH_SYMLINK")).remove().createRegularFile()
        defer:
            check pathname.removeRegularFile().isNotExisting()
        check pathname.isRegularFile()
        try:
            pathname.removeEmptyDirectory()
            fail()
        except IOError:
            check true
        check pathname.isRegularFile()


    when not pathname.AreSymlinksSupported:
        test "#removeEmptyDirectory() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.AreSymlinksSupported:
        test "#removeEmptyDirectory() should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            defer:
                check pathname.removeSymlink().isNotExisting()
            check pathname.isSymlink()
            try:
                pathname.removeEmptyDirectory()
                fail()
            except IOError:
                check true
            check pathname.isSymlink()


    when not pathname.ArePipesSupported:
        test "#removeEmptyDirectory() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.ArePipesSupported:
        test "#removeEmptyDirectory() should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_WITH_FIFO")).remove().createPipeFile()
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname.isPipeFile()
            try:
                pathname.removeEmptyDirectory()
                fail()
            except IOError:
                check true
            check pathname.isPipeFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeDirectoryTree()
#-----------------------------------------------------------------------------------------------------------------------


    test "#removeDirectoryTree() should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE_EMPTY")).remove().createEmptyDirectory()
        check pathname.isDirectory()
        pathname.removeDirectoryTree()
        check pathname.isNotExisting()


    test "#removeDirectoryTree() should delete a full directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE_FULL")).remove().createEmptyDirectory()
        check pathname.isDirectory()
        let pathnameContent = pathname.join("A_FILE").createRegularFile()
        check pathnameContent.isRegularFile()
        pathname.removeDirectoryTree()
        check pathname.isNotExisting()


    test "#removeDirectoryTree() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE"))
        let pathname2: Pathname = pathname.removeDirectoryTree()
        check pathname2 == pathname


    test "#removeDirectoryTree() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
        check pathname.isNotExisting()
        pathname.removeDirectoryTree()
        pathname.removeDirectoryTree()
        check pathname.isNotExisting()


    test "#removeDirectoryTree() should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE")).remove().createRegularFile()
        defer:
            check pathname.removeRegularFile().isNotExisting()
        check pathname.isRegularFile()
        try:
            pathname.removeDirectoryTree()
            fail()
        except IOError:
            check true
        check pathname.isRegularFile()


    when not pathname.AreSymlinksSupported:
        test "#removeDirectoryTree() symlinks are NOT supported for this Architecture":
            skip


    when pathname.AreSymlinksSupported:
        test "#removeDirectoryTree() should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            defer:
                check pathname.removeSymlink().isNotExisting()
            check pathname.isSymlink()
            try:
                pathname.removeDirectoryTree()
                fail()
            except IOError:
                check true
            check pathname.isSymlink()


    when not pathname.ArePipesSupported:
        test "#removeDirectoryTree() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.ArePipesSupported:
        test "#removeDirectoryTree() should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE_FIFO")).remove().createPipeFile()
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname.isPipeFile()
            try:
                pathname.removeDirectoryTree()
                fail()
            except IOError:
                check true
            check pathname.isPipeFile()


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
                pathname.createSymlinkTo("NOT_EXISTING").remove()
                fail
            except NotSupportedError:
                check true
            except Exception:
                fail


    when pathname.AreSymlinksSupported:
        test "#createSymlinkTo() should create a symlink":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_TO")).remove()
            defer:
                check pathname.removeSymlink().isNotExisting()
            check pathname.isNotExisting()
            pathname.createSymlinkTo("NOT_EXISTING")
            check pathname.isSymlink()


    when pathname.AreSymlinksSupported:
        test "#createSymlinkTo() should return self for Method-Chaining":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_TO")).remove()
            let pathname2: Pathname = pathname.createSymlinkTo("NOT_EXISTING")
            defer:
                check pathname.removeSymlink().isNotExisting()
            check pathname2 == pathname


    when pathname.AreSymlinksSupported:
        test "#createSymlinkTo() should NOT allow multiple calls":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_TO")).remove()
            defer:
                check pathname.removeSymlink().isNotExisting()
            check pathname.isNotExisting()
            pathname.createSymlinkTo("NOT_EXISTING")
            check pathname.isSymlink()
            try:
                pathname.createSymlinkTo("NOT_EXISTING")
                fail()
            except IOError:
                check true


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
            let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
            let pathnameSymlink = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_FROM")).remove()
            defer:
                check pathnameSymlink.removeSymlink().isNotExisting()
            check pathnameSymlink.isNotExisting()
            pathname.createSymlinkFrom(fixturePath("TEST_CREATE_SYMLINK_FROM"))
            check pathnameSymlink.isSymlink()


    when pathname.AreSymlinksSupported:
        test "#createSymlinkFrom() should return self for Method-Chaining":
            let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
            let pathname2: Pathname = pathname.createSymlinkFrom(fixturePath("TEST_CREATE_SYMLINK_FROM"))
            defer:
                check Pathname.new(fixturePath("TEST_CREATE_SYMLINK_FROM")).removeSymlink().isNotExisting()
            check pathname2 == pathname


    when pathname.AreSymlinksSupported:
        test "#createSymlinkFrom() should NOT allow multiple calls":
            let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
            let pathnameSymlink = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_FROM")).remove()
            defer:
                check pathnameSymlink.removeSymlink().isNotExisting()
            check pathnameSymlink.isNotExisting()
            pathname.createSymlinkFrom(fixturePath("TEST_CREATE_SYMLINK_FROM"))
            check pathnameSymlink.isSymlink()
            try:
                pathname.createSymlinkFrom(fixturePath("TEST_CREATE_SYMLINK_FROM"))
                fail()
            except IOError:
                check true


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
            check pathname.isSymlink()
            pathname.removeSymlink()
            check pathname.isNotExisting()
            pathname.removeSymlink()
            check pathname.isNotExisting()


    when pathname.AreSymlinksSupported:
        test "#removeSymlink() should delete a pipe file":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK_WITH_PIPE")).remove().createSymlinkTo("NOT_EXISTING")
            check pathname.isSymlink()
            pathname.removeSymlink()
            check pathname.isNotExisting()


    when pathname.AreSymlinksSupported:
        test "#removeSymlink() should handle deletion of non existing file-entry":
            let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
            check pathname.isNotExisting()
            pathname.removeSymlink()
            pathname.removeSymlink()
            check pathname.isNotExisting()


    when pathname.AreSymlinksSupported:
        test "#removeSymlink() should NOT delete a regular file":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK_WITH_REGULAR_FILE")).remove().createRegularFile()
            defer:
                check pathname.removeRegularFile().isNotExisting()
            check pathname.isRegularFile()
            try:
                pathname.removeSymlink()
                fail()
            except IOError:
                check true
            check pathname.isRegularFile()


    when pathname.AreSymlinksSupported:
        test "#removeSymlink() should NOT delete a directory":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK_WITH_DIRECTORY")).remove().createEmptyDirectory()
            defer:
                check pathname.removeEmptyDirectory().isNotExisting()
            check pathname.isDirectory()
            try:
                pathname.removeSymlink()
                fail()
            except IOError:
                check true
            check pathname.isDirectory()


    when pathname.AreSymlinksSupported:
        test "#removeSymlink() should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK_WITH_FIFO")).remove().createPipeFile()
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname.isPipeFile()
            try:
                pathname.removeSymlink()
                fail()
            except IOError:
                check true
            check pathname.isPipeFile()


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
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname.isNotExisting()
            pathname.createPipeFile()
            check pathname.isPipeFile()


    when pathname.ArePipesSupported:
        test "#createPipeFile() should NOT allow multiple calls, because the target may otherwise not as expected":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_PIPE_FILE")).remove()
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname.isNotExisting()
            pathname.createPipeFile()
            check pathname.isPipeFile()
            try:
                pathname.createPipeFile()
                fail
            except IOError:
                check true
            check pathname.isPipeFile()


    when pathname.ArePipesSupported:
        test "#createPipeFile() should return self for Method-Chaining":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_PIPE_FILE")).remove()
            let pathname2: Pathname = pathname.createPipeFile()
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname2 == pathname


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
            check pathname.isPipeFile()
            pathname.removePipeFile()
            check pathname.isNotExisting()
            pathname.removePipeFile()
            check pathname.isNotExisting()


    when pathname.ArePipesSupported:
        test "#removePipeFile() should delete a pipe file":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE")).remove().createPipeFile()
            check pathname.isPipeFile()
            pathname.removePipeFile()
            check pathname.isNotExisting()


    when pathname.ArePipesSupported:
        test "#removePipeFile() should handle deletion of non existing file-entry":
            let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
            check pathname.isNotExisting()
            pathname.removePipeFile()
            pathname.removePipeFile()
            check pathname.isNotExisting()


    when pathname.ArePipesSupported:
        test "#removePipeFile() should NOT delete a regular file":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_REGULAR")).remove().createRegularFile()
            defer:
                check pathname.removeRegularFile().isNotExisting()
            check pathname.isRegularFile()
            try:
                pathname.removePipeFile()
                fail()
            except IOError:
                check true
            check pathname.isRegularFile()


    when pathname.ArePipesSupported:
        test "#removePipeFile() should NOT delete a directory":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_DIRECTORY")).remove().createEmptyDirectory()
            defer:
                check pathname.removeEmptyDirectory().isNotExisting()
            check pathname.isDirectory()
            try:
                pathname.removePipeFile()
                fail()
            except IOError:
                check true
            check pathname.isDirectory()


    when pathname.ArePipesSupported:
        test "#removePipeFile() should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            defer:
                check pathname.removeSymlink().isNotExisting()
            check pathname.isSymlink()
            try:
                pathname.removePipeFile()
                fail()
            except IOError:
                check true
            check pathname.isSymlink()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createCharacterDeviceFile()
#-----------------------------------------------------------------------------------------------------------------------


    when not pathname.AreDeviceFilesSupported:
        test "#createCharacterDeviceFile() character device files are NOT supported for this Architecture":
            skip


    when not pathname.AreDeviceFilesSupported:
        test "#createCharacterDeviceFile() should raise NotSupported-Error for this Architecture":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_CHARACTER_DEVICE_FILE1")).remove()
            try:
                pathname.createCharacterDeviceFile(1, 1)
                fail
            except NotSupportedError:
                check true
            except Exception:
                fail


    when pathname.AreDeviceFilesSupported:
        test "#createCharacterDeviceFile() should raise IOError when not root":
            if not isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_CREATE_CHARACTER_DEVICE_FILE2")).remove()
                try:
                    defer:
                        check pathname.removeCharacterDeviceFile().isNotExisting()
                    check pathname.isNotExisting()
                    pathname.createCharacterDeviceFile(1, 3)  # /dev/null
                    fail
                except IOError:
                    check true
                except Exception:
                    fail
                check pathname.isNotExisting()
            else:
                echo "Test can not be applied, because it needs to be run as non root user"
                skip


    when pathname.ArePipesSupported:
        test "#createCharacterDeviceFile() should NOT allow multiple calls, because the target may otherwise not as expected":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_CREATE_CHARACTER_DEVICE_FILE3")).remove()
                defer:
                    check pathname.removeCharacterDeviceFile().isNotExisting()
                check pathname.isNotExisting()
                pathname.createCharacterDeviceFile(1, 3)  # /dev/null
                check pathname.isCharacterDeviceFile()
                try:
                    pathname.createCharacterDeviceFile(1, 3)  # /dev/null
                    fail
                except IOError:
                    check true
                check pathname.isCharacterDeviceFile()
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


    when pathname.AreDeviceFilesSupported:
        test "#createCharacterDeviceFile() should create a character device (needs root)":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_CREATE_CHARACTER_DEVICE_FILE4")).remove()
                defer:
                    check pathname.removeCharacterDeviceFile().isNotExisting()
                check pathname.isNotExisting()
                pathname.createCharacterDeviceFile(1, 3)  # /dev/null
                check pathname.isCharacterDeviceFile()
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


    when pathname.AreDeviceFilesSupported:
        test "#createCharacterDeviceFile() should allow multiple calls (needs root)":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_CREATE_CHARACTER_DEVICE_FILE5")).remove()
                defer:
                    check pathname.removeCharacterDeviceFile().isNotExisting()
                check pathname.isNotExisting()
                pathname.createCharacterDeviceFile(1, 3)  # /dev/null
                check pathname.isCharacterDeviceFile()
                pathname.createCharacterDeviceFile(1, 3)  # /dev/null
                check pathname.isCharacterDeviceFile()
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


    when pathname.AreDeviceFilesSupported:
        test "#createCharacterDeviceFile() should return self for Method-Chaining (needs root)":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_CREATE_CHARACTER_DEVICE_FILE6")).remove()
                let pathname2: Pathname = pathname.createCharacterDeviceFile(1, 3)
                defer:
                    check pathname.removeCharacterDeviceFile().isNotExisting()
                check pathname2 == pathname
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeCharacterDeviceFile()
#-----------------------------------------------------------------------------------------------------------------------


    when not pathname.AreDeviceFilesSupported:
        test "#removeCharacterDeviceFile() character device files are NOT supported for this Architecture":
            skip


    when not pathname.AreDeviceFilesSupported:
        test "#removeCharacterDeviceFile() should raise NotSupported-Error for this Architecture":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_CHARACTER_DEVICE_FILE")).remove()
            try:
                pathname.removeCharacterDeviceFile()
                fail
            except NotSupportedError:
                check true
            except Exception:
                fail


    when pathname.AreDeviceFilesSupported:
        test "#removeCharacterDeviceFile() should return self for Method-Chaining":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_CHARACTER_DEVICE_FILE")).remove()
            let pathname2: Pathname = pathname.removeCharacterDeviceFile()
            check pathname2 == pathname


    when pathname.AreDeviceFilesSupported:
        test "#removeCharacterDeviceFile() should allow multiple calls":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_CHARACTER_DEVICE_FILE")).remove()
            pathname.removeCharacterDeviceFile()
            pathname.removeCharacterDeviceFile()


    when pathname.AreDeviceFilesSupported:
        test "#removeCharacterDeviceFile() should handle deletion of non existing file-entry":
            let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
            check pathname.isNotExisting()
            pathname.removeCharacterDeviceFile()
            check pathname.isNotExisting()


    when pathname.AreDeviceFilesSupported:
        test "#removeCharacterDeviceFile() should delete a character device file (needs root)":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_REMOVE_CHARACTER_DEVICE_FILE_WITH_CHAR_DEVICE")).remove().createCharacterDeviceFile(1, 3) # /dev/null
                check pathname.isCharacterDeviceFile()
                pathname.removeCharacterDeviceFile()
                check pathname.isNotExisting()
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


    when pathname.AreDeviceFilesSupported:
        test "#removeCharacterDeviceFile() should NOT delete a block device file (needs root)":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_REMOVE_CHARACTER_DEVICE_FILE_WITH_BLOCK_DEVICE")).remove().createBlockDeviceFile(1, 3) # /dev/null
                defer:
                    check pathname.removeCharacterDeviceFile().isNotExisting()
                check pathname.isBlockDeviceFile()
                try:
                    pathname.removeCharacterDeviceFile()
                    fail()
                except IOError:
                    check true
                check pathname.isCharacterDeviceFile()
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


    when pathname.AreDeviceFilesSupported:
        test "#removeCharacterDeviceFile() should NOT delete a regular file":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_CHARACTER_DEVICE_FILE_WITH_REGULAR_FILE")).remove().createRegularFile()
            defer:
                check pathname.removeRegularFile().isNotExisting()
            check pathname.isRegularFile()
            try:
                pathname.removeCharacterDeviceFile()
                fail()
            except IOError:
                check true
            check pathname.isRegularFile()


    when pathname.AreDeviceFilesSupported:
        test "#removeCharacterDeviceFile() should NOT delete a directory":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_CHARACTER_DEVICE_FILE_WITH_DIRECTORY")).remove().createEmptyDirectory()
            defer:
                check pathname.removeEmptyDirectory().isNotExisting()
            check pathname.isDirectory()
            try:
                pathname.removeCharacterDeviceFile()
                fail()
            except IOError:
                check true
            check pathname.isDirectory()


    when pathname.AreDeviceFilesSupported:
        test "#removeCharacterDeviceFile() should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_CHARACTER_DEVICE_FILE_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            defer:
                check pathname.removeSymlink().isNotExisting()
            check pathname.isSymlink()
            try:
                pathname.removeCharacterDeviceFile()
                fail()
            except IOError:
                check true
            check pathname.isSymlink()


    when pathname.AreDeviceFilesSupported:
        test "#removeCharacterDeviceFile() should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_CHARACTER_DEVICE_FILE_WITH_PIPE")).remove().createPipeFile()
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname.isPipeFile()
            try:
                pathname.removeCharacterDeviceFile()
                fail()
            except IOError:
                check true
            check pathname.isPipeFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createBlockDeviceFile()
#-----------------------------------------------------------------------------------------------------------------------


    when not pathname.AreDeviceFilesSupported:
        test "#createBlockDeviceFile() block device files are NOT supported for this Architecture":
            skip


    when not pathname.AreDeviceFilesSupported:
        test "#createBlockDeviceFile() should raise NotSupported-Error for this Architecture":
            let pathname = Pathname.new(fixturePath("TEST_CREATE_BLOCK_DEVICE_FILE1")).remove()
            try:
                pathname.createBlockDeviceFile(1, 1)
                fail
            except NotSupportedError:
                check true
            except Exception:
                fail


    when pathname.AreDeviceFilesSupported:
        test "#createBlockDeviceFile() should raise IOError when not root":
            if not isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_CREATE_BLOCK_DEVICE_FILE2")).remove()
                try:
                    defer:
                        check pathname.removeBlockDeviceFile().isNotExisting()
                    check pathname.isNotExisting()
                    pathname.createBlockDeviceFile(1, 3)  # /dev/null
                    fail
                except IOError:
                    check true
                except Exception:
                    fail
                check pathname.isNotExisting()
            else:
                echo "Test can not be applied, because it needs to be run as non root user"
                skip


    when pathname.ArePipesSupported:
        test "#createBlockDeviceFile() should NOT allow multiple calls, because the target may otherwise not as expected":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_CREATE_BLOCK_DEVICE_FILE3")).remove()
                defer:
                    check pathname.removeBlockDeviceFile().isNotExisting()
                check pathname.isNotExisting()
                pathname.createBlockDeviceFile(1, 3)  # /dev/null
                check pathname.isBlockDeviceFile()
                try:
                    pathname.createBlockDeviceFile(1, 3)  # /dev/null
                    fail
                except IOError:
                    check true
                check pathname.isBlockDeviceFile()
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


    when pathname.AreDeviceFilesSupported:
        test "#createBlockDeviceFile() should create a character device (needs root)":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_CREATE_BLOCK_DEVICE_FILE4")).remove()
                defer:
                    check pathname.removeBlockDeviceFile().isNotExisting()
                check pathname.isNotExisting()
                pathname.createBlockDeviceFile(1, 3)  # /dev/null
                check pathname.isCharacterDeviceFile()
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


    when pathname.AreDeviceFilesSupported:
        test "#createBlockDeviceFile() should allow multiple calls (needs root)":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_CREATE_BLOCK_DEVICE_FILE5")).remove()
                defer:
                    check pathname.removeBlockDeviceFile().isNotExisting()
                check pathname.isNotExisting()
                pathname.createBlockDeviceFile(1, 3)  # /dev/null
                check pathname.isCharacterDeviceFile()
                pathname.createBlockDeviceFile(1, 3)  # /dev/null
                check pathname.isCharacterDeviceFile()
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


    when pathname.AreDeviceFilesSupported:
        test "#createBlockDeviceFile() should return self for Method-Chaining (needs root)":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_CREATE_BLOCK_DEVICE_FILE6")).remove()
                let pathname2: Pathname = pathname.createBlockDeviceFile(1, 3)
                defer:
                    check pathname.removeBlockDeviceFile().isNotExisting()
                check pathname2 == pathname
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeBlockDeviceFile()
#-----------------------------------------------------------------------------------------------------------------------


    when not pathname.AreDeviceFilesSupported:
        test "#removeBlockDeviceFile() block device files are NOT supported for this Architecture":
            skip


    when not pathname.AreDeviceFilesSupported:
        test "#removeBlockDeviceFile() should raise NotSupported-Error for this Architecture":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_BLOCK_DEVICE_FILE")).remove()
            try:
                pathname.removeBlockDeviceFile()
                fail
            except NotSupportedError:
                check true
            except Exception:
                fail


    when pathname.AreDeviceFilesSupported:
        test "#removeBlockDeviceFile() should return self for Method-Chaining":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_BLOCK_DEVICE_FILE")).remove()
            let pathname2: Pathname = pathname.removeBlockDeviceFile()
            check pathname2 == pathname


    when pathname.AreDeviceFilesSupported:
        test "#removeBlockDeviceFile() should allow multiple calls":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_BLOCK_DEVICE_FILE")).remove()
            pathname.removeBlockDeviceFile()
            pathname.removeBlockDeviceFile()


    when pathname.AreDeviceFilesSupported:
        test "#removeBlockDeviceFile() should handle deletion of non existing file-entry":
            let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
            check pathname.isNotExisting()
            pathname.removeBlockDeviceFile()
            check pathname.isNotExisting()


    when pathname.AreDeviceFilesSupported:
        test "#removeBlockDeviceFile() should delete a block device file (needs root)":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_REMOVE_BLOCK_DEVICE_FILE_WITH_BLOCK_DEVICE")).remove().createBlockDeviceFile(1, 3) # /dev/null
                check pathname.isBlockDeviceFile()
                pathname.removeBlockDeviceFile()
                check pathname.isNotExisting()
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


    when pathname.AreDeviceFilesSupported:
        test "#removeBlockDeviceFile() should NOT delete a character device file (needs root)":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_REMOVE_BLOCK_DEVICE_FILE_WITH_BLOCK_DEVICE")).remove().createCharacterDeviceFile(1, 3) # /dev/null
                defer:
                    check pathname.removeCharacterDeviceFile().isNotExisting()
                check pathname.isBlockDeviceFile()
                try:
                    pathname.removeBlockDeviceFile()
                    fail()
                except IOError:
                    check true
                check pathname.isBlockDeviceFile()
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


    when pathname.AreDeviceFilesSupported:
        test "#removeBlockDeviceFile() should NOT delete a regular file":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_BLOCK_DEVICE_FILE_WITH_REGULAR_FILE")).remove().createRegularFile()
            defer:
                check pathname.removeRegularFile().isNotExisting()
            check pathname.isRegularFile()
            try:
                pathname.removeBlockDeviceFile()
                fail()
            except IOError:
                check true
            check pathname.isRegularFile()


    when pathname.AreDeviceFilesSupported:
        test "#removeBlockDeviceFile() should NOT delete a directory":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_BLOCK_DEVICE_FILE_WITH_DIRECTORY")).remove().createEmptyDirectory()
            defer:
                check pathname.removeEmptyDirectory().isNotExisting()
            check pathname.isDirectory()
            try:
                pathname.removeBlockDeviceFile()
                fail()
            except IOError:
                check true
            check pathname.isDirectory()


    when pathname.AreDeviceFilesSupported:
        test "#removeBlockDeviceFile() should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_BLOCK_DEVICE_FILE_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            defer:
                check pathname.removeSymlink().isNotExisting()
            check pathname.isSymlink()
            try:
                pathname.removeBlockDeviceFile()
                fail()
            except IOError:
                check true
            check pathname.isSymlink()


    when pathname.AreDeviceFilesSupported:
        test "#removeBlockDeviceFile() should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_BLOCK_DEVICE_FILE_WITH_PIPE")).remove().createPipeFile()
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname.isPipeFile()
            try:
                pathname.removeBlockDeviceFile()
                fail()
            except IOError:
                check true
            check pathname.isPipeFile()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeDeviceFile()
#-----------------------------------------------------------------------------------------------------------------------


    when not pathname.AreDeviceFilesSupported:
        test "#removeDeviceFile() device files are NOT supported for this Architecture":
            skip


    when not pathname.AreDeviceFilesSupported:
        test "#removeDeviceFile() should raise NotSupported-Error for this Architecture":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_BLOCK_DEVICE_FILE")).remove()
            try:
                pathname.removeDeviceFile()
                fail
            except NotSupportedError:
                check true
            except Exception:
                fail


    when pathname.AreDeviceFilesSupported:
        test "#removeDeviceFile() should return self for Method-Chaining":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DEVICE_FILE")).remove()
            let pathname2: Pathname = pathname.removeDeviceFile()
            check pathname2 == pathname


    when pathname.AreDeviceFilesSupported:
        test "#removeDeviceFile() should allow multiple calls":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DEVICE_FILE")).remove()
            pathname.removeDeviceFile()
            pathname.removeDeviceFile()


    when pathname.AreDeviceFilesSupported:
        test "#removeDeviceFile() should handle deletion of non existing file-entry":
            let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
            check pathname.isNotExisting()
            pathname.removeDeviceFile()
            check pathname.isNotExisting()


    when pathname.AreDeviceFilesSupported:
        test "#removeDeviceFile() should delete a character device file (needs root)":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_REMOVE_DEVICE_FILE_WITH_BLOCK_DEVICE")).remove().createCharacterDeviceFile(1, 3) # /dev/null
                check pathname.isCharacterDeviceFile()
                pathname.removeDeviceFile()
                check pathname.isNotExisting()
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


    when pathname.AreDeviceFilesSupported:
        test "#removeDeviceFile() should delete a block device file (needs root)":
            if isRootUser():
                let pathname = Pathname.new(fixturePath("TEST_REMOVE_DEVICE_FILE_WITH_BLOCK_DEVICE")).remove().createBlockDeviceFile(1, 3) # /dev/null
                check pathname.isBlockDeviceFile()
                pathname.removeDeviceFile()
                check pathname.isNotExisting()
            else:
                echo "Test can not be applied, because it needs to be run as root user"
                skip


    when pathname.AreDeviceFilesSupported:
        test "#removeDeviceFile() should NOT delete a regular file":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DEVICE_FILE_WITH_REGULAR_FILE")).remove().createRegularFile()
            defer:
                check pathname.removeRegularFile().isNotExisting()
            check pathname.isRegularFile()
            try:
                pathname.removeDeviceFile()
                fail()
            except IOError:
                check true
            check pathname.isRegularFile()


    when pathname.AreDeviceFilesSupported:
        test "#removeDeviceFile() should NOT delete a directory":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DEVICE_FILE_WITH_DIRECTORY")).remove().createEmptyDirectory()
            defer:
                check pathname.removeEmptyDirectory().isNotExisting()
            check pathname.isDirectory()
            try:
                pathname.removeDeviceFile()
                fail()
            except IOError:
                check true
            check pathname.isDirectory()


    when pathname.AreDeviceFilesSupported:
        test "#removeDeviceFile() should NOT delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DEVICE_FILE_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            defer:
                check pathname.removeSymlink().isNotExisting()
            check pathname.isSymlink()
            try:
                pathname.removeDeviceFile()
                fail()
            except IOError:
                check true
            check pathname.isSymlink()


    when pathname.AreDeviceFilesSupported:
        test "#removeDeviceFile() should NOT delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_DEVICE_FILE_WITH_PIPE")).remove().createPipeFile()
            defer:
                check pathname.removePipeFile().isNotExisting()
            check pathname.isPipeFile()
            try:
                pathname.removeDeviceFile()
                fail()
            except IOError:
                check true
            check pathname.isPipeFile()



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - remove()
#-----------------------------------------------------------------------------------------------------------------------


    test "#remove() should return self for Method-Chaining and be multiple callable":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
        let pathname2 = pathname.remove()
        let pathname3 = pathname.remove().remove().remove()
        check pathname == pathname2
        check pathname == pathname3


    test "#remove() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING")).remove()
        check pathname.isNotExisting()
        pathname.remove()
        check pathname.isNotExisting()


    test "#remove() should delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_REGULAR_FILE")).remove().createRegularFile()
        check pathname.isRegularFile()
        pathname.remove()
        check pathname.isNotExisting()


    test "#remove() should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_EMPTY_DIRECTORY")).remove().createEmptyDirectory()
        check pathname.isDirectory()
        pathname.remove()
        check pathname.isNotExisting()


    test "#remove() should delete a full directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_FULL_DIRECTORY")).remove().createEmptyDirectory()
        check pathname.isDirectory()
        let pathname2 = pathname.join("A_FILE").createRegularFile()
        check pathname2.isRegularFile()
        pathname.remove()
        check pathname.isNotExisting()


    when not pathname.AreSymlinksSupported:
        test "#remove() symlinks are NOT supported for this Architecture":
            skip


    when pathname.AreSymlinksSupported:
        test "#remove() should delete a symlink":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_SYMLINK")).remove().createSymlinkTo("NOT_EXISTING")
            check pathname.isSymlink()
            pathname.remove()
            check pathname.isNotExisting()


    when not pathname.AreSymlinksSupported:
        test "#remove() pipes/fifos are NOT supported for this Architecture":
            skip


    when pathname.ArePipesSupported:
        test "#remove() should delete a pipe/fifo":
            let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_PIPE")).remove().createPipeFile()
            check pathname.isPipeFile()
            pathname.remove()
            check pathname.isNotExisting()
