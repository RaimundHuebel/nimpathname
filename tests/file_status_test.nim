###
# Test for FileStatus of Pathname-Module in Nim.
#
# Run Tests:
# ----------
#     $ nim compile --run tests/file_status_test
#
# :Author: Raimund Hübel <raimund.huebel@googlemail.com>
###


import pathname/file_status

import times
import posix
import unittest
import test_helper


suite "FileStatus - Tests":


    test "FileStatus is defined":
        check compiles(FileStatus)
        check compiles(file_status.FileStatus)


    test "FileStatus.fromPathStr()":
        let fileStatus1: FileStatus = FileStatus.fromPathStr("/")
        check FileType.DIRECTORY == fileStatus1.getFileType()

        let fileStatus2: FileStatus = FileStatus.fromPathStr(fixturePath("sample_dir/a_file"))
        check FileType.REGULAR_FILE == fileStatus2.getFileType()



    test "#getPathStr()":
        check fixturePath("sample_dir/a_file") == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).getPathStr()
        check fixturePath("sample_dir/a_dir")  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).getPathStr()



    test "#getFileType()":
        check FileType.REGULAR_FILE == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).getFileType()

        check FileType.DIRECTORY == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir")).getFileType()

        check FileType.SYMLINK      == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file")).getFileType()
        check FileType.NOT_EXISTING == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file/")).getFileType()

        check FileType.SYMLINK   == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir" )).getFileType()
        check FileType.DIRECTORY == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir/")).getFileType()

        check FileType.CHARACTER_DEVICE == FileStatus.fromPathStr("/dev/null" ).getFileType()

        check FileType.BLOCK_DEVICE == FileStatus.fromPathStr("/dev/loop0" ).getFileType()

        check FileType.NOT_EXISTING == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE" )).getFileType()
        check FileType.NOT_EXISTING == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE/")).getFileType()

        check FileType.SOCKET_FILE == FileStatus.fromPathStr("/tmp/.X11-unix/X0").getFileType()

        discard posix.mkfifo( fixturePath("sample_dir/a_pipe"), 0o600)
        check FileType.PIPE_FILE == FileStatus.fromPathStr(fixturePath("sample_dir/a_pipe")).getFileType()
        discard posix.unlink( fixturePath("sample_dir/a_pipe") )



    test "#getFileSizeInBytes()":
        check 0 == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).getFileSizeInBytes()
        check 4096 == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir")).getFileSizeInBytes()
        ## When needs update -> change to a file with fixed file size ...
        check 122 == FileStatus.fromPathStr(fixturePath("README.md")).getFileSizeInBytes()



    test "#getUserId()":
        check 0    == FileStatus.fromPathStr("/").getUserId()
        check 1000 == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).getUserId()



    test "#getGroupId()":
        check 0    == FileStatus.fromPathStr("/").getGroupId()
        check 1000 == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).getGroupId()



    test "#fileStatus - getCountHardlinks()":
        check 1 == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).getCountHardlinks()



    test "FileStatus - isExisting() with regular files":
        check true == FileStatus.fromPathStr(fixturePath("README.md"  )).isExisting()

        check true == FileStatus.fromPathStr(fixturePath("sample_dir"  )).isExisting()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/" )).isExisting()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir//")).isExisting()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file"  )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file/" )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file//")).isExisting()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2"  )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2/" )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2//")).isExisting()

        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE"  )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE/" )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE//")).isExisting()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir//NON_EXISTING_FILE"  )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir//NON_EXISTING_FILE/" )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir//NON_EXISTING_FILE//")).isExisting()

        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR//NON_EXISTING_FILE"  )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR//NON_EXISTING_FILE/" )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR//NON_EXISTING_FILE//")).isExisting()

        check false == FileStatus.fromPathStr("/NON_EXISTING_FILE"  ).isExisting()
        check false == FileStatus.fromPathStr("/NON_EXISTING_FILE/" ).isExisting()
        check false == FileStatus.fromPathStr("/NON_EXISTING_FILE//").isExisting()



    test "FileStatus - isExisting() with directories":
        check true == FileStatus.fromPathStr(fixturePath("sample_dir"  )).isExisting()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/" )).isExisting()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir//")).isExisting()

        check true == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir"  )).isExisting()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir/" )).isExisting()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir//")).isExisting()

        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR"  )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR/" )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR//")).isExisting()

        check false == FileStatus.fromPathStr("/NON_EXISTING_DIR"  ).isExisting()
        check false == FileStatus.fromPathStr("/NON_EXISTING_DIR/" ).isExisting()
        check false == FileStatus.fromPathStr("/NON_EXISTING_DIR//").isExisting()



    test "FileStatus - isExisting() with device-files":
        check true == FileStatus.fromPathStr("/dev/null"   ).isExisting()
        check true == FileStatus.fromPathStr("/dev/zero"   ).isExisting()
        check true == FileStatus.fromPathStr("/dev/random" ).isExisting()
        check true == FileStatus.fromPathStr("/dev/urandom").isExisting()

        check true == FileStatus.fromPathStr("/dev/loop0").isExisting()
        check true == FileStatus.fromPathStr("/dev/loop1").isExisting()

        check false == FileStatus.fromPathStr("/dev/NON_EXISTING_FILE" ).isExisting()
        check false == FileStatus.fromPathStr("/dev/NON_EXISTING_DIR/" ).isExisting()
        check false == FileStatus.fromPathStr("/dev/NON_EXISTING_DIR//").isExisting()



    test "FileStatus - isExisting() with symlink-files":
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink"  )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink/" )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink//")).isExisting()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file"  )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file/" )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file//")).isExisting()

        check true == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir"  )).isExisting()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir/" )).isExisting()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir//")).isExisting()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device"  )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device/" )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device//")).isExisting()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid"  )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid/" )).isExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid//")).isExisting()

        check false == FileStatus.fromPathStr("/dev/NON_EXISTING_SYMLINK" ).isExisting()



    test "#isNotExisting()":
        check false == FileStatus.fromPathStr(fixturePath("README.md")).isNotExisting()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir"  )).isNotExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/" )).isNotExisting()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir//")).isNotExisting()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file"  )).isNotExisting()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file/" )).isNotExisting()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file//")).isNotExisting()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2"  )).isNotExisting()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2/" )).isNotExisting()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2//")).isNotExisting()

        check true == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE"  )).isNotExisting()
        check true == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE/" )).isNotExisting()
        check true == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE//")).isNotExisting()

        check true == FileStatus.fromPathStr(fixturePath("sample_dir//NON_EXISTING_FILE"  )).isNotExisting()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir//NON_EXISTING_FILE/" )).isNotExisting()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir//NON_EXISTING_FILE//")).isNotExisting()

        check true == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR//NON_EXISTING_FILE"  )).isNotExisting()
        check true == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR//NON_EXISTING_FILE/" )).isNotExisting()
        check true == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR//NON_EXISTING_FILE//")).isNotExisting()

        check true == FileStatus.fromPathStr("/NON_EXISTING_FILE"  ).isNotExisting()
        check true == FileStatus.fromPathStr("/NON_EXISTING_FILE/" ).isNotExisting()
        check true == FileStatus.fromPathStr("/NON_EXISTING_FILE//").isNotExisting()

        check false == FileStatus.fromPathStr("/tmp/.X11-unix/X0").isNotExisting()



    test "#isUnknownFileType()":
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file"  )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file/" )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file//")).isUnknownFileType()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir"  )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/" )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir//")).isUnknownFileType()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir"  )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir/" )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir//")).isUnknownFileType()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2"  )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2/" )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2//")).isUnknownFileType()

        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE"  )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE/" )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE//")).isUnknownFileType()

        check false == FileStatus.fromPathStr("/dev/null").isUnknownFileType()
        check false == FileStatus.fromPathStr("/dev/zero").isUnknownFileType()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file"  )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file/" )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file//")).isUnknownFileType()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir"  )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir/" )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir//")).isUnknownFileType()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device"  )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device/" )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device//")).isUnknownFileType()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid"  )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid/" )).isUnknownFileType()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid//")).isUnknownFileType()

        check false == FileStatus.fromPathStr("/tmp/.X11-unix/X0").isUnknownFileType()



    test "#isRegularFile()":
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file"  )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file/" )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file//")).isRegularFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir"  )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/" )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir//")).isRegularFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir"  )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir/" )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir//")).isRegularFile()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2"  )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2/" )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2//")).isRegularFile()

        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE"  )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE/" )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE//")).isRegularFile()

        check false == FileStatus.fromPathStr("/dev/null").isRegularFile()
        check false == FileStatus.fromPathStr("/dev/zero").isRegularFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file"  )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file/" )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file//")).isRegularFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir"  )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir/" )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir//")).isRegularFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device"  )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device/" )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device//")).isRegularFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid"  )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid/" )).isRegularFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid//")).isRegularFile()

        check false == FileStatus.fromPathStr("/tmp/.X11-unix/X0").isRegularFile()



    test "#isDirectory()":
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir"  )).isDirectory()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/" )).isDirectory()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir//")).isDirectory()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir"  )).isDirectory()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir/" )).isDirectory()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir//")).isDirectory()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file"  )).isDirectory()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file/" )).isDirectory()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file//")).isDirectory()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2"  )).isDirectory()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2/" )).isDirectory()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2//")).isDirectory()

        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR"  )).isDirectory()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR/" )).isDirectory()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR//")).isDirectory()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file"  )).isDirectory()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file/" )).isDirectory()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file//")).isDirectory()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir"  )).isDirectory()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir/" )).isDirectory()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir//")).isDirectory()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device"  )).isDirectory()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device/" )).isDirectory()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device//")).isDirectory()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid"  )).isDirectory()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid/" )).isDirectory()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid//")).isDirectory()

        check false == FileStatus.fromPathStr("/tmp/.X11-unix/X0").isDirectory()



    test "#isSymlink()":
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink"  )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink/" )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink//")).isSymlink()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file"  )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file/" )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file//")).isSymlink()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir"  )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir/" )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir//")).isSymlink()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device"  )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device/" )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device//")).isSymlink()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_char_device"  )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_char_device/" )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_char_device//")).isSymlink()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_block_device"  )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_block_device/" )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_block_device//")).isSymlink()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid"  )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid/" )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid//")).isSymlink()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir"  )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/" )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir//")).isSymlink()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir"  )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir/" )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir//")).isSymlink()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file"  )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file/" )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file//")).isSymlink()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2"  )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2/" )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2//")).isSymlink()

        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR"  )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR/" )).isSymlink()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_DIR//")).isSymlink()

        check false == FileStatus.fromPathStr("/tmp/.X11-unix/X0").isSymlink()



    test "#isDeviceFile()":
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/"      )).isDeviceFile()

        check true == FileStatus.fromPathStr("/dev/null"   ).isDeviceFile()
        check true == FileStatus.fromPathStr("/dev/zero"   ).isDeviceFile()
        check true == FileStatus.fromPathStr("/dev/random" ).isDeviceFile()
        check true == FileStatus.fromPathStr("/dev/urandom").isDeviceFile()

        check true == FileStatus.fromPathStr("/dev/loop0").isDeviceFile()
        check true == FileStatus.fromPathStr("/dev/loop1").isDeviceFile()

        check false == FileStatus.fromPathStr("/dev/NON_EXISTING"  ).isDeviceFile()
        check false == FileStatus.fromPathStr("/dev/NON_EXISTING/" ).isDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file"  )).isDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file/" )).isDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir"  )).isDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir/" )).isDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device"  )).isDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device/" )).isDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_char_device"  )).isDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_char_device/" )).isDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_block_device"  )).isDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_block_device/" )).isDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid"  )).isDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid/" )).isDeviceFile()

        check false == FileStatus.fromPathStr("/tmp/.X11-unix/X0").isDeviceFile()



    test "#isCharacterDeviceFile()":
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isCharacterDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/"      )).isCharacterDeviceFile()

        check true == FileStatus.fromPathStr("/dev/null"   ).isCharacterDeviceFile()
        check true == FileStatus.fromPathStr("/dev/zero"   ).isCharacterDeviceFile()
        check true == FileStatus.fromPathStr("/dev/random" ).isCharacterDeviceFile()
        check true == FileStatus.fromPathStr("/dev/urandom").isCharacterDeviceFile()

        check false == FileStatus.fromPathStr("/dev/loop0").isCharacterDeviceFile()
        check false == FileStatus.fromPathStr("/dev/loop1").isCharacterDeviceFile()

        check false == FileStatus.fromPathStr("/dev/NON_EXISTING"  ).isCharacterDeviceFile()
        check false == FileStatus.fromPathStr("/dev/NON_EXISTING/" ).isCharacterDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file"  )).isCharacterDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file/" )).isCharacterDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir"  )).isCharacterDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir/" )).isCharacterDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device"  )).isCharacterDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device/" )).isCharacterDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_char_device"  )).isCharacterDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_char_device/" )).isCharacterDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_block_device"  )).isCharacterDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_block_device/" )).isCharacterDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid"  )).isCharacterDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid/" )).isCharacterDeviceFile()

        check false == FileStatus.fromPathStr("/tmp/.X11-unix/X0").isCharacterDeviceFile()



    test "#isBlockDeviceFile()":
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isBlockDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/"      )).isBlockDeviceFile()

        check false == FileStatus.fromPathStr("/dev/null"   ).isBlockDeviceFile()
        check false == FileStatus.fromPathStr("/dev/zero"   ).isBlockDeviceFile()
        check false == FileStatus.fromPathStr("/dev/random" ).isBlockDeviceFile()
        check false == FileStatus.fromPathStr("/dev/urandom").isBlockDeviceFile()

        check true == FileStatus.fromPathStr("/dev/loop0").isBlockDeviceFile()
        check true == FileStatus.fromPathStr("/dev/loop1").isBlockDeviceFile()

        check false == FileStatus.fromPathStr("/dev/NON_EXISTING"  ).isBlockDeviceFile()
        check false == FileStatus.fromPathStr("/dev/NON_EXISTING/" ).isBlockDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file"  )).isBlockDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file/" )).isBlockDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir"  )).isBlockDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir/" )).isBlockDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device"  )).isBlockDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device/" )).isBlockDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_char_device"  )).isBlockDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_char_device/" )).isBlockDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_block_device"  )).isBlockDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_block_device/" )).isBlockDeviceFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid"  )).isBlockDeviceFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid/" )).isBlockDeviceFile()

        check false == FileStatus.fromPathStr("/tmp/.X11-unix/X0").isBlockDeviceFile()



    test "#isSocketFile()":
        check true == FileStatus.fromPathStr("/tmp/.X11-unix/X0").isSocketFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file"  )).isSocketFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file/" )).isSocketFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir"  )).isSocketFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/" )).isSocketFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir"  )).isSocketFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir/" )).isSocketFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2"  )).isSocketFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2/" )).isSocketFile()

        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE"  )).isSocketFile()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE/" )).isSocketFile()

        check false == FileStatus.fromPathStr("/dev/null").isSocketFile()
        check false == FileStatus.fromPathStr("/dev/zero").isSocketFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file"  )).isSocketFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file/" )).isSocketFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir"  )).isSocketFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir/" )).isSocketFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device"  )).isSocketFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device/" )).isSocketFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid"  )).isSocketFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid/" )).isSocketFile()



    test "#isPipeFile()":
        discard posix.mkfifo( fixturePath("sample_dir/a_pipe"), 0o600)
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/a_pipe")).isPipeFile()
        discard posix.unlink( fixturePath("sample_dir/a_pipe") )

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file" )).isPipeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file/")).isPipeFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir"  )).isPipeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/" )).isPipeFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir"  )).isPipeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir/" )).isPipeFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2"  )).isPipeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2/" )).isPipeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2//")).isPipeFile()

        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE"  )).isPipeFile()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE/" )).isPipeFile()

        check false == FileStatus.fromPathStr("/dev/null").isPipeFile()
        check false == FileStatus.fromPathStr("/dev/zero").isPipeFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file"  )).isPipeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file/" )).isPipeFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir"  )).isPipeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir/" )).isPipeFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device"  )).isPipeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device/" )).isPipeFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid"  )).isPipeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid/" )).isPipeFile()

        check false == FileStatus.fromPathStr("/tmp/.X11-unix/X0").isPipeFile()



    test "#isHidden()":
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/.a_hidden_file")).isHidden()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/.a_hidden_dir")).isHidden()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/.a_hidden_dir/.keep")).isHidden()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isHidden()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir")).isHidden()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/NOT_EXISTING")).isHidden()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/.NOT_EXISTING")).isHidden()



    test "#isVisible()":
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isVisible()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir")).isVisible()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/.a_hidden_file")).isVisible()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/.a_hidden_dir")).isVisible()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/.a_hidden_dir/.keep")).isVisible()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/NOT_EXISTING")).isVisible()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/.NOT_EXISTING")).isVisible()



    test "#isZeroSizeFile()":
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file" )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file/")).isZeroSizeFile()

        check false == FileStatus.fromPathStr(fixturePath("README.md")).isZeroSizeFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir"  )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/" )).isZeroSizeFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir"  )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir/" )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir//")).isZeroSizeFile()

        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2"  )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2/" )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file.no2//")).isZeroSizeFile()

        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE"  )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE/" )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("NON_EXISTING_FILE//")).isZeroSizeFile()

        check false == FileStatus.fromPathStr("/dev/null").isZeroSizeFile()
        check false == FileStatus.fromPathStr("/dev/zero").isZeroSizeFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file"  )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file/" )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_file//")).isZeroSizeFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir"  )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir/" )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_dir//")).isZeroSizeFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device"  )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device/" )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_to_device//")).isZeroSizeFile()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid"  )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid/" )).isZeroSizeFile()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_symlink_invalid//")).isZeroSizeFile()



    test "#hasSetUidBit()":
        check true == FileStatus.fromPathStr("/bin/su").hasSetUidBit()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file" )).hasSetUidBit()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir"  )).hasSetUidBit()



    test "#hasSetGidBit()":
        check true == FileStatus.fromPathStr("/usr/bin/wall").hasSetGidBit()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file" )).hasSetGidBit()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir"  )).hasSetGidBit()



    test "#hasStickyBit()":
        check true == FileStatus.fromPathStr("/tmp").hasStickyBit()

        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file" )).hasStickyBit()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir"  )).hasStickyBit()



    test "#getLastAccessTime()":
        let maxTime = times.getTime()
        let minTime = times.parse("2020-01-13", "yyyy-MM-dd").toTime()

        check maxTime >= minTime

        check maxTime >= FileStatus.fromPathStr(fixturePath("sample_dir/a_file" )).getLastAccessTime()
        check minTime <= FileStatus.fromPathStr(fixturePath("sample_dir/a_file" )).getLastAccessTime()

        check maxTime >= FileStatus.fromPathStr(fixturePath("sample_dir/a_dir")).getLastAccessTime()
        check minTime <= FileStatus.fromPathStr(fixturePath("sample_dir/a_dir")).getLastAccessTime()



    test "#getLastChangeTime()":
        let maxTime = times.getTime()
        let minTime = times.parse("2020-01-13", "yyyy-MM-dd").toTime()

        check maxTime >= minTime

        check maxTime >= FileStatus.fromPathStr(fixturePath("sample_dir/a_file" )).getLastChangeTime()
        check minTime <= FileStatus.fromPathStr(fixturePath("sample_dir/a_file" )).getLastChangeTime()

        check maxTime >= FileStatus.fromPathStr(fixturePath("sample_dir/a_dir")).getLastChangeTime()
        check minTime <= FileStatus.fromPathStr(fixturePath("sample_dir/a_dir")).getLastChangeTime()



    test "#getLastStatusChangeTime()":
        let maxTime = times.getTime()
        let minTime = times.parse("2020-01-13", "yyyy-MM-dd").toTime()

        check maxTime >= minTime

        check maxTime >= FileStatus.fromPathStr(fixturePath("sample_dir/a_file" )).getLastStatusChangeTime()
        check minTime <= FileStatus.fromPathStr(fixturePath("sample_dir/a_file" )).getLastStatusChangeTime()

        check maxTime >= FileStatus.fromPathStr(fixturePath("sample_dir/a_dir")).getLastStatusChangeTime()
        check minTime <= FileStatus.fromPathStr(fixturePath("sample_dir/a_dir")).getLastStatusChangeTime()



    test "#isUserOwned()":
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isUserOwned()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isUserOwned()

        check false == FileStatus.fromPathStr("/"   ).isUserOwned()
        check false == FileStatus.fromPathStr("/tmp").isUserOwned()



    test "#isGroupOwned()":
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isGroupOwned()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isGroupOwned()

        check false == FileStatus.fromPathStr("/"   ).isGroupOwned()
        check false == FileStatus.fromPathStr("/tmp").isGroupOwned()



    test "#isGroupMember()":
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isGroupMember()
        check true == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isGroupMember()

        check false == FileStatus.fromPathStr("/"   ).isGroupMember()
        check false == FileStatus.fromPathStr("/tmp").isGroupMember()



    test "#isReadable()":
        check false == FileStatus.fromPathStr("/var/log/syslog"               ).isReadable()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isReadable()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isReadable()



    test "#isReadableByUser()":
        check false == FileStatus.fromPathStr("/var/log/syslog"               ).isReadableByUser()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isReadableByUser()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isReadableByUser()



    test "#isReadableByGroup()":
        check false == FileStatus.fromPathStr("/var/log/syslog"               ).isReadableByGroup()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isReadableByGroup()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isReadableByGroup()



    test "#isReadableByOther()":
        check false == FileStatus.fromPathStr("/var/log/syslog"               ).isReadableByOther()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isReadableByOther()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isReadableByOther()



    test "#isWritable()":
        check false == FileStatus.fromPathStr("/var/log/syslog"               ).isWritable()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isWritable()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isWritable()



    test "#isWritableByUser()":
        check false == FileStatus.fromPathStr("/var/log/syslog"               ).isWritableByUser()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isWritableByUser()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isWritableByUser()



    test "#isWritableByGroup()":
        check false == FileStatus.fromPathStr("/var/log/syslog"               ).isWritableByGroup()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isWritableByGroup()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isWritableByGroup()



    test "#isWritableByOther()":
        check false == FileStatus.fromPathStr("/var/log/syslog"               ).isWritableByOther()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isWritableByOther()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isWritableByOther()



    test "#isExecutable()":
        check true  == FileStatus.fromPathStr("/bin/cat"                      ).isExecutable()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isExecutable()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isExecutable()



    test "#isExecutableByUser()":
        check false == FileStatus.fromPathStr("/bin/cat"                      ).isExecutableByUser()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isExecutableByUser()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isExecutableByUser()



    test "#isExecutableByGroup()":
        check false == FileStatus.fromPathStr("/bin/cat"                      ).isExecutableByGroup()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isExecutableByGroup()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isExecutableByGroup()



    test "#isExecutableByOther()":
        check true  == FileStatus.fromPathStr("/bin/cat"                      ).isExecutableByOther()
        check false == FileStatus.fromPathStr(fixturePath("sample_dir/a_file")).isExecutableByOther()
        check true  == FileStatus.fromPathStr(fixturePath("sample_dir/a_dir" )).isExecutableByOther()
