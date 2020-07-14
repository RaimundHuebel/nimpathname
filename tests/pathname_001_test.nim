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

import unittest
import test_helper


suite "Pathname Tests 001":


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - File-System-Access
#-----------------------------------------------------------------------------------------------------------------------


    test "#readAll() from existing File":
        check "Hello World!\n" == Pathname.new(fixturePath("sample_file_000.txt")).readAll()


    test "#readAll() from non existing file-entry should fail":
        expect(IOError):
            discard Pathname.new(fixturePath("NOT_EXISTING")).readAll()


    test "#readAll() from Directory should fail":
        expect(IOError):
            discard Pathname.new(fixturePath("sample_dir")).readAll()



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
# Pathname - createFile()/removeFile()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createFile() should create a regular File":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_FILE")).removeRegularFile()
        check false == pathname.isExisting()
        pathname.createFile()
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#createFile() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_FILE")).removeRegularFile()
        check false == pathname.isExisting()
        pathname.createFile()
        check true == pathname.isRegularFile()
        pathname.createFile()
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#createFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_FILE")).removeRegularFile()
        let pathname2: Pathname = pathname.createFile()
        #echo "'", pathname, "'"
        #echo "'", pathname2, "'"
        check pathname2 == pathname
        pathname.removeRegularFile()


    test "#removeFile() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        check false == pathname.isExisting()
        pathname.removeFile()
        pathname.removeFile()
        check false == pathname.isExisting()


    test "#removeFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE"))
        let pathname2: Pathname = pathname.removeFile()
        check pathname2 == pathname


    test "#removeFile() should delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE")).createRegularFile()
        check true == pathname.isRegularFile()
        pathname.removeFile()
        check false == pathname.isExisting()


    test "#removeFile() should NOT delete a directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE_WITH_DIRECTORY")).createEmptyDirectory()
        check true == pathname.isDirectory()
        try:
            pathname.removeFile()
            fail()
        except IOError:
            check true
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


    test "#removeFile() should delete a symlink":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE_WITH_SYMLINK")).removeSymlink().createSymlinkTo("NOT_EXISTING")
        check true == pathname.isSymlink()
        pathname.removeFile()
        check false == pathname.isExisting()


    test "#removeFile() should delete a pipe/fifo":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_FILE_WITH_PIPE")).createPipeFile()
        check true == pathname.isPipeFile()
        pathname.removeFile()
        check false == pathname.isExisting()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createRegularFile()/removeRegularFile()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createRegularFile() should create a regular File":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_REGULAR_FILE")).removeRegularFile()
        check false == pathname.isExisting()
        pathname.createRegularFile()
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#createRegularFile() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_REGULAR_FILE")).removeRegularFile()
        check false == pathname.isExisting()
        pathname.createRegularFile()
        check true == pathname.isRegularFile()
        pathname.createRegularFile()
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#createRegularFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_REGULAR_FILE")).removeRegularFile()
        let pathname2: Pathname = pathname.createRegularFile()
        check pathname2 == pathname
        pathname.removeRegularFile()


    test "#removeRegularFile() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        check false == pathname.isExisting()
        pathname.removeRegularFile()
        pathname.removeRegularFile()
        check false == pathname.isExisting()


    test "#removeRegularFile() should delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE")).createRegularFile()
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()
        check false == pathname.isExisting()


    test "#removeRegularFile() should NOT delete a directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE_WITH_DIRECTORY")).createEmptyDirectory()
        check true == pathname.isDirectory()
        try:
            pathname.removeRegularFile()
            fail()
        except IOError:
            check true
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


    test "#removeRegularFile() should NOT delete a symlink":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE_WITH_SYMLINK")).removeSymlink().createSymlinkTo("NOT_EXISTING")
        check true == pathname.isSymlink()
        try:
            pathname.removeRegularFile()
            fail()
        except IOError:
            check true
        check true == pathname.isSymlink()
        pathname.removeSymlink()


    test "#removeRegularFile() should NOT delete a pipe/fifo":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE_WITH_PIPE")).createPipeFile()
        check true == pathname.isPipeFile()
        try:
            pathname.removeRegularFile()
            fail()
        except IOError:
            check true
        check true == pathname.isPipeFile()
        pathname.removePipeFile()


    test "#removeRegularFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_REGULAR_FILE"))
        let pathname2: Pathname = pathname.removeRegularFile()
        check pathname2 == pathname


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createDirectory()/removeDirectory()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createDirectory() should create an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_DIRECTORY")).removeEmptyDirectory()
        check false == pathname.isExisting()
        pathname.createDirectory()
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


    test "#createDirectory() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_DIRECTORY")).removeEmptyDirectory()
        check false == pathname.isExisting()
        pathname.createDirectory()
        check true == pathname.isDirectory()
        pathname.createDirectory()
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


    test "#createDirectory() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_DIRECTORY")).removeEmptyDirectory()
        let pathname2: Pathname = pathname.createDirectory()
        check pathname2 == pathname
        pathname.removeEmptyDirectory()


    test "#removeDirectory() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        check false == pathname.isExisting()
        pathname.removeDirectory()
        pathname.removeDirectory(isRecursive=true)
        pathname.removeDirectory(isRecursive=false)
        check false == pathname.isExisting()


    test "#removeDirectory() should delete an empty directory by default":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_EMPTY_DIR")).createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeDirectory()
        check false == pathname.isExisting()


    test "#removeDirectory(isRecursive=false) should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_EMPTY_DIR")).createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeDirectory(isRecursive=false)
        check false == pathname.isExisting()


    test "#removeDirectory(isRecursive=true) should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_EMPTY_DIR")).createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeDirectory(isRecursive=true)
        check false == pathname.isExisting()


    test "#removeDirectory() should NOT delete a full directory by default":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FULL_DIR")).createEmptyDirectory()
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
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FULL_DIR")).createEmptyDirectory()
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
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FULL_DIR")).createEmptyDirectory()
        check true == pathname.isDirectory()
        let pathname2 = pathname.join("A_FILE").createRegularFile()
        check true == pathname2.isRegularFile()
        pathname.removeDirectory(isRecursive=true)
        check false == pathname.isExisting()


    test "#removeDirectory() should NOT delete a regular file by default":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FILE")).createRegularFile()
        check true == pathname.isRegularFile()
        try:
            pathname.removeDirectory()
            fail()
        except IOError:
            check true
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#removeDirectory(isRecursive=false) should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FILE")).createRegularFile()
        check true == pathname.isRegularFile()
        try:
            pathname.removeDirectory(isRecursive=false)
            fail()
        except IOError:
            check true
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#removeDirectory(isRecursive=true) should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FILE")).createRegularFile()
        check true == pathname.isRegularFile()
        try:
            pathname.removeDirectory(isRecursive=true)
            fail()
        except IOError:
            check true
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#removeDirectory() should NOT delete a pipe/fifo by default":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FIFO")).createPipeFile()
        check true == pathname.isPipeFile()
        try:
            pathname.removeDirectory()
            fail()
        except IOError:
            check true
        check true == pathname.isPipeFile()
        pathname.removePipeFile()


    test "#removeDirectory(isRecursive=false) should NOT delete a pipe/fifo":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FIFO")).createPipeFile()
        check true == pathname.isPipeFile()
        try:
            pathname.removeDirectory(isRecursive=false)
            fail()
        except IOError:
            check true
        check true == pathname.isPipeFile()
        pathname.removePipeFile()


    test "#removeDirectory(isRecursive=true) should NOT delete a pipe/fifo":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_FIFO")).createPipeFile()
        check true == pathname.isPipeFile()
        try:
            pathname.removeDirectory(isRecursive=true)
            fail()
        except IOError:
            check true
        check true == pathname.isPipeFile()
        pathname.removePipeFile()


    test "#removeDirectory() should NOT delete a symlink by default":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_SYMLINK")).removeSymlink().createSymlinkTo("NOT_EXISTING")
        check true == pathname.isSymlink()
        try:
            pathname.removeDirectory()
            fail()
        except IOError:
            check true
        check true == pathname.isSymlink()
        pathname.removeSymlink()


    test "#removeDirectory(isRecursive=false) should NOT delete a symlink":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_SYMLINK")).removeSymlink().createSymlinkTo("NOT_EXISTING")
        check true == pathname.isSymlink()
        try:
            pathname.removeDirectory(isRecursive=false)
            fail()
        except IOError:
            check true
        check true == pathname.isSymlink()
        pathname.removeSymlink()


    test "#removeDirectory(isRecursive=true) should NOT delete a symlink":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_WITH_SYMLINK")).removeSymlink().createSymlinkTo("NOT_EXISTING")
        check true == pathname.isSymlink()
        try:
            pathname.removeDirectory(isRecursive=true)
            fail()
        except IOError:
            check true
        check true == pathname.isSymlink()
        pathname.removeSymlink()


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


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createEmptyDirectory()/removeEmptyDirectory()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createEmptyDirectory() should create an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_EMPTY_DIRECTORY")).removeEmptyDirectory()
        check false == pathname.isExisting()
        pathname.createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


    test "#createEmptyDirectory() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_EMPTY_DIRECTORY")).removeEmptyDirectory()
        let pathname2: Pathname = pathname.createEmptyDirectory()
        check pathname2 == pathname
        pathname.removeEmptyDirectory()


    test "#removeEmptyDirectory() should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_EMPTY")).createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()
        check false == pathname.isExisting()


    test "#removeEmptyDirectory() should NOT delete a full directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_FULL")).createEmptyDirectory()
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
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_WITH_SYMLINK")).removeRegularFile().createRegularFile()
        check true == pathname.isRegularFile()
        try:
            pathname.removeEmptyDirectory()
            fail()
        except IOError:
            check true
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#removeEmptyDirectory() should NOT delete a symlink":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_WITH_SYMLINK")).removeSymlink().createSymlinkTo("NOT_EXISTING")
        check true == pathname.isSymlink()
        try:
            pathname.removeEmptyDirectory()
            fail()
        except IOError:
            check true
        check true == pathname.isSymlink()
        pathname.removeSymlink()


    test "#removeEmptyDirectory() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_EMPTY_DIRECTORY_EMPTY"))
        let pathname2: Pathname = pathname.removeEmptyDirectory()
        check pathname2 == pathname



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - removeDirectoryTree()
#-----------------------------------------------------------------------------------------------------------------------


    test "#removeDirectoryTree() should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE_EMPTY")).createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.removeDirectoryTree()
        check false == pathname.isExisting()


    test "#removeDirectoryTree() should delete a full directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE_FULL")).createEmptyDirectory()
        check true == pathname.isDirectory()
        let pathnameContent = pathname.join("A_FILE").createRegularFile()
        check true == pathnameContent.isRegularFile()
        pathname.removeDirectoryTree()
        check false == pathname.isExisting()


    test "#removeDirectoryTree() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        check false == pathname.isExisting()
        pathname.removeDirectoryTree()
        pathname.removeDirectoryTree()
        check false == pathname.isExisting()


    test "#removeDirectoryTree() should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE")).createRegularFile()
        check true == pathname.isRegularFile()
        try:
            pathname.removeDirectoryTree()
            fail()
        except IOError:
            check true
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#removeDirectoryTree() should NOT delete a symlink":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE_WITH_SYMLINK")).removeSymlink().createSymlinkTo("NOT_EXISTING")
        check true == pathname.isSymlink()
        try:
            pathname.removeDirectoryTree()
            fail()
        except IOError:
            check true
        check true == pathname.isSymlink()
        pathname.removeSymlink()


    test "#removeDirectoryTree() should NOT delete a named pipe":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE")).createPipeFile()
        check true == pathname.isPipeFile()
        try:
            pathname.removeDirectoryTree()
            fail()
        except IOError:
            check true
        check true == pathname.isPipeFile()
        pathname.removePipeFile()


    test "#removeDirectoryTree() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_DIRECTORY_TREE"))
        let pathname2: Pathname = pathname.removeDirectoryTree()
        check pathname2 == pathname



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createSymlinkTo()/removeSymlink()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createSymlinkTo() should create a symlink":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_TO")).removeSymlink()
        check false == pathname.isExisting()
        pathname.createSymlinkTo("NOT_EXISTING")
        check true == pathname.isSymlink()
        pathname.removeSymlink()


    test "#createSymlinkTo() should NOT allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_TO")).removeSymlink()
        check false == pathname.isExisting()
        pathname.createSymlinkTo("NOT_EXISTING")
        check true == pathname.isSymlink()
        try:
            pathname.createSymlinkTo("NOT_EXISTING")
            fail()
        except IOError:
            check true
        pathname.removeSymlink()


    test "#createSymlinkTo() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_TO")).removeSymlink()
        let pathname2: Pathname = pathname.createSymlinkTo("NOT_EXISTING")
        check pathname2 == pathname
        pathname.removeSymlink()


    test "#createSymlinkFrom() should create a symlink":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        let pathnameSymlink = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_FROM")).removeSymlink()
        check false == pathnameSymlink.isExisting()
        pathname.createSymlinkFrom(fixturePath("TEST_CREATE_SYMLINK_FROM"))
        check true == pathnameSymlink.isSymlink()
        pathnameSymlink.removeSymlink()


    test "#createSymlinkFrom() should NOT allow multiple calls":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        let pathnameSymlink = Pathname.new(fixturePath("TEST_CREATE_SYMLINK_FROM")).removeSymlink()
        check false == pathnameSymlink.isExisting()
        pathname.createSymlinkFrom(fixturePath("TEST_CREATE_SYMLINK_FROM"))
        check true == pathnameSymlink.isSymlink()
        try:
            pathname.createSymlinkFrom("NOT_EXISTING")
            fail()
        except IOError:
            check true
        pathnameSymlink.removeSymlink()


    test "#createSymlinkFrom() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        let pathname2: Pathname = pathname.createSymlinkFrom(fixturePath("TEST_CREATE_SYMLINK_FROM"))
        check pathname2 == pathname
        Pathname.new(fixturePath("TEST_CREATE_SYMLINK_FROM")).removeSymlink()


    test "#removeSymlink() should delete a pipe file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK_WITH_PIPE")).removeSymlink().createSymlinkTo("NOT_EXISTING")
        check true == pathname.isSymlink()
        pathname.removeSymlink()
        check false == pathname.isExisting()


    test "#removeSymlink() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        check false == pathname.isExisting()
        pathname.removeSymlink()
        pathname.removeSymlink()
        check false == pathname.isExisting()


    test "#removeSymlink() should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK_WITH_REGULAR_FILE")).createRegularFile()
        check true == pathname.isRegularFile()
        try:
            pathname.removeSymlink()
            fail()
        except IOError:
            check true
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#removeSymlink() should NOT delete a directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK_WITH_DIRECTORY")).createEmptyDirectory()
        check true == pathname.isDirectory()
        try:
            pathname.removeSymlink()
            fail()
        except IOError:
            check true
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


    test "#removeSymlink() should NOT delete a pipe/fifo":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK_WITH_SYMLINK")).createPipeFile()
        check true == pathname.isPipeFile()
        try:
            pathname.removeSymlink()
            fail()
        except IOError:
            check true
        check true == pathname.isPipeFile()
        pathname.removePipeFile()


    test "#removeSymlink() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_SYMLINK")).removeSymlink().createSymlinkTo("NOT_EXISTING")
        let pathname2: Pathname = pathname.removeSymlink()
        check pathname2 == pathname



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createPipeFile()/removePipeFile()
#-----------------------------------------------------------------------------------------------------------------------


    test "#createPipeFile() should create a named pipe":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_PIPE_FILE")).removePipeFile()
        check false == pathname.isExisting()
        pathname.createPipeFile()
        check true == pathname.isPipeFile()
        pathname.removePipeFile()


    test "#createPipeFile() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_PIPE_FILE")).removePipeFile()
        check false == pathname.isExisting()
        pathname.createPipeFile()
        check true == pathname.isPipeFile()
        pathname.createPipeFile()
        check true == pathname.isPipeFile()
        pathname.removePipeFile()


    test "#createPipeFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_PIPE_FILE")).removePipeFile()
        let pathname2: Pathname = pathname.createPipeFile()
        check pathname2 == pathname
        pathname.removePipeFile()


    test "#removePipeFile() should delete a pipe file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_PIPE")).createPipeFile()
        check true == pathname.isPipeFile()
        pathname.removePipeFile()
        check false == pathname.isExisting()


    test "#removePipeFile() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        check false == pathname.isExisting()
        pathname.removePipeFile()
        pathname.removePipeFile()
        check false == pathname.isExisting()


    test "#removePipeFile() should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_REGULAR")).createRegularFile()
        check true == pathname.isRegularFile()
        try:
            pathname.removePipeFile()
            fail()
        except IOError:
            check true
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#removePipeFile() should NOT delete a directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_DIRECTORY")).createEmptyDirectory()
        check true == pathname.isDirectory()
        try:
            pathname.removePipeFile()
            fail()
        except IOError:
            check true
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


    test "#removePipeFile() should NOT delete a symlink":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_WITH_SYMLINK")).removeSymlink().createSymlinkTo("NOT_EXISTING")
        check true == pathname.isSymlink()
        try:
            pathname.removePipeFile()
            fail()
        except IOError:
            check true
        check true == pathname.isSymlink()
        pathname.removeSymlink()


    test "#removePipeFile() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_PIPE"))
        let pathname2: Pathname = pathname.removePipeFile()
        check pathname2 == pathname


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - createFifo()/removeFifo() (alias for createPipeFile()/removePipeFile())
#-----------------------------------------------------------------------------------------------------------------------


    test "#createFifo() should create a named pipe":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_PIPE_FILE")).removePipeFile()
        check false == pathname.isExisting()
        pathname.createFifo()
        check true == pathname.isPipeFile()
        pathname.removePipeFile()


    test "#createFifo() should allow multiple calls":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_PIPE_FILE")).removePipeFile()
        check false == pathname.isExisting()
        pathname.createFifo()
        check true == pathname.isPipeFile()
        pathname.createFifo()
        check true == pathname.isPipeFile()
        pathname.removePipeFile()


    test "#createFifo() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_CREATE_PIPE_FILE")).removePipeFile()
        let pathname2: Pathname = pathname.createFifo()
        check pathname2 == pathname
        pathname.removePipeFile()


    test "#removeFifo() should delete a pipe file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_PIPE")).createFifo()
        check true == pathname.isPipeFile()
        pathname.removeFifo()
        check false == pathname.isExisting()


    test "#removeFifo() should handle deletion of non existing file-entry":
        let pathname = Pathname.new(fixturePath("NOT_EXISTING"))
        check false == pathname.isExisting()
        pathname.removeFifo()
        pathname.removeFifo()
        check false == pathname.isExisting()


    test "#removeFifo() should NOT delete a regular file":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_REGULAR")).createRegularFile()
        check true == pathname.isRegularFile()
        try:
            pathname.removeFifo()
            fail()
        except IOError:
            check true
        check true == pathname.isRegularFile()
        pathname.removeRegularFile()


    test "#removeFifo() should NOT delete a directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_DIRECTORY")).createEmptyDirectory()
        check true == pathname.isDirectory()
        try:
            pathname.removeFifo()
            fail()
        except IOError:
            check true
        check true == pathname.isDirectory()
        pathname.removeEmptyDirectory()


    test "#removeFifo() should NOT delete a symlink":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_WITH_SYMLINK")).removeSymlink().createSymlinkTo("NOT_EXISTING")
        check true == pathname.isSymlink()
        try:
            pathname.removeFifo()
            fail()
        except IOError:
            check true
        check true == pathname.isSymlink()
        pathname.removeSymlink()


    test "#removeFifo() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_PIPE_FILE_PIPE"))
        let pathname2: Pathname = pathname.removeFifo()
        check pathname2 == pathname



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
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_REGULAR_FILE")).createRegularFile()
        check true == pathname.isRegularFile()
        pathname.remove()
        check false == pathname.isExisting()


    test "#remove() should delete an empty directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_EMPTY_DIRECTORY")).createEmptyDirectory()
        check true == pathname.isDirectory()
        pathname.remove()
        check false == pathname.isExisting()


    test "#remove() should delete a full directory":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_FULL_DIRECTORY")).createEmptyDirectory()
        check true == pathname.isDirectory()
        let pathname2 = pathname.join("A_FILE").createRegularFile()
        check true == pathname2.isRegularFile()
        pathname.remove()
        check false == pathname.isExisting()


    test "#remove() should delete a symlink":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_SYMLINK")).removeSymlink().createSymlinkTo("NOT_EXISTING")
        check true == pathname.isSymlink()
        pathname.remove()
        check false == pathname.isExisting()


    test "#remove() should delete a pipe/fifo":
        let pathname = Pathname.new(fixturePath("TEST_REMOVE_WITH_PIPE")).createPipeFile()
        check true == pathname.isPipeFile()
        pathname.remove()
        check false == pathname.isExisting()
