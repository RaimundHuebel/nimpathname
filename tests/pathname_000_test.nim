###
# Test for Pathname-Module in Nim.
#
# Run Tests:
# ----------
#     $ nim compile --run tests/pathname_000_test
#
# :Author: Raimund Hübel <raimund.huebel@googlemail.com>
###


import pathname

import os
import times
import options
import unittest
import test_helper

when defined(Posix):
    import posix


suite "Pathname Tests 000":


    test "Pathname is defined":
        check compiles(Pathname)


    test "Pathname.new(path)":
        let aPathname: Pathname = Pathname.new("hello")
        check "hello" == aPathname.toPathStr()

        # Common
        check ""          == Pathname.new(""   ).toPathStr()
        check " "         == Pathname.new(" "  ).toPathStr()
        check "abc"       == Pathname.new("abc").toPathStr()

        # Posix
        check "abc"       == Pathname.new("abc"     ).toPathStr()
        check "cde/"      == Pathname.new("cde/"    ).toPathStr()
        check "cde/fgh"   == Pathname.new("cde/fgh" ).toPathStr()
        check "cde/fgh/"  == Pathname.new("cde/fgh/").toPathStr()
        check "/"         == Pathname.new("/"       ).toPathStr()
        check "/abc"      == Pathname.new("/abc"    ).toPathStr()
        check "/abc/"     == Pathname.new("/abc/"   ).toPathStr()

        # Windows
        check "abc"        == Pathname.new("abc"       ).toPathStr()
        check "cde\\"      == Pathname.new("cde\\"     ).toPathStr()
        check "cde\\fgh"   == Pathname.new("cde\\fgh"  ).toPathStr()
        check "cde\\fgh\\" == Pathname.new("cde\\fgh\\").toPathStr()
        check "C:"         == Pathname.new("C:"        ).toPathStr()
        check "C:\\"       == Pathname.new("C:\\"      ).toPathStr()
        check "C:\\abc"    == Pathname.new("C:\\abc"   ).toPathStr()
        check "C:\\abc\\"  == Pathname.new("C:\\abc\\" ).toPathStr()


    test "Pathname.new(base, pc1)":
        # Alle Plattformen
        when true:
            check "a"               == Pathname.new("a").toPathStr()
            check "a" / "b"         == Pathname.new("a", "b").toPathStr()
            check "hello" / "world" == Pathname.new("hello", "world").toPathStr()

        when defined(Posix):
            check "a/b"  == Pathname.new("a", "b"    ).toPathStr()
            check "a/b"  == Pathname.new("a/", "/b/" ).toPathStr()
            check "/a/b" == Pathname.new("/a", "b"   ).toPathStr()
            check "/a/b" == Pathname.new("/a/", "/b/").toPathStr()

            check "a/b/c"  == Pathname.new("a", "b", "c"      ).toPathStr()
            check "a/b/c"  == Pathname.new("a/", "/b/", "/c/" ).toPathStr()
            check "/a/b/c" == Pathname.new("/a", "b", "c"     ).toPathStr()
            check "/a/b/c" == Pathname.new("/a/", "/b/", "/c/").toPathStr()

        when defined(Windows):
            check "a\\b"     == Pathname.new("a", "b"        ).toPathStr()
            check "a\\b"     == Pathname.new("a\\", "\\b\\"  ).toPathStr()
            check "C:\\a\\b" == Pathname.new("C:\\a", "b"      ).toPathStr()
            check "C:\\a\\b" == Pathname.new("C:\\a\\", "\\b\\").toPathStr()

            check "a\\b\\c"     == Pathname.new("a", "b", "c"            ).toPathStr()
            check "a\\b\\c"     == Pathname.new("a\\", "\\b\\", "\\c\\"  ).toPathStr()
            check "C:\\a\\b\\c" == Pathname.new("C:\\a", "b", "c"          ).toPathStr()
            check "C:\\a\\b\\c" == Pathname.new("C:\\a\\", "\\b\\", "\\c\\").toPathStr()


    test "Pathname.fromPathStr(path)":
        let aPathname: Pathname = Pathname.fromPathStr("hello")
        check "hello" == aPathname.toPathStr()

        # Common
        check ""          == Pathname.fromPathStr(""   ).toPathStr()
        check " "         == Pathname.fromPathStr(" "  ).toPathStr()
        check "abc"       == Pathname.fromPathStr("abc").toPathStr()

        # Posix
        check "abc"       == Pathname.fromPathStr("abc"     ).toPathStr()
        check "cde/"      == Pathname.fromPathStr("cde/"    ).toPathStr()
        check "cde/fgh"   == Pathname.fromPathStr("cde/fgh" ).toPathStr()
        check "cde/fgh/"  == Pathname.fromPathStr("cde/fgh/").toPathStr()
        check "/"         == Pathname.fromPathStr("/"       ).toPathStr()
        check "/abc"      == Pathname.fromPathStr("/abc"    ).toPathStr()
        check "/abc/"     == Pathname.fromPathStr("/abc/"   ).toPathStr()

        # Windows
        check "abc"        == Pathname.fromPathStr("abc"       ).toPathStr()
        check "cde\\"      == Pathname.fromPathStr("cde\\"     ).toPathStr()
        check "cde\\fgh"   == Pathname.fromPathStr("cde\\fgh"  ).toPathStr()
        check "cde\\fgh\\" == Pathname.fromPathStr("cde\\fgh\\").toPathStr()
        check "C:"         == Pathname.fromPathStr("C:"        ).toPathStr()
        check "C:\\"       == Pathname.fromPathStr("C:\\"      ).toPathStr()
        check "C:\\abc"    == Pathname.fromPathStr("C:\\abc"   ).toPathStr()
        check "C:\\abc\\"  == Pathname.fromPathStr("C:\\abc\\" ).toPathStr()


    test "Pathname.fromPathStr(base, pc1)":
        # Alle Plattformen
        when true:
            check "a"               == Pathname.fromPathStr("a").toPathStr()
            check "a" / "b"         == Pathname.fromPathStr("a", "b").toPathStr()
            check "hello" / "world" == Pathname.fromPathStr("hello", "world").toPathStr()

        when defined(Posix):
            check "a/b"  == Pathname.fromPathStr("a", "b"    ).toPathStr()
            check "a/b"  == Pathname.fromPathStr("a/", "/b/" ).toPathStr()
            check "/a/b" == Pathname.fromPathStr("/a", "b"   ).toPathStr()
            check "/a/b" == Pathname.fromPathStr("/a/", "/b/").toPathStr()

            check "a/b/c"  == Pathname.fromPathStr("a", "b", "c"      ).toPathStr()
            check "a/b/c"  == Pathname.fromPathStr("a/", "/b/", "/c/" ).toPathStr()
            check "/a/b/c" == Pathname.fromPathStr("/a", "b", "c"     ).toPathStr()
            check "/a/b/c" == Pathname.fromPathStr("/a/", "/b/", "/c/").toPathStr()

        when defined(Windows):
            check "a\\b"     == Pathname.fromPathStr("a", "b"        ).toPathStr()
            check "a\\b"     == Pathname.fromPathStr("a\\", "\\b\\"  ).toPathStr()
            check "C:\\a\\b" == Pathname.fromPathStr("C:\\a", "b"      ).toPathStr()
            check "C:\\a\\b" == Pathname.fromPathStr("C:\\a\\", "\\b\\").toPathStr()

            check "a\\b\\c"     == Pathname.fromPathStr("a", "b", "c"            ).toPathStr()
            check "a\\b\\c"     == Pathname.fromPathStr("a\\", "\\b\\", "\\c\\"  ).toPathStr()
            check "C:\\a\\b\\c" == Pathname.fromPathStr("C:\\a", "b", "c"          ).toPathStr()
            check "C:\\a\\b\\c" == Pathname.fromPathStr("C:\\a\\", "\\b\\", "\\c\\").toPathStr()



    test "Pathname.fromCurrentWorkDir(...)":
        check os.getCurrentDir()             == Pathname.fromCurrentWorkDir().toPathStr()
        check os.getCurrentDir() / "a"       == Pathname.fromCurrentWorkDir("a").toPathStr()
        check os.getCurrentDir() / "a" / "b" == Pathname.fromCurrentWorkDir("a", "b").toPathStr()


    test "Pathname.fromAppDir(...)":
        check os.getAppDir()             == Pathname.fromAppDir().toPathStr()
        check os.getAppDir() / "a"       == Pathname.fromAppDir("a").toPathStr()
        check os.getAppDir() / "a" / "b" == Pathname.fromAppDir("a", "b").toPathStr()


    test "Pathname.fromAppFile(...)":
        check os.getAppFilename() == Pathname.fromAppFile().toPathStr()


    test "Pathname.fromRootDir(...)":
        when defined(Posix):
            check "/"    == Pathname.fromRootDir().toPathStr()
            check "/a"   == Pathname.fromRootDir("a").toPathStr()
            check "/a/b" == Pathname.fromRootDir("a", "b").toPathStr()

        when defined(Windows):
            check "C:"       == Pathname.fromRootDir().toPathStr()
            check "C:\\a"    == Pathname.fromRootDir("a").toPathStr()
            check "C:\\a\\b" == Pathname.fromRootDir("a", "b").toPathStr()


    test "Pathname.fromUserConfigDir()":
        check os.getConfigDir()             == Pathname.fromUserConfigDir().toPathStr()
        check os.getConfigDir() / "a"       == Pathname.fromUserConfigDir("a").toPathStr()
        check os.getConfigDir() / "a" / "b" == Pathname.fromUserConfigDir("a", "b").toPathStr()


    test "Pathname.fromUserHomeDir()":
        check os.getHomeDir()             == Pathname.fromUserHomeDir().toPathStr()
        check os.getHomeDir() / "a"       == Pathname.fromUserHomeDir("a").toPathStr()
        check os.getHomeDir() / "a" / "b" == Pathname.fromUserHomeDir("a", "b").toPathStr()


    test "Pathname.fromEnvVar()":
        block:
            os.delEnv("SAMPLE_PATH_ENV_VAR")
            let noPathname = Pathname.fromEnvVar("SAMPLE_PATH_ENV_VAR")
            check noPathname.isNone()
        block: # Posix
            os.putEnv("SAMPLE_PATH_ENV_VAR", "/tmp/abc/123")
            let somePathname = Pathname.fromEnvVar("SAMPLE_PATH_ENV_VAR")
            check somePathname.isSome()
            check "/tmp/abc/123" == somePathname.get().toPathStr()
        block: # Windows
            os.putEnv("SAMPLE_PATH_ENV_VAR", "C:\\tmp\\abc\\123")
            let somePathname = Pathname.fromEnvVar("SAMPLE_PATH_ENV_VAR")
            check somePathname.isSome()
            check "C:\\tmp\\abc\\123" == somePathname.get().toPathStr()
        block:
            os.delEnv("SAMPLE_PATH_ENV_VAR")
            let noPathname = Pathname.fromEnvVar("SAMPLE_PATH_ENV_VAR")
            check noPathname.isNone()


    test "Pathname.fromEnvVarOrDefault()":
        when true or defined(Posix):
            block:
                os.delEnv("SAMPLE_PATH_ENV_VAR")
                let aPathname: Pathname = Pathname.fromEnvVarOrDefault("SAMPLE_PATH_ENV_VAR", "/opt/fallback")
                check "/opt/fallback" == aPathname.toPathStr()
            block:
                os.putEnv("SAMPLE_PATH_ENV_VAR", "/tmp/abc/123")
                let aPathname: Pathname = Pathname.fromEnvVarOrDefault("SAMPLE_PATH_ENV_VAR", "/opt/fallback")
                check "/tmp/abc/123" == aPathname.toPathStr()
            block:
                os.delEnv("SAMPLE_PATH_ENV_VAR")
                let aPathname: Pathname = Pathname.fromEnvVarOrDefault("SAMPLE_PATH_ENV_VAR", "/opt/fallback")
                check "/opt/fallback" == aPathname.toPathStr()

        when true or defined(Windows):
            block:
                os.delEnv("SAMPLE_PATH_ENV_VAR")
                let aPathname: Pathname = Pathname.fromEnvVarOrDefault("SAMPLE_PATH_ENV_VAR", "C:\\tmp\\fallback")
                check "C:\\tmp\\fallback" == aPathname.toPathStr()
            block:
                os.putEnv("SAMPLE_PATH_ENV_VAR", "/tmp/abc/123")
                let aPathname: Pathname = Pathname.fromEnvVarOrDefault("SAMPLE_PATH_ENV_VAR", "C:\\tmp\\fallback")
                check "/tmp/abc/123" == aPathname.toPathStr()
            block:
                os.delEnv("SAMPLE_PATH_ENV_VAR")
                let aPathname: Pathname = Pathname.fromEnvVarOrDefault("SAMPLE_PATH_ENV_VAR", "C:\\tmp\\fallback")
                check "C:\\tmp\\fallback" == aPathname.toPathStr()


    test "Pathname.fromEnvVarOrNil()":
        block:
            os.delEnv("SAMPLE_PATH_ENV_VAR")
            let noPathname: Pathname = Pathname.fromEnvVarOrNil("SAMPLE_PATH_ENV_VAR")
            check noPathname == nil
        block:
            os.putEnv("SAMPLE_PATH_ENV_VAR", "/tmp/ABC/123")
            let aPathname: Pathname = Pathname.fromEnvVarOrNil("SAMPLE_PATH_ENV_VAR")
            check aPathname != nil
            check "/tmp/ABC/123" == aPathname.toPathStr()
        block:
            os.delEnv("SAMPLE_PATH_ENV_VAR")
            let noPathname: Pathname = Pathname.fromEnvVarOrNil("SAMPLE_PATH_ENV_VAR")
            check noPathname == nil


    test "Pathname.fromNimbleDir()":
        check os.getHomeDir() / ".nimble"                   == Pathname.fromNimbleDir().toPathStr()
        check os.getHomeDir() / ".nimble" / "bin"           == Pathname.fromNimbleDir("bin").toPathStr()
        check os.getHomeDir() / ".nimble" / "bin" / "c2nim" == Pathname.fromNimbleDir("bin", "c2nim").toPathStr()
        check os.getHomeDir() / ".nimble" / "pkgs"          == Pathname.fromNimbleDir("pkgs").toPathStr()
        check os.getHomeDir() / ".nimble" / "pkgs" / "zmq"  == Pathname.fromNimbleDir("pkgs", "zmq").toPathStr()


    test "Internal Pathname-Path is immutable (v1: ctor)":
        var samplePath = "/Test1"
        let aPathname = Pathname.new(samplePath)

        check "/Test1" == samplePath
        check "/Test1" == aPathname.toPathStr()
        check "/Test1" == aPathname.toString()
        check "/Test1" == $aPathname

        samplePath[1] = 'J'
        check "/Jest1" == samplePath
        check "/Test1" == aPathname.toPathStr()
        check "/Test1" == aPathname.toString()
        check "/Test1" == $aPathname


    test "Internal Pathname-Path is immutable (v2: toPathStr)":
        let aPathname = Pathname.new("/Test2")
        var samplePath = aPathname.toPathStr()

        check "/Test2" == samplePath
        check "/Test2" == aPathname.toPathStr()
        check "/Test2" == aPathname.toString()
        check "/Test2" == $aPathname

        samplePath[1] = 'J'
        check "/Jest2" == samplePath
        check "/Test2" == aPathname.toPathStr()
        check "/Test2" == aPathname.toString()
        check "/Test2" == $aPathname


    test "Internal Pathname-Path is immutable (v3: toString)":
        let aPathname = Pathname.new("/Test3")
        var samplePath = aPathname.toString()

        check "/Test3" == samplePath
        check "/Test3" == aPathname.toPathStr()
        check "/Test3" == aPathname.toString()
        check "/Test3" == $aPathname

        samplePath[1] = 'J'
        check "/Jest3" == samplePath
        check "/Test3" == aPathname.toPathStr()
        check "/Test3" == aPathname.toString()
        check "/Test3" == $aPathname


    test "Internal Pathname-Path is immutable (v4: $)":
        let aPathname = Pathname.new("/Test4")
        var samplePath = $aPathname

        check "/Test4" == samplePath
        check "/Test4" == aPathname.toPathStr()
        check "/Test4" == aPathname.toString()
        check "/Test4" == $aPathname

        samplePath[1] = 'J'
        check "/Jest4" == samplePath
        check "/Test4" == aPathname.toPathStr()
        check "/Test4" == aPathname.toString()
        check "/Test4" == $aPathname


    test "#toPathStr()":
        check os.getCurrentDir() == Pathname.fromCurrentWorkDir().toPathStr()

        check ""      == Pathname.new(""     ).toPathStr()
        check " "     == Pathname.new(" "    ).toPathStr()
        check "   "   == Pathname.new("   "  ).toPathStr()
        check "/"     == Pathname.new("/"    ).toPathStr()
        check "/abc"  == Pathname.new("/abc" ).toPathStr()
        check "/abc/" == Pathname.new("/abc/").toPathStr()
        check "abc"   == Pathname.new("abc"  ).toPathStr()
        check "cde/"  == Pathname.new("cde/" ).toPathStr()


    test "#toPathStr() with absolute paths":
        check "/"            == Pathname.new("/"          ).toPathStr()
        check "/a"           == Pathname.new("/a"         ).toPathStr()
        check "/a/"          == Pathname.new("/a/"        ).toPathStr()
        check "/a/b"         == Pathname.new("/a/b"       ).toPathStr()
        check "/a/b/"        == Pathname.new("/a/b/"      ).toPathStr()
        check "/a/b/c"       == Pathname.new("/a/b/c"     ).toPathStr()
        check "/a/b/c/"      == Pathname.new("/a/b/c/"    ).toPathStr()
        check "/a/b/c/ "     == Pathname.new("/a/b/c/ "   ).toPathStr()
        check "/a/b/c/ /"    == Pathname.new("/a/b/c/ /"  ).toPathStr()
        check "/a/b/c/ /d"   == Pathname.new("/a/b/c/ /d" ).toPathStr()
        check "/a/b/c/ /d/"  == Pathname.new("/a/b/c/ /d/").toPathStr()

        check "/."       == Pathname.new("/."      ).toPathStr()
        check "/./"      == Pathname.new("/./"     ).toPathStr()
        check "/./."     == Pathname.new("/./."    ).toPathStr()
        check "/././"    == Pathname.new("/././"   ).toPathStr()
        check "/././."   == Pathname.new("/././."  ).toPathStr()
        check "/./././"  == Pathname.new("/./././" ).toPathStr()
        check "/./././." == Pathname.new("/./././.").toPathStr()

        check "/.."          == Pathname.new("/.."         ).toPathStr()
        check "/../"         == Pathname.new("/../"        ).toPathStr()
        check "/../.."       == Pathname.new("/../.."      ).toPathStr()
        check "/../../"      == Pathname.new("/../../"     ).toPathStr()
        check "/../../.."    == Pathname.new("/../../.."   ).toPathStr()
        check "/../../../"   == Pathname.new("/../../../"  ).toPathStr()
        check "/../../../.." == Pathname.new("/../../../..").toPathStr()


    test "#toPathStr() with relative paths":
        check "" == Pathname.new("").toPathStr()

        check "a"           == Pathname.new("a"         ).toPathStr()
        check "a/"          == Pathname.new("a/"        ).toPathStr()
        check "a/b"         == Pathname.new("a/b"       ).toPathStr()
        check "a/b/"        == Pathname.new("a/b/"      ).toPathStr()
        check "a/b/c"       == Pathname.new("a/b/c"     ).toPathStr()
        check "a/b/c/"      == Pathname.new("a/b/c/"    ).toPathStr()
        check "a/b/c/ "     == Pathname.new("a/b/c/ "   ).toPathStr()
        check "a/b/c/ /"    == Pathname.new("a/b/c/ /"  ).toPathStr()
        check "a/b/c/ /d"   == Pathname.new("a/b/c/ /d" ).toPathStr()
        check "a/b/c/ /d/"  == Pathname.new("a/b/c/ /d/").toPathStr()

        check "."       == Pathname.new("."      ).toPathStr()
        check "./"      == Pathname.new("./"     ).toPathStr()
        check "./."     == Pathname.new("./."    ).toPathStr()
        check "././"    == Pathname.new("././"   ).toPathStr()
        check "././."   == Pathname.new("././."  ).toPathStr()
        check "./././"  == Pathname.new("./././" ).toPathStr()
        check "./././." == Pathname.new("./././.").toPathStr()

        check ".."          == Pathname.new(".."         ).toPathStr()
        check "../"         == Pathname.new("../"        ).toPathStr()
        check "../.."       == Pathname.new("../.."      ).toPathStr()
        check "../../"      == Pathname.new("../../"     ).toPathStr()
        check "../../.."    == Pathname.new("../../.."   ).toPathStr()
        check "../../../"   == Pathname.new("../../../"  ).toPathStr()
        check "../../../.." == Pathname.new("../../../..").toPathStr()


    test "#toString()":
        check os.getCurrentDir() == Pathname.fromCurrentWorkDir().toString()

        check ""      == Pathname.new(""     ).toString()
        check "/"     == Pathname.new("/"    ).toString()
        check "/abc"  == Pathname.new("/abc" ).toString()
        check "/abc/" == Pathname.new("/abc/").toString()
        check "abc"   == Pathname.new("abc"  ).toString()
        check "cde/"  == Pathname.new("cde/" ).toString()


    test "#$":
        check os.getCurrentDir() == $Pathname.fromCurrentWorkDir()

        check ""      == $Pathname.new(""     )
        check "/"     == $Pathname.new("/"    )
        check "/abc"  == $Pathname.new("/abc" )
        check "/abc/" == $Pathname.new("/abc/")
        check "abc"   == $Pathname.new("abc"  )
        check "cde/"  == $Pathname.new("cde/" )


    test "#inspect()":
        check "Pathname(\"\")"      == Pathname.new(""     ).inspect()
        check "Pathname(\"/\")"     == Pathname.new("/"    ).inspect()
        check "Pathname(\"/abc\")"  == Pathname.new("/abc" ).inspect()
        check "Pathname(\"/abc/\")" == Pathname.new("/abc/").inspect()
        check "Pathname(\"abc\")"   == Pathname.new("abc"  ).inspect()
        check "Pathname(\"cde/\")"  == Pathname.new("cde/" ).inspect()



    test "#isAbsolute()":
        when true: # Common
            check false == Pathname.new(""  ).isAbsolute()
            check false == Pathname.new("a" ).isAbsolute()
            check false == Pathname.new("." ).isAbsolute()
            check false == Pathname.new("..").isAbsolute()
            check false == Pathname.new("a/../b/.").isAbsolute()
            check false == Pathname.new("a/./b/..").isAbsolute()

        when defined(Posix):
            check true  == Pathname.new("/"  ).isAbsolute()
            check true  == Pathname.new("/a" ).isAbsolute()
            check true  == Pathname.new("/." ).isAbsolute()
            check true  == Pathname.new("/..").isAbsolute()
            check true  == Pathname.new("/a/../b/.").isAbsolute()
            check true  == Pathname.new("/a/./b/..").isAbsolute()

            check false == Pathname.new("C:\\"  ).isAbsolute()
            check false == Pathname.new("C:\\a" ).isAbsolute()
            check false == Pathname.new("C:\\." ).isAbsolute()
            check false == Pathname.new("C:\\..").isAbsolute()
            check false == Pathname.new("C:\\a\\..\\b\\.").isAbsolute()
            check false == Pathname.new("C:\\a\\.\\b\\..").isAbsolute()

        when defined(Windows):
            check true  == Pathname.new("C:\\"  ).isAbsolute()
            check true  == Pathname.new("D:\\a" ).isAbsolute()
            check true  == Pathname.new("E:\\." ).isAbsolute()
            check true  == Pathname.new("F:\\..").isAbsolute()
            check true  == Pathname.new("G:\\a\\..\\b\\.").isAbsolute()
            check true  == Pathname.new("H:\\a\\.\\b\\..").isAbsolute()

            check false == Pathname.new("/"  ).isAbsolute()
            check false == Pathname.new("/a" ).isAbsolute()
            check false == Pathname.new("/." ).isAbsolute()
            check false == Pathname.new("/..").isAbsolute()
            check false == Pathname.new("/a/../b/.").isAbsolute()
            check false == Pathname.new("/a/./b/..").isAbsolute()



    test "#isRelative()":
        when true: # Common
            check true  == Pathname.new(""  ).isRelative()
            check true  == Pathname.new("a" ).isRelative()
            check true  == Pathname.new("." ).isRelative()
            check true  == Pathname.new("..").isRelative()
            check true  == Pathname.new("a/../b/.").isRelative()
            check true  == Pathname.new("a/./b/..").isRelative()

        when defined(Posix):
            check false  == Pathname.new("/"  ).isRelative()
            check false  == Pathname.new("/a" ).isRelative()
            check false  == Pathname.new("/." ).isRelative()
            check false  == Pathname.new("/..").isRelative()
            check false  == Pathname.new("/a/../b/.").isRelative()
            check false  == Pathname.new("/a/./b/..").isRelative()

            check true  == Pathname.new("C:\\"  ).isRelative()
            check true  == Pathname.new("C:\\a" ).isRelative()
            check true  == Pathname.new("C:\\." ).isRelative()
            check true  == Pathname.new("C:\\..").isRelative()
            check true  == Pathname.new("C:\\a\\..\\b\\.").isRelative()
            check true  == Pathname.new("C:\\a\\.\\b\\..").isRelative()

        when defined(Windows):
            check false  == Pathname.new("C:\\"  ).isRelative()
            check false  == Pathname.new("D:\\a" ).isRelative()
            check false  == Pathname.new("E:\\." ).isRelative()
            check false  == Pathname.new("F:\\..").isRelative()
            check false  == Pathname.new("G:\\a\\..\\b\\.").isRelative()
            check false  == Pathname.new("H:\\a\\.\\b\\..").isRelative()

            check true  == Pathname.new("/"  ).isRelative()
            check true  == Pathname.new("/a" ).isRelative()
            check true  == Pathname.new("/." ).isRelative()
            check true  == Pathname.new("/..").isRelative()
            check true  == Pathname.new("/a/../b/.").isRelative()
            check true  == Pathname.new("/a/./b/..").isRelative()



    test "#parent()":
        when true: # Common
            check "a" / "b"   == Pathname.new("a", "b", "c").parent().toPathStr()
            check "a"         == Pathname.new("a", "b", "c").parent().parent().toPathStr()
            check "."         == Pathname.new("a", "b", "c").parent().parent().parent().toPathStr()
            check ".."        == Pathname.new("a", "b", "c").parent().parent().parent().parent().toPathStr()
            check ".." / ".." == Pathname.new("a", "b", "c").parent().parent().parent().parent().parent().toPathStr()

        when true: # Common
            check "."           == Pathname.new("a", "..", "c").parent().toPathStr()
            check ".."          == Pathname.new("a", "..", "c").parent().parent().toPathStr()
            check ".." / ".."   == Pathname.new("a", "..", "c").parent().parent().parent().toPathStr()

        when defined(Posix):
            check "/"    == Pathname.new("/").toPathStr()
            check "/"    == Pathname.new("/").parent().toPathStr()
            check "/"    == Pathname.new("/a").parent().toPathStr()
            check "/"    == Pathname.new("/a/").parent().toPathStr()
            check "/a"   == Pathname.new("/a/b").parent().toPathStr()
            check "/a"   == Pathname.new("/a/b/").parent().toPathStr()
            check "/a/b" == Pathname.new("/a/b/c").parent().toPathStr()
            check "/a/b" == Pathname.new("/a/b/c/").parent().toPathStr()

            check "/" == Pathname.new("/a/../b" ).parent().toPathStr()
            check "/" == Pathname.new("/a/../b/").parent().toPathStr()
            check "/" == Pathname.new("/a/b/.." ).parent().toPathStr()
            check "/" == Pathname.new("/a/b/../").parent().toPathStr()

            check "/a" == Pathname.new("/a/b/../c" ).parent().toPathStr()
            check "/a" == Pathname.new("/a/b/../c/").parent().toPathStr()
            check "/a" == Pathname.new("/a/b/c/.." ).parent().toPathStr()
            check "/a" == Pathname.new("/a/b/c/../").parent().toPathStr()

        when defined(Windows):
            check "C:"       == Pathname.new("C:").toPathStr()
            check "C:"       == Pathname.new("C:").parent().toPathStr()
            check "C:"       == Pathname.new("C:\\").parent().toPathStr()
            check "C:"       == Pathname.new("C:\\a").parent().toPathStr()
            check "C:"       == Pathname.new("C:\\a\\").parent().toPathStr()
            check "C:\\a"    == Pathname.new("C:\\a\\b").parent().toPathStr()
            check "C:\\a"    == Pathname.new("C:\\a\\b\\").parent().toPathStr()
            check "C:\\a\\b" == Pathname.new("C:\\a\\b\\c").parent().toPathStr()
            check "C:\\a\\b" == Pathname.new("C:\\a\\b\\c\\").parent().toPathStr()

            check "C:" == Pathname.new("C:\\a\\..\\b" ).parent().toPathStr()
            check "C:" == Pathname.new("C:\\a\\..\\b\\").parent().toPathStr()
            check "C:" == Pathname.new("C:\\a\\b\\.." ).parent().toPathStr()
            check "C:" == Pathname.new("C:\\a\\b\\..\\").parent().toPathStr()

            check "C:\\a" == Pathname.new("C:\\a\\b\\..\\c" ).parent().toPathStr()
            check "C:\\a" == Pathname.new("C:\\a\\b\\..\\c\\").parent().toPathStr()
            check "C:\\a" == Pathname.new("C:\\a\\b\\c\\.." ).parent().toPathStr()
            check "C:\\a" == Pathname.new("C:\\a\\b\\c\\..\\").parent().toPathStr()


    test "#join()":
        when true: # Common
            check "a" / "b"       == Pathname.new("a").join("b").toPathStr()
            check "a" / "b" / "c" == Pathname.new("a").join("b", "c").toPathStr()

        when defined(Posix):
            check "/a"   == Pathname.new("/").join("a").toPathStr()
            check "/a/b" == Pathname.new("/").join("a", "b").toPathStr()

            check "/a/b/.." == Pathname.new("/").join("a", "b", ".." ).toPathStr()
            check "/a/b/.." == Pathname.new("/").join("a", "b", "../").toPathStr()
            check "/a/../b" == Pathname.new("/").join("a", "..", "b" ).toPathStr()
            check "/a/../b" == Pathname.new("/").join("a", "..", "b/").toPathStr()

        when defined(Windows):
            check "C:\\a"    == Pathname.new("C:").join("a").toPathStr()
            check "C:\\a\\b" == Pathname.new("C:").join("a", "b").toPathStr()

            check "C:\\a"    == Pathname.new("C:\\").join("a").toPathStr()
            check "C:\\a\\b" == Pathname.new("C:\\").join("a", "b").toPathStr()

            check "C:\\a\\b\\.." == Pathname.new("C:").join("a", "b", ".." ).toPathStr()
            check "C:\\a\\b\\.." == Pathname.new("C:").join("a", "b", "..\\").toPathStr()
            check "C:\\a\\..\\b" == Pathname.new("C:").join("a", "..", "b" ).toPathStr()
            check "C:\\a\\..\\b" == Pathname.new("C:").join("a", "..", "b\\").toPathStr()


    test "#joinNormalized()":
        when true: # Common
            check "a" / "b"       == Pathname.new("a").join("b").toPathStr()
            check "a" / "b" / "c" == Pathname.new("a").join("b", "c").toPathStr()

        when defined(Posix):
            check "/a"   == Pathname.new("/").joinNormalized("a").toPathStr()
            check "/a/b" == Pathname.new("/").joinNormalized("a", "b").toPathStr()

            check "/a" == Pathname.new("/").joinNormalized("a", "b", ".." ).toPathStr()
            check "/a" == Pathname.new("/").joinNormalized("a", "b", "../").toPathStr()
            check "/b" == Pathname.new("/").joinNormalized("a", "..", "b" ).toPathStr()
            check "/b" == Pathname.new("/").joinNormalized("a", "..", "b/").toPathStr()

        when defined(Windows):
            check "C:\\a"    == Pathname.new("C:").joinNormalized("a").toPathStr()
            check "C:\\a\\b" == Pathname.new("C:").joinNormalized("a", "b").toPathStr()

            check "C:\\a"    == Pathname.new("C:\\").joinNormalized("a").toPathStr()
            check "C:\\a\\b" == Pathname.new("C:\\").joinNormalized("a", "b").toPathStr()

            check "C:\\a" == Pathname.new("C:").joinNormalized("a", "b", ".." ).toPathStr()
            check "C:\\a" == Pathname.new("C:").joinNormalized("a", "b", "..\\").toPathStr()
            check "C:\\b" == Pathname.new("C:").joinNormalized("a", "..", "b" ).toPathStr()
            check "C:\\b" == Pathname.new("C:").joinNormalized("a", "..", "b\\").toPathStr()


    test "#dirname()":
        when defined(Posix):
            check "/" == Pathname.new("/"  ).dirname().toPathStr()
            check "/" == Pathname.new("//" ).dirname().toPathStr()
            check "/" == Pathname.new("///").dirname().toPathStr()
            check "/" == Pathname.new("/a" ).dirname().toPathStr()
            check "/" == Pathname.new("/a/").dirname().toPathStr()

            check "."  == Pathname.new("a" ).dirname().toPathStr()
            check "." == Pathname.new("a/").dirname().toPathStr()

            check "." == Pathname.new("" ).dirname().toPathStr()
            check "." == Pathname.new(" ").dirname().toPathStr()

            check "/" == Pathname.new("/."   ).dirname().toPathStr()
            check "/" == Pathname.new("/./"  ).dirname().toPathStr()
            check "/." == Pathname.new("/./ " ).dirname().toPathStr()
            check "/." == Pathname.new("/./ /").dirname().toPathStr()

            check "." == Pathname.new("."   ).dirname().toPathStr()
            check "." == Pathname.new("./"  ).dirname().toPathStr()
            check "." == Pathname.new("./ " ).dirname().toPathStr()
            check "." == Pathname.new("./ /").dirname().toPathStr()

            check "."  == Pathname.new(".."   ).dirname().toPathStr()
            check "."  == Pathname.new("../"  ).dirname().toPathStr()
            check ".." == Pathname.new("../ " ).dirname().toPathStr()
            check ".." == Pathname.new("../ /").dirname().toPathStr()

        when defined(Windows):
            check "C:" == Pathname.new("C:"     ).dirname().toPathStr()
            check "C:" == Pathname.new("C:\\"   ).dirname().toPathStr()
            check "C:" == Pathname.new("C:\\\\" ).dirname().toPathStr()
            check "C:" == Pathname.new("C:\\a"  ).dirname().toPathStr()
            check "C:" == Pathname.new("C:\\a\\").dirname().toPathStr()

            check "." == Pathname.new("a"  ).dirname().toPathStr()
            check "." == Pathname.new("a\\").dirname().toPathStr()

            check "." == Pathname.new("" ).dirname().toPathStr()
            check "." == Pathname.new(" ").dirname().toPathStr()

            check "C:"    == Pathname.new("C:\\."     ).dirname().toPathStr()
            check "C:"    == Pathname.new("C:\\.\\"   ).dirname().toPathStr()
            check "C:\\." == Pathname.new("C:\\.\\ "  ).dirname().toPathStr()
            check "C:\\." == Pathname.new("C:\\.\\ \\").dirname().toPathStr()

            check "." == Pathname.new("."     ).dirname().toPathStr()
            check "." == Pathname.new(".\\"   ).dirname().toPathStr()
            check "." == Pathname.new(".\\ "  ).dirname().toPathStr()
            check "." == Pathname.new(".\\ \\").dirname().toPathStr()

            check "."  == Pathname.new(".."     ).dirname().toPathStr()
            check "."  == Pathname.new("..\\"   ).dirname().toPathStr()
            check ".." == Pathname.new("..\\ "  ).dirname().toPathStr()
            check ".." == Pathname.new("..\\ \\").dirname().toPathStr()

    test "#dirname() with absolute paths":
        when defined(Posix):
            check "/"    == Pathname.new("/"      ).dirname().toPathStr()
            check "/"    == Pathname.new("//"     ).dirname().toPathStr()
            check "/"    == Pathname.new("/a"     ).dirname().toPathStr()
            check "/"    == Pathname.new("/a/"    ).dirname().toPathStr()
            check "/a"   == Pathname.new("/a/b"   ).dirname().toPathStr()
            check "/a"   == Pathname.new("/a/b/"  ).dirname().toPathStr()
            check "/a/b" == Pathname.new("/a/b/c" ).dirname().toPathStr()
            check "/a/b" == Pathname.new("/a/b/c/").dirname().toPathStr()

            check "/"      == Pathname.new("/"      ).dirname().toPathStr()
            check "/"      == Pathname.new("/ "     ).dirname().toPathStr()
            check "/"      == Pathname.new("/ /"    ).dirname().toPathStr()
            check "/ "     == Pathname.new("/ /a"   ).dirname().toPathStr()
            check "/ "     == Pathname.new("/ /a/"  ).dirname().toPathStr()
            check "/ /a"   == Pathname.new("/ /a/b" ).dirname().toPathStr()
            check "/ /a"   == Pathname.new("/ /a/b/").dirname().toPathStr()

            check "/"      == Pathname.new("/."     ).dirname().toPathStr()
            check "/"      == Pathname.new("/./"    ).dirname().toPathStr()
            check "/."     == Pathname.new("/./a"   ).dirname().toPathStr()
            check "/."     == Pathname.new("/./a/"  ).dirname().toPathStr()
            check "/./a"   == Pathname.new("/./a/b" ).dirname().toPathStr()
            check "/./a"   == Pathname.new("/./a/b/").dirname().toPathStr()

            check "/"      == Pathname.new("/.."     ).dirname().toPathStr()
            check "/"      == Pathname.new("/../"    ).dirname().toPathStr()
            check "/.."    == Pathname.new("/../a"   ).dirname().toPathStr()
            check "/.."    == Pathname.new("/../a/"  ).dirname().toPathStr()
            check "/../a"  == Pathname.new("/../a/b" ).dirname().toPathStr()
            check "/../a"  == Pathname.new("/../a/b/").dirname().toPathStr()

        when defined(Windows):
            check "C:"       == Pathname.new("C:\\"         ).dirname().toPathStr()
            check "C:"       == Pathname.new("C:\\a"        ).dirname().toPathStr()
            check "C:"       == Pathname.new("C:\\a\\"      ).dirname().toPathStr()
            check "C:\\a"    == Pathname.new("C:\\a\\b"     ).dirname().toPathStr()
            check "C:\\a"    == Pathname.new("C:\\a\\b\\"   ).dirname().toPathStr()
            check "C:\\a\\b" == Pathname.new("C:\\a\\b\\c"  ).dirname().toPathStr()
            check "C:\\a\\b" == Pathname.new("C:\\a\\b\\c\\").dirname().toPathStr()

            check "C:"        == Pathname.new("C:\\"         ).dirname().toPathStr()
            check "C:"        == Pathname.new("C:\\ "        ).dirname().toPathStr()
            check "C:"        == Pathname.new("C:\\ \\"      ).dirname().toPathStr()
            check "C:\\ "     == Pathname.new("C:\\ \\a"     ).dirname().toPathStr()
            check "C:\\ "     == Pathname.new("C:\\ \\a\\"   ).dirname().toPathStr()
            check "C:\\ \\a"  == Pathname.new("C:\\ \\a\\b"  ).dirname().toPathStr()
            check "C:\\ \\a"  == Pathname.new("C:\\ \\a\\b\\").dirname().toPathStr()

            check "C:"        == Pathname.new("C:\\."        ).dirname().toPathStr()
            check "C:"        == Pathname.new("C:\\.\\"      ).dirname().toPathStr()
            check "C:\\."     == Pathname.new("C:\\.\\a"     ).dirname().toPathStr()
            check "C:\\."     == Pathname.new("C:\\.\\a\\"   ).dirname().toPathStr()
            check "C:\\.\\a"  == Pathname.new("C:\\.\\a\\b"  ).dirname().toPathStr()
            check "C:\\.\\a"  == Pathname.new("C:\\.\\a\\b\\").dirname().toPathStr()

            check "C:"        == Pathname.new("C:\\.."        ).dirname().toPathStr()
            check "C:"        == Pathname.new("C:\\..\\"      ).dirname().toPathStr()
            check "C:\\.."    == Pathname.new("C:\\..\\a"     ).dirname().toPathStr()
            check "C:\\.."    == Pathname.new("C:\\..\\a\\"   ).dirname().toPathStr()
            check "C:\\..\\a" == Pathname.new("C:\\..\\a\\b"  ).dirname().toPathStr()
            check "C:\\..\\a" == Pathname.new("C:\\..\\a\\b\\").dirname().toPathStr()


    test "#dirname() with absolute paths (edgecase_00)":
        when defined(Posix):
            check "//a"  == Pathname.new("//a//b").dirname().toPathStr()
            check "//a"  == Pathname.new("//a//b//").dirname().toPathStr()

            check "//a"  == Pathname.new("//a// ").dirname().toPathStr()
            check "//a"  == Pathname.new("//a// //").dirname().toPathStr()

            check "//a"  == Pathname.new("//a//.").dirname().toPathStr()
            check "//a"  == Pathname.new("//a//.//").dirname().toPathStr()

            check "//a"  == Pathname.new("//a//..").dirname().toPathStr()
            check "//a"  == Pathname.new("//a//..//").dirname().toPathStr()

        when defined(Windows):
            check "C:\\\\a"  == Pathname.new("C:\\\\a\\\\b"    ).dirname().toPathStr()
            check "C:\\\\a"  == Pathname.new("C:\\\\a\\\\b\\\\").dirname().toPathStr()

            check "C:\\\\a"  == Pathname.new("C:\\\\a\\\\ "    ).dirname().toPathStr()
            check "C:\\\\a"  == Pathname.new("C:\\\\a\\\\ \\\\").dirname().toPathStr()

            check "C:\\\\a"  == Pathname.new("C:\\\\a\\\\."    ).dirname().toPathStr()
            check "C:\\\\a"  == Pathname.new("C:\\\\a\\\\.\\\\").dirname().toPathStr()

            check "C:\\\\a"  == Pathname.new("C:\\\\a\\\\.."    ).dirname().toPathStr()
            check "C:\\\\a"  == Pathname.new("C:\\\\a\\\\..\\\\").dirname().toPathStr()


    test "#dirname() with absolute paths (edgecase_01)":
        when defined(Posix):
            check "// "  == Pathname.new("// //a").dirname().toPathStr()
            check "// "  == Pathname.new("// //a//").dirname().toPathStr()

            check "// "  == Pathname.new("// // ").dirname().toPathStr()
            check "// "  == Pathname.new("// // //").dirname().toPathStr()

            check "// "  == Pathname.new("// //.").dirname().toPathStr()
            check "// "  == Pathname.new("// //.//").dirname().toPathStr()

            check "// "  == Pathname.new("// //..").dirname().toPathStr()
            check "// "  == Pathname.new("// //..//").dirname().toPathStr()

        when defined(Windows):
            check "C:\\\\ "  == Pathname.new("C:\\\\ \\\\a").dirname().toPathStr()
            check "C:\\\\ "  == Pathname.new("C:\\\\ \\\\a\\\\").dirname().toPathStr()

            check "C:\\\\ "  == Pathname.new("C:\\\\ \\\\ ").dirname().toPathStr()
            check "C:\\\\ "  == Pathname.new("C:\\\\ \\\\ \\\\").dirname().toPathStr()

            check "C:\\\\ "  == Pathname.new("C:\\\\ \\\\.").dirname().toPathStr()
            check "C:\\\\ "  == Pathname.new("C:\\\\ \\\\.\\\\").dirname().toPathStr()

            check "C:\\\\ "  == Pathname.new("C:\\\\ \\\\..").dirname().toPathStr()
            check "C:\\\\ "  == Pathname.new("C:\\\\ \\\\..\\\\").dirname().toPathStr()


    test "#dirname() with absolute paths (edgecase_02)":
        when defined(Posix):
            check "/"  == Pathname.new("/ /"  ).dirname().toPathStr()
            check "/"  == Pathname.new("/ //" ).dirname().toPathStr()
            check "/"  == Pathname.new("/ ///").dirname().toPathStr()

            check "//"  == Pathname.new("// /"  ).dirname().toPathStr()
            check "//"  == Pathname.new("// //" ).dirname().toPathStr()
            check "//"  == Pathname.new("// ///").dirname().toPathStr()

            check "///"  == Pathname.new("/// /"  ).dirname().toPathStr()
            check "///"  == Pathname.new("/// //" ).dirname().toPathStr()
            check "///"  == Pathname.new("/// ///").dirname().toPathStr()

        when defined(Windows):
            check "C:" == Pathname.new("C:\\ \\"  ).dirname().toPathStr()
            check "C:" == Pathname.new("C:\\ \\\\" ).dirname().toPathStr()
            check "C:" == Pathname.new("C:\\ \\\\\\").dirname().toPathStr()

            check "C:" == Pathname.new("C:\\\\ \\"  ).dirname().toPathStr()
            check "C:" == Pathname.new("C:\\\\ \\\\" ).dirname().toPathStr()
            check "C:" == Pathname.new("C:\\\\ \\\\\\").dirname().toPathStr()

            check "C:" == Pathname.new("C:\\\\\\ \\"  ).dirname().toPathStr()
            check "C:" == Pathname.new("C:\\\\\\ \\\\" ).dirname().toPathStr()
            check "C:" == Pathname.new("C:\\\\\\ \\\\\\").dirname().toPathStr()


    test "#dirname() with absolute paths (edgecase_03)":
        when defined(Posix):
            check "/ "  == Pathname.new("/ / "  ).dirname().toPathStr()
            check "/ "  == Pathname.new("/ // " ).dirname().toPathStr()
            check "/ "  == Pathname.new("/ /// ").dirname().toPathStr()

            check "// "  == Pathname.new("// / "  ).dirname().toPathStr()
            check "// "  == Pathname.new("// // " ).dirname().toPathStr()
            check "// "  == Pathname.new("// /// ").dirname().toPathStr()

            check "/// "  == Pathname.new("/// / "  ).dirname().toPathStr()
            check "/// "  == Pathname.new("/// // " ).dirname().toPathStr()
            check "/// "  == Pathname.new("/// /// ").dirname().toPathStr()

        when defined(Windows):
            check "C:\\ " == Pathname.new("C:\\ \\ "  ).dirname().toPathStr()
            check "C:\\ " == Pathname.new("C:\\ \\\\ " ).dirname().toPathStr()
            check "C:\\ " == Pathname.new("C:\\ \\\\\\ ").dirname().toPathStr()

            check "C:\\\\ " == Pathname.new("C:\\\\ \\ "  ).dirname().toPathStr()
            check "C:\\\\ " == Pathname.new("C:\\\\ \\\\ " ).dirname().toPathStr()
            check "C:\\\\ " == Pathname.new("C:\\\\ \\\\\\ ").dirname().toPathStr()

            check "C:\\\\\\ " == Pathname.new("C:\\\\\\ \\ "  ).dirname().toPathStr()
            check "C:\\\\\\ " == Pathname.new("C:\\\\\\ \\\\ " ).dirname().toPathStr()
            check "C:\\\\\\ " == Pathname.new("C:\\\\\\ \\\\\\ ").dirname().toPathStr()


    test "#dirname() with relative paths":
        check "."       == Pathname.new("a"     ).dirname().toPathStr()
        check "."       == Pathname.new("a" / ""    ).dirname().toPathStr()
        check "a"       == Pathname.new("a" / "b"   ).dirname().toPathStr()
        check "a"       == Pathname.new("a" / "b" / ""  ).dirname().toPathStr()
        check "a" / "b" == Pathname.new("a" / "b" / "c" ).dirname().toPathStr()
        check "a" / "b" == Pathname.new("a" / "b" / "c" / "").dirname().toPathStr()

        check "."       == Pathname.new(""      ).dirname().toPathStr()
        check "."       == Pathname.new(" "     ).dirname().toPathStr()
        check "."       == Pathname.new(" " / ""    ).dirname().toPathStr()
        check " "       == Pathname.new(" " / "a"   ).dirname().toPathStr()
        check " "       == Pathname.new(" " / "a" / ""  ).dirname().toPathStr()
        check " " / "a" == Pathname.new(" " / "a" / "b" ).dirname().toPathStr()
        check " " / "a" == Pathname.new(" " / "a" / "b" / "").dirname().toPathStr()

        check "." == Pathname.new("."     ).dirname().toPathStr()
        check "." == Pathname.new("." / ""    ).dirname().toPathStr()
        check "." == Pathname.new("." / "a"   ).dirname().toPathStr()
        check "." == Pathname.new("." / "a" / ""  ).dirname().toPathStr()
        check "a" == Pathname.new("." / "a" / "b" ).dirname().toPathStr()
        check "a" == Pathname.new("." / "a" / "b" / "").dirname().toPathStr()

        check "."        == Pathname.new(".."     ).dirname().toPathStr()
        check "."        == Pathname.new(".." / ""    ).dirname().toPathStr()
        check ".."       == Pathname.new(".." / "a"   ).dirname().toPathStr()
        check ".."       == Pathname.new(".." / "a" / ""  ).dirname().toPathStr()
        check ".." / "a" == Pathname.new(".." / "a" / "b" ).dirname().toPathStr()
        check ".." / "a" == Pathname.new(".." / "a" / "b" / "").dirname().toPathStr()


    test "#basename()":
        when true: # Common
            check ""   == Pathname.new(""  ).basename().toPathStr()
            check " "  == Pathname.new(" " ).basename().toPathStr()
            check "."  == Pathname.new("." ).basename().toPathStr()
            check ".." == Pathname.new("..").basename().toPathStr()
            check "a"  == Pathname.new("a" ).basename().toPathStr()
            check "b"  == Pathname.new("b" ).basename().toPathStr()
            check "a"  == Pathname.new("a" / ""      ).basename().toPathStr()
            check "b"  == Pathname.new("a" / "b"     ).basename().toPathStr()
            check "b"  == Pathname.new("a" / "b" / "").basename().toPathStr()

        when defined(Posix):
            check "/" == Pathname.new("/").basename().toPathStr()

            check "a" == Pathname.new("/a" ).basename().toPathStr()
            check "a" == Pathname.new("/a/").basename().toPathStr()
            check " " == Pathname.new("/ " ).basename().toPathStr()
            check " " == Pathname.new("/ /").basename().toPathStr()

            check "a" == Pathname.new("a" ).basename().toPathStr()
            check "a" == Pathname.new("a/").basename().toPathStr()
            check " " == Pathname.new(" " ).basename().toPathStr()
            check " " == Pathname.new(" /").basename().toPathStr()

            check "." == Pathname.new("/."   ).basename().toPathStr()
            check "." == Pathname.new("/./"  ).basename().toPathStr()
            check "a" == Pathname.new("/./a" ).basename().toPathStr()
            check "a" == Pathname.new("/./a/").basename().toPathStr()
            check " " == Pathname.new("/./ " ).basename().toPathStr()
            check " " == Pathname.new("/./ /").basename().toPathStr()

            check "." == Pathname.new("."   ).basename().toPathStr()
            check "." == Pathname.new("./"  ).basename().toPathStr()
            check "a" == Pathname.new("./a" ).basename().toPathStr()
            check "a" == Pathname.new("./a/").basename().toPathStr()
            check " " == Pathname.new("./ " ).basename().toPathStr()
            check " " == Pathname.new("./ /").basename().toPathStr()

            check ".." == Pathname.new("/.."   ).basename().toPathStr()
            check ".." == Pathname.new("/../"  ).basename().toPathStr()
            check "a"  == Pathname.new("/../a" ).basename().toPathStr()
            check "a"  == Pathname.new("/../a/").basename().toPathStr()
            check " "  == Pathname.new("/../ " ).basename().toPathStr()
            check " "  == Pathname.new("/../ /").basename().toPathStr()

            check ".." == Pathname.new(".."   ).basename().toPathStr()
            check ".." == Pathname.new("../"  ).basename().toPathStr()
            check "a"  == Pathname.new("../a" ).basename().toPathStr()
            check "a"  == Pathname.new("../a/").basename().toPathStr()
            check " "  == Pathname.new("../ " ).basename().toPathStr()
            check " "  == Pathname.new("../ /").basename().toPathStr()

        when defined(Windows):
            check "C:" == Pathname.new("C:\\").basename().toPathStr()

            check "a" == Pathname.new("C:\\a"  ).basename().toPathStr()
            check "a" == Pathname.new("C:\\a\\").basename().toPathStr()
            check " " == Pathname.new("C:\\ "  ).basename().toPathStr()
            check " " == Pathname.new("C:\\ \\").basename().toPathStr()

            check "a" == Pathname.new("a"  ).basename().toPathStr()
            check "a" == Pathname.new("a\\").basename().toPathStr()
            check " " == Pathname.new(" "  ).basename().toPathStr()
            check " " == Pathname.new(" \\").basename().toPathStr()

            check "." == Pathname.new("C:\\."     ).basename().toPathStr()
            check "." == Pathname.new("C:\\.\\"   ).basename().toPathStr()
            check "a" == Pathname.new("C:\\.\\a"  ).basename().toPathStr()
            check "a" == Pathname.new("C:\\.\\a\\").basename().toPathStr()
            check " " == Pathname.new("C:\\.\\ "  ).basename().toPathStr()
            check " " == Pathname.new("C:\\.\\ \\").basename().toPathStr()

            check "." == Pathname.new("."     ).basename().toPathStr()
            check "." == Pathname.new(".\\"   ).basename().toPathStr()
            check "a" == Pathname.new(".\\a"  ).basename().toPathStr()
            check "a" == Pathname.new(".\\a\\").basename().toPathStr()
            check " " == Pathname.new(".\\ "  ).basename().toPathStr()
            check " " == Pathname.new(".\\ \\").basename().toPathStr()

            check ".." == Pathname.new("C:\\.."    ).basename().toPathStr()
            check ".." == Pathname.new("C:\\..\\"   ).basename().toPathStr()
            check "a"  == Pathname.new("C:\\..\\a"  ).basename().toPathStr()
            check "a"  == Pathname.new("C:\\..\\a\\").basename().toPathStr()
            check " "  == Pathname.new("C:\\..\\ "  ).basename().toPathStr()
            check " "  == Pathname.new("C:\\..\\ \\").basename().toPathStr()

            check ".." == Pathname.new(".."     ).basename().toPathStr()
            check ".." == Pathname.new("..\\"   ).basename().toPathStr()
            check "a"  == Pathname.new("..\\a"  ).basename().toPathStr()
            check "a"  == Pathname.new("..\\a\\").basename().toPathStr()
            check " "  == Pathname.new("..\\ "  ).basename().toPathStr()
            check " "  == Pathname.new("..\\ \\").basename().toPathStr()


    test "#extname() file-form with relative paths":
        when true: # Common
            check ""    == Pathname.new("." ).extname()
            check ""    == Pathname.new("..").extname()
            check ""    == Pathname.new("x.").extname()
            check ""    == Pathname.new("xy.").extname()
            check ""    == Pathname.new("a.x.").extname()
            check ""    == Pathname.new("a.xy.").extname()
            check ""    == Pathname.new("a" / "b.x.").extname()
            check ""    == Pathname.new("a" / "b.xy.").extname()
            check ".x"  == Pathname.new("a.x").extname()
            check ".xy" == Pathname.new("a.xy").extname()
            check ".x"  == Pathname.new(".a.x").extname()
            check ".xy" == Pathname.new(".a.xy").extname()
            check ".x"  == Pathname.new("a" / "b.x").extname()
            check ".xy" == Pathname.new("a" / "b.xy").extname()
            check ".x"  == Pathname.new("a" / ".b.x").extname()
            check ".xy" == Pathname.new("a" / ".b.xy").extname()

        when defined(Posix):
            check ""    == Pathname.new("." ).extname()
            check ""    == Pathname.new(".x").extname()
            check ""    == Pathname.new(".xy").extname()
            check ".x"  == Pathname.new("a.x").extname()
            check ".xy" == Pathname.new(".a.xy").extname()
            check ".x"  == Pathname.new(".a.x").extname()
            check ".xy" == Pathname.new("a.xy").extname()
            check ""    == Pathname.new("a" / ".x").extname()
            check ""    == Pathname.new("a" / ".xy").extname()
            check ".x"  == Pathname.new("a" / "b.x").extname()
            check ".xy" == Pathname.new("a" / "b.xy").extname()
            check ".x"  == Pathname.new("a" / ".b.x").extname()
            check ".xy" == Pathname.new("a" / ".b.xy").extname()

        when defined(Windows):
            check ""    == Pathname.new("." ).extname()
            check ".x"  == Pathname.new(".x").extname()
            check ".xy" == Pathname.new(".xy").extname()
            check ".x"  == Pathname.new("a.x").extname()
            check ".xy" == Pathname.new(".a.xy").extname()
            check ".x"  == Pathname.new(".a.x").extname()
            check ".xy" == Pathname.new("a.xy").extname()
            check ".x"  == Pathname.new("a" / ".x").extname()
            check ".xy" == Pathname.new("a" / ".xy").extname()
            check ".x"  == Pathname.new("a" / "b.x").extname()
            check ".xy" == Pathname.new("a" / "b.xy").extname()
            check ".x"  == Pathname.new("a" / ".b.x").extname()
            check ".xy" == Pathname.new("a" / ".b.xy").extname()


    test "#extname() file-form with absolute paths":
        when defined(Posix):
            check ""  == Pathname.new("/."  ).extname()
            check ""  == Pathname.new("//." ).extname()
            check ""  == Pathname.new("///.").extname()

            check ""  == Pathname.new("/.x"  ).extname()
            check ""  == Pathname.new("//.x" ).extname()
            check ""  == Pathname.new("///.x").extname()

            check ".x"  == Pathname.new("/a.x"  ).extname()
            check ".x"  == Pathname.new("//a.x" ).extname()
            check ".x"  == Pathname.new("///a.x").extname()

            check ".xy" == Pathname.new("/a.xy"  ).extname()
            check ".xy" == Pathname.new("//a.xy" ).extname()
            check ".xy"  == Pathname.new("///a.xy").extname()

            check "" == Pathname.new("/a/.x"  ).extname()
            check "" == Pathname.new("//a//.x" ).extname()
            check ""  == Pathname.new("///a///.x").extname()

            check ".x" == Pathname.new("/a/b.x"  ).extname()
            check ".x" == Pathname.new("//a//b.x" ).extname()
            check ".x"  == Pathname.new("///a///b.x").extname()

            check ".xy" == Pathname.new("/a/b.xy"  ).extname()
            check ".xy" == Pathname.new("//a//b.xy" ).extname()
            check ".xy"  == Pathname.new("///a///b.xy").extname()

        when defined(Windows):
            check ""  == Pathname.new("C:\\."  ).extname()
            check ""  == Pathname.new("C:\\\\." ).extname()
            check ""  == Pathname.new("C:\\\\\\.").extname()

            check ".x"  == Pathname.new("C:\\.x"  ).extname()
            check ".x"  == Pathname.new("C:\\\\.x" ).extname()
            check ".x"  == Pathname.new("C:\\\\\\.x").extname()

            check ".x"  == Pathname.new("C:\\a.x"  ).extname()
            check ".x"  == Pathname.new("C:\\\\a.x" ).extname()
            check ".x"  == Pathname.new("C:\\\\\\a.x").extname()

            check ".xy" == Pathname.new("C:\\a.xy"  ).extname()
            check ".xy" == Pathname.new("C:\\\\a.xy" ).extname()
            check ".xy"  == Pathname.new("C:\\\\\\a.xy").extname()

            check ".x" == Pathname.new("C:\\a\\.x"  ).extname()
            check ".x" == Pathname.new("C:\\\\a\\\\.x" ).extname()
            check ".x"  == Pathname.new("C:\\\\\\a\\\\\\.x").extname()

            check ".x" == Pathname.new("C:\\a\\b.x"  ).extname()
            check ".x" == Pathname.new("C:\\\\a\\\\b.x" ).extname()
            check ".x"  == Pathname.new("C:\\\\\\a\\\\\\b.x").extname()

            check ".xy" == Pathname.new("C:\\a\\b.xy"  ).extname()
            check ".xy" == Pathname.new("C:\\\\a\\\\b.xy" ).extname()
            check ".xy"  == Pathname.new("C:\\\\\\a\\\\\\b.xy").extname()


    test "#extname() directory-form":
        when defined(Posix):
            check ".x"  == Pathname.new("a.x/" ).extname()
            check ".x"  == Pathname.new("a.x//").extname()

            check ".xy" == Pathname.new("a.xy/" ).extname()
            check ".xy" == Pathname.new("a.xy//").extname()

            check ".x"  == Pathname.new("/a.x/" ).extname()
            check ".x"  == Pathname.new("/a.x//").extname()

            check ".xy" == Pathname.new("/a.xy/" ).extname()
            check ".xy" == Pathname.new("/a.xy//").extname()

            check ".x"  == Pathname.new("/a.x/" ).extname()
            check ".x"  == Pathname.new("/a.x//").extname()

            check ".xy" == Pathname.new("/a.xy/" ).extname()
            check ".xy" == Pathname.new("/a.xy//").extname()

            check ".xy" == Pathname.new("//a.xy/" ).extname()
            check ".xy" == Pathname.new("//a.xy//").extname()

        when defined(Windows):
            check ".x"  == Pathname.new("a.x\\" ).extname()
            check ".x"  == Pathname.new("a.x\\\\").extname()

            check ".xy" == Pathname.new("a.xy\\" ).extname()
            check ".xy" == Pathname.new("a.xy\\\\").extname()

            check ".x"  == Pathname.new("C:\\a.x\\" ).extname()
            check ".x"  == Pathname.new("C:\\a.x\\\\").extname()

            check ".xy" == Pathname.new("C:\\a.xy\\" ).extname()
            check ".xy" == Pathname.new("C:\\a.xy\\\\").extname()

            check ".x"  == Pathname.new("C:\\a.x\\" ).extname()
            check ".x"  == Pathname.new("C:\\a.x\\\\").extname()

            check ".xy" == Pathname.new("C:\\a.xy\\" ).extname()
            check ".xy" == Pathname.new("C:\\a.xy\\\\").extname()

            check ".xy" == Pathname.new("C:\\\\a.xy\\" ).extname()
            check ".xy" == Pathname.new("C:\\\\a.xy\\\\").extname()


    test "#extname() (edgecase_00)":
        when defined(Posix):
            check "" == Pathname.new(".x" ).extname()
            check "" == Pathname.new(".xy").extname()

            check ".x"  == Pathname.new(".a.x" ).extname()
            check ".xy" == Pathname.new(".a.xy").extname()

            check "" == Pathname.new("/.x" ).extname()
            check "" == Pathname.new("/.xy").extname()
            check "" == Pathname.new("//.x" ).extname()
            check "" == Pathname.new("//.xy").extname()

            check "" == Pathname.new("a/.x" ).extname()
            check "" == Pathname.new("a/.xy").extname()
            check "" == Pathname.new("a//.x" ).extname()
            check "" == Pathname.new("a//.xy").extname()

            check "" == Pathname.new("/a/.x" ).extname()
            check "" == Pathname.new("/a/.xy").extname()
            check "" == Pathname.new("//a//.x" ).extname()
            check "" == Pathname.new("//a//.xy").extname()

        when defined(Windows):
            check ".x"  == Pathname.new(".x" ).extname()
            check ".xy" == Pathname.new(".xy").extname()

            check ".x"  == Pathname.new(".a.x" ).extname()
            check ".xy" == Pathname.new(".a.xy").extname()

            check ".x"  == Pathname.new("C:\\.x" ).extname()
            check ".xy" == Pathname.new("C:\\.xy").extname()
            check ".x"  == Pathname.new("C:\\\\.x" ).extname()
            check ".xy" == Pathname.new("C:\\\\.xy").extname()

            check ".x"  == Pathname.new("a\\.x" ).extname()
            check ".xy" == Pathname.new("a\\.xy").extname()
            check ".x"  == Pathname.new("a\\\\.x" ).extname()
            check ".xy" == Pathname.new("a\\\\.xy").extname()

            check ".x"  == Pathname.new("C:\\a\\.x" ).extname()
            check ".xy" == Pathname.new("C:\\a\\.xy").extname()
            check ".x"  == Pathname.new("C:\\\\a\\\\.x" ).extname()
            check ".xy" == Pathname.new("C:\\\\a\\\\.xy").extname()


    test "#extname() (edgecase_01)":
        when defined(Posix):
            check "" == Pathname.new("." ).extname()
            check "" == Pathname.new(". ").extname()

            check "" == Pathname.new("/." ).extname()
            check "" == Pathname.new("//.").extname()

            check "" == Pathname.new("//." ).extname()
            check "" == Pathname.new("//. ").extname()

            check "" == Pathname.new("a/." ).extname()
            check "" == Pathname.new("a//.").extname()

            check "" == Pathname.new("a/. ").extname()
            check "" == Pathname.new("a//. ").extname()

            check "" == Pathname.new("/a/."  ).extname()
            check "" == Pathname.new("//a//.").extname()

            check "" == Pathname.new("/a/."  ).extname()
            check "" == Pathname.new("//a//.").extname()

            check "" == Pathname.new("/a/. "  ).extname()
            check "" == Pathname.new("//a//. ").extname()

        when defined(Windows):
            check ""   == Pathname.new("." ).extname()
            check ". " == Pathname.new(". ").extname()

            check "" == Pathname.new("C:\\."  ).extname()
            check "" == Pathname.new("C:\\\\.").extname()

            check ""   == Pathname.new("C:\\\\." ).extname()
            check ". " == Pathname.new("C:\\\\. ").extname()

            check "" == Pathname.new("a\\."  ).extname()
            check "" == Pathname.new("a\\\\.").extname()

            check ". " == Pathname.new("a\\. "  ).extname()
            check ". " == Pathname.new("a\\\\. ").extname()

            check "" == Pathname.new("C:\\a\\."    ).extname()
            check "" == Pathname.new("C:\\\\a\\\\.").extname()

            check "" == Pathname.new("C:\\a\\."    ).extname()
            check "" == Pathname.new("C:\\\\a\\\\.").extname()

            check ". " == Pathname.new("C:\\a\\. "    ).extname()
            check ". " == Pathname.new("C:\\\\a\\\\. ").extname()


    test "#extname() (edgecase_02)":
        when defined(Posix):
            check "" == Pathname.new("..x"   ).extname()
            check "" == Pathname.new("/..x"  ).extname()
            check "" == Pathname.new("//..x" ).extname()
            check "" == Pathname.new("///..x").extname()

            check "" == Pathname.new("a/..x"     ).extname()
            check "" == Pathname.new("/a/..x"    ).extname()
            check "" == Pathname.new("//a//..x"  ).extname()
            check "" == Pathname.new("///a///..x").extname()

            check ".y" == Pathname.new("..x.y"   ).extname()
            check ".y" == Pathname.new("/..x.y"  ).extname()
            check ".y" == Pathname.new("//..x.y" ).extname()
            check ".y" == Pathname.new("///..x.y").extname()

            check ".y" == Pathname.new("a/..x.y"     ).extname()
            check ".y" == Pathname.new("/a/..x.y"    ).extname()
            check ".y" == Pathname.new("//a//..x.y"  ).extname()
            check ".y" == Pathname.new("///a///..x.y").extname()

        when defined(Windows):
            check ".x" == Pathname.new("..x"   ).extname()
            check ".x" == Pathname.new("/..x"  ).extname()
            check ".x" == Pathname.new("//..x" ).extname()
            check ".x" == Pathname.new("///..x").extname()

            check ".x" == Pathname.new("a/..x"     ).extname()
            check ".x" == Pathname.new("/a/..x"    ).extname()
            check ".x" == Pathname.new("//a//..x"  ).extname()
            check ".x" == Pathname.new("///a///..x").extname()

            check ".y" == Pathname.new("..x.y"   ).extname()
            check ".y" == Pathname.new("/..x.y"  ).extname()
            check ".y" == Pathname.new("//..x.y" ).extname()
            check ".y" == Pathname.new("///..x.y").extname()

            check ".y" == Pathname.new("a/..x.y"     ).extname()
            check ".y" == Pathname.new("/a/..x.y"    ).extname()
            check ".y" == Pathname.new("//a//..x.y"  ).extname()
            check ".y" == Pathname.new("///a///..x.y").extname()


    test "#extname() (edgecase_03)":
        when defined(Posix):
            check ".x" == Pathname.new("a..x"   ).extname()
            check ".x" == Pathname.new("/a..x"  ).extname()
            check ".x" == Pathname.new("//a..x" ).extname()
            check ".x" == Pathname.new("///a..x").extname()

            check ".x" == Pathname.new("a/b..x"     ).extname()
            check ".x" == Pathname.new("/a/b..x"    ).extname()
            check ".x" == Pathname.new("//a//b..x"  ).extname()
            check ".x" == Pathname.new("///a///b..x").extname()

            check ".y" == Pathname.new("a..x.y"   ).extname()
            check ".y" == Pathname.new("/a..x.y"  ).extname()
            check ".y" == Pathname.new("//a..x.y" ).extname()
            check ".y" == Pathname.new("///a..x.y").extname()

            check ".y" == Pathname.new("a/b..x.y"     ).extname()
            check ".y" == Pathname.new("/a/b..x.y"    ).extname()
            check ".y" == Pathname.new("//a//b..x.y"  ).extname()
            check ".y" == Pathname.new("///a///b..x.y").extname()

        when defined(Windows):
            check ".x" == Pathname.new("a..x"   ).extname()
            check ".x" == Pathname.new("C:\\a..x"  ).extname()
            check ".x" == Pathname.new("C:\\\\a..x" ).extname()
            check ".x" == Pathname.new("C:\\\\\\a..x").extname()

            check ".x" == Pathname.new("a\\b..x"     ).extname()
            check ".x" == Pathname.new("C:\\a\\b..x"    ).extname()
            check ".x" == Pathname.new("C:\\\\a\\\\b..x"  ).extname()
            check ".x" == Pathname.new("C:\\\\\\a\\\\\\b..x").extname()

            check ".y" == Pathname.new("a..x.y"   ).extname()
            check ".y" == Pathname.new("C:\\a..x.y"  ).extname()
            check ".y" == Pathname.new("C:\\\\a..x.y" ).extname()
            check ".y" == Pathname.new("C:\\\\\\a..x.y").extname()

            check ".y" == Pathname.new("a\\b..x.y"     ).extname()
            check ".y" == Pathname.new("C:\\a\\b..x.y"    ).extname()
            check ".y" == Pathname.new("C:\\\\a\\\\b..x.y"  ).extname()
            check ".y" == Pathname.new("C:\\\\\\a\\\\\\b..x.y").extname()


    test "#extname() (edgecase_04)":
        when defined(Posix):
            check ".x" == Pathname.new("a..x/"     ).extname()
            check ".x" == Pathname.new("/a..x//"   ).extname()
            check ".x" == Pathname.new("//a..x///" ).extname()
            check ".x" == Pathname.new("///a..x///").extname()

            check ".x" == Pathname.new("a/b..x/"        ).extname()
            check ".x" == Pathname.new("/a/b..x//"      ).extname()
            check ".x" == Pathname.new("//a//b..x///"   ).extname()
            check ".x" == Pathname.new("///a///b..x////").extname()

            check ".y" == Pathname.new("a..x.y/"      ).extname()
            check ".y" == Pathname.new("/a..x.y//"    ).extname()
            check ".y" == Pathname.new("//a..x.y///"  ).extname()
            check ".y" == Pathname.new("///a..x.y////").extname()

            check ".y" == Pathname.new("a/b..x.y/"        ).extname()
            check ".y" == Pathname.new("/a/b..x.y//"      ).extname()
            check ".y" == Pathname.new("//a//b..x.y///"   ).extname()
            check ".y" == Pathname.new("///a///b..x.y////").extname()

        when defined(Windows):
            check ".x" == Pathname.new("a..x\\"     ).extname()
            check ".x" == Pathname.new("C:\\a..x\\\\"   ).extname()
            check ".x" == Pathname.new("C:\\\\a..x\\\\\\" ).extname()
            check ".x" == Pathname.new("C:\\\\\\a..x\\\\\\").extname()

            check ".x" == Pathname.new("a\\b..x\\"        ).extname()
            check ".x" == Pathname.new("C:\\a\\b..x\\\\"      ).extname()
            check ".x" == Pathname.new("C:\\\\a\\\\b..x\\\\\\"   ).extname()
            check ".x" == Pathname.new("C:\\\\\\a\\\\\\b..x\\\\\\\\").extname()

            check ".y" == Pathname.new("a..x.y\\"      ).extname()
            check ".y" == Pathname.new("C:\\a..x.y\\\\"    ).extname()
            check ".y" == Pathname.new("C:\\\\a..x.y\\\\\\"  ).extname()
            check ".y" == Pathname.new("C:\\\\\\a..x.y\\\\\\\\").extname()

            check ".y" == Pathname.new("a\\b..x.y\\"        ).extname()
            check ".y" == Pathname.new("C:\\a\\b..x.y\\\\"      ).extname()
            check ".y" == Pathname.new("C:\\\\a\\\\b..x.y\\\\\\"   ).extname()
            check ".y" == Pathname.new("C:\\\\\\a\\\\\\b..x.y\\\\\\\\").extname()


    test "#extname() (edgecase_05a)":
        when defined(Posix):
            check "" == Pathname.new(".").extname()
            check "" == Pathname.new("/.").extname()
            check "" == Pathname.new("//.").extname()
            check "" == Pathname.new("///.").extname()

            check "" == Pathname.new("..").extname()
            check "" == Pathname.new("/..").extname()
            check "" == Pathname.new("//..").extname()
            check "" == Pathname.new("///..").extname()

            check "" == Pathname.new("...").extname()
            check "" == Pathname.new("/...").extname()
            check "" == Pathname.new("//...").extname()
            check "" == Pathname.new("///...").extname()

            check "" == Pathname.new("....").extname()
            check "" == Pathname.new("/....").extname()
            check "" == Pathname.new("//....").extname()
            check "" == Pathname.new("///....").extname()

        when defined(Windows):
            check "" == Pathname.new(".").extname()
            check "" == Pathname.new("C:\\.").extname()
            check "" == Pathname.new("C:\\\\.").extname()
            check "" == Pathname.new("C:\\\\\\.").extname()

            check "" == Pathname.new("..").extname()
            check "" == Pathname.new("C:\\..").extname()
            check "" == Pathname.new("C:\\\\..").extname()
            check "" == Pathname.new("C:\\\\\\..").extname()

            check "" == Pathname.new("...").extname()
            check "" == Pathname.new("C:\\...").extname()
            check "" == Pathname.new("C:\\\\...").extname()
            check "" == Pathname.new("C:\\\\\\...").extname()

            check "" == Pathname.new("....").extname()
            check "" == Pathname.new("C:\\....").extname()
            check "" == Pathname.new("C:\\\\....").extname()
            check "" == Pathname.new("C:\\\\\\....").extname()


    test "#extname() (edgecase_05b)":
        when defined(Posix):
            check "" == Pathname.new(".x").extname()
            check "" == Pathname.new("/.x").extname()
            check "" == Pathname.new("//.x").extname()
            check "" == Pathname.new("///.x").extname()

            check "" == Pathname.new("..x").extname()
            check "" == Pathname.new("/..x").extname()
            check "" == Pathname.new("//..x").extname()
            check "" == Pathname.new("///..x").extname()

            check "" == Pathname.new("...x").extname()
            check "" == Pathname.new("/...x").extname()
            check "" == Pathname.new("//...x").extname()
            check "" == Pathname.new("///...x").extname()

            check "" == Pathname.new("....x").extname()
            check "" == Pathname.new("/....x").extname()
            check "" == Pathname.new("//....x").extname()
            check "" == Pathname.new("///....x").extname()

        when defined(Windows):
            check ".x" == Pathname.new(".x").extname()
            check ".x" == Pathname.new("C:\\.x").extname()
            check ".x" == Pathname.new("C:\\\\.x").extname()
            check ".x" == Pathname.new("C:\\\\\\.x").extname()

            check ".x" == Pathname.new("..x").extname()
            check ".x" == Pathname.new("C:\\..x").extname()
            check ".x" == Pathname.new("C:\\\\..x").extname()
            check ".x" == Pathname.new("C:\\\\\\..x").extname()

            check ".x" == Pathname.new("...x").extname()
            check ".x" == Pathname.new("C:\\...x").extname()
            check ".x" == Pathname.new("C:\\\\...x").extname()
            check ".x" == Pathname.new("C:\\\\\\...x").extname()

            check ".x" == Pathname.new("....x").extname()
            check ".x" == Pathname.new("C:\\....x").extname()
            check ".x" == Pathname.new("C:\\\\....x").extname()
            check ".x" == Pathname.new("C:\\\\\\....x").extname()


    test "#extname() (edgecase_05c)":
        when defined(Posix):
            check "" == Pathname.new(". ").extname()
            check "" == Pathname.new("/. ").extname()
            check "" == Pathname.new("//. ").extname()
            check "" == Pathname.new("///. ").extname()

            check "" == Pathname.new(".. ").extname()
            check "" == Pathname.new("/.. ").extname()
            check "" == Pathname.new("//.. ").extname()
            check "" == Pathname.new("///.. ").extname()

            check "" == Pathname.new("... ").extname()
            check "" == Pathname.new("/... ").extname()
            check "" == Pathname.new("//... ").extname()
            check "" == Pathname.new("///... ").extname()

            check "" == Pathname.new(".... ").extname()
            check "" == Pathname.new("/.... ").extname()
            check "" == Pathname.new("//.... ").extname()
            check "" == Pathname.new("///.... ").extname()

        when defined(Windows):
            check ". " == Pathname.new(". ").extname()
            check ". " == Pathname.new("C:\\. ").extname()
            check ". " == Pathname.new("C:\\\\. ").extname()
            check ". " == Pathname.new("C:\\\\\\. ").extname()

            check ". " == Pathname.new(".. ").extname()
            check ". " == Pathname.new("C:\\.. ").extname()
            check ". " == Pathname.new("C:\\\\.. ").extname()
            check ". " == Pathname.new("C:\\\\\\.. ").extname()

            check ". " == Pathname.new("... ").extname()
            check ". " == Pathname.new("C:\\... ").extname()
            check ". " == Pathname.new("C:\\\\... ").extname()
            check ". " == Pathname.new("C:\\\\\\... ").extname()

            check ". " == Pathname.new(".... ").extname()
            check ". " == Pathname.new("C:\\.... ").extname()
            check ". " == Pathname.new("C:\\\\.... ").extname()
            check ". " == Pathname.new("C:\\\\\\.... ").extname()


    test "#extname() (edgecase_06a)":
        when defined(Posix):
            check "" == Pathname.new("a.").extname()
            check "" == Pathname.new("/a.").extname()
            check "" == Pathname.new("//a.").extname()
            check "" == Pathname.new("///a.").extname()

        when defined(Windows):
            check "" == Pathname.new("a.").extname()
            check "" == Pathname.new("C:\\a.").extname()
            check "" == Pathname.new("C:\\\\a.").extname()
            check "" == Pathname.new("C:\\\\\\a.").extname()


    test "#extname() (edgecase_06b)":
        when defined(Posix):
            check "" == Pathname.new(" .").extname()
            check "" == Pathname.new("/ .").extname()
            check "" == Pathname.new("// .").extname()
            check "" == Pathname.new("/// .").extname()

        when defined(Windows):
            check "" == Pathname.new(" .").extname()
            check "" == Pathname.new("C:\\ .").extname()
            check "" == Pathname.new("C:\\\\ .").extname()
            check "" == Pathname.new("C:\\\\\\ .").extname()


    test "#extname() (edgecase_06c)":
        when defined(Posix):
            check "" == Pathname.new("a./").extname()
            check "" == Pathname.new("/a.//").extname()
            check "" == Pathname.new("//a.///").extname()
            check "" == Pathname.new("///a.////").extname()

        when defined(Windows):
            check "" == Pathname.new("a.\\").extname()
            check "" == Pathname.new("C:\\a.\\\\").extname()
            check "" == Pathname.new("C:\\\\a.\\\\\\").extname()
            check "" == Pathname.new("C:\\\\\\a.\\\\\\\\").extname()


    test "#extname() (edgecase_06d)":
        when defined(Posix):
            check "" == Pathname.new(" ./").extname()
            check "" == Pathname.new("/ .//").extname()
            check "" == Pathname.new("// .///").extname()
            check "" == Pathname.new("/// .////").extname()

        when defined(Windows):
            check "" == Pathname.new(" .\\").extname()
            check "" == Pathname.new("C:\\ .\\\\").extname()
            check "" == Pathname.new("C:\\\\ .\\\\\\").extname()
            check "" == Pathname.new("C:\\\\\\ .\\\\\\\\").extname()


    test "#normalize()":
        when defined(Posix):
            check "." == Pathname.new("").normalize().toPathStr()

            check "a" == Pathname.new("a"  ).normalize().toPathStr()
            check "a" == Pathname.new("a/" ).normalize().toPathStr()
            check "a" == Pathname.new("a//").normalize().toPathStr()

            check "/b" == Pathname.new("/b"   ).normalize().toPathStr()
            check "/b" == Pathname.new("/b/"  ).normalize().toPathStr()
            check "/b" == Pathname.new("//b//").normalize().toPathStr()

            check "." == Pathname.new("."  ).normalize().toPathStr()
            check "." == Pathname.new("./" ).normalize().toPathStr()
            check "." == Pathname.new(".//").normalize().toPathStr()

            check ".." == Pathname.new(".."  ).normalize().toPathStr()
            check ".." == Pathname.new("../" ).normalize().toPathStr()
            check ".." == Pathname.new("..//").normalize().toPathStr()

            check "/" == Pathname.new("/."     ).normalize().toPathStr()
            check "/" == Pathname.new("/./"    ).normalize().toPathStr()
            check "/" == Pathname.new("//."    ).normalize().toPathStr()
            check "/" == Pathname.new("//.//"  ).normalize().toPathStr()
            check "/" == Pathname.new("///."   ).normalize().toPathStr()
            check "/" == Pathname.new("///.///").normalize().toPathStr()

            check "/" == Pathname.new("/.."     ).normalize().toPathStr()
            check "/" == Pathname.new("/../"    ).normalize().toPathStr()
            check "/" == Pathname.new("//.."    ).normalize().toPathStr()
            check "/" == Pathname.new("//..//"  ).normalize().toPathStr()
            check "/" == Pathname.new("///.."   ).normalize().toPathStr()
            check "/" == Pathname.new("///..///").normalize().toPathStr()

        when defined(Windows):
            check "." == Pathname.new("").normalize().toPathStr()

            check "a" == Pathname.new("a"  ).normalize().toPathStr()
            check "a" == Pathname.new("a\\" ).normalize().toPathStr()
            check "a" == Pathname.new("a\\\\").normalize().toPathStr()

            check "C:\\b" == Pathname.new("C:\\b"   ).normalize().toPathStr()
            check "C:\\b" == Pathname.new("C:\\b\\"  ).normalize().toPathStr()
            check "C:\\b" == Pathname.new("C:\\\\b\\\\").normalize().toPathStr()

            check "." == Pathname.new("."  ).normalize().toPathStr()
            check "." == Pathname.new(".\\" ).normalize().toPathStr()
            check "." == Pathname.new(".\\\\").normalize().toPathStr()

            check ".." == Pathname.new(".."  ).normalize().toPathStr()
            check ".." == Pathname.new("..\\" ).normalize().toPathStr()
            check ".." == Pathname.new("..\\\\").normalize().toPathStr()

            check "C:" == Pathname.new("C:\\."     ).normalize().toPathStr()
            check "C:" == Pathname.new("C:\\.\\"    ).normalize().toPathStr()
            check "C:" == Pathname.new("C:\\\\."    ).normalize().toPathStr()
            check "C:" == Pathname.new("C:\\\\.\\\\"  ).normalize().toPathStr()
            check "C:" == Pathname.new("C:\\\\\\."   ).normalize().toPathStr()
            check "C:" == Pathname.new("C:\\\\\\.\\\\\\").normalize().toPathStr()

            check "C:" == Pathname.new("C:\\.."     ).normalize().toPathStr()
            check "C:" == Pathname.new("C:\\..\\"    ).normalize().toPathStr()
            check "C:" == Pathname.new("C:\\\\.."    ).normalize().toPathStr()
            check "C:" == Pathname.new("C:\\\\..\\\\"  ).normalize().toPathStr()
            check "C:" == Pathname.new("C:\\\\\\.."   ).normalize().toPathStr()
            check "C:" == Pathname.new("C:\\\\\\..\\\\\\").normalize().toPathStr()


    test "#cleanpath()":
        when defined(Posix):
            check "." == Pathname.new("").cleanpath().toPathStr()

            check "a" == Pathname.new("a"  ).cleanpath().toPathStr()
            check "a" == Pathname.new("a/" ).cleanpath().toPathStr()
            check "a" == Pathname.new("a//").cleanpath().toPathStr()

            check "/b" == Pathname.new("/b"   ).cleanpath().toPathStr()
            check "/b" == Pathname.new("/b/"  ).cleanpath().toPathStr()
            check "/b" == Pathname.new("//b//").cleanpath().toPathStr()

            check "." == Pathname.new("."  ).cleanpath().toPathStr()
            check "." == Pathname.new("./" ).cleanpath().toPathStr()
            check "." == Pathname.new(".//").cleanpath().toPathStr()

            check ".." == Pathname.new(".."  ).cleanpath().toPathStr()
            check ".." == Pathname.new("../" ).cleanpath().toPathStr()
            check ".." == Pathname.new("..//").cleanpath().toPathStr()

            check "/" == Pathname.new("/."     ).cleanpath().toPathStr()
            check "/" == Pathname.new("/./"    ).cleanpath().toPathStr()
            check "/" == Pathname.new("//."    ).cleanpath().toPathStr()
            check "/" == Pathname.new("//.//"  ).cleanpath().toPathStr()
            check "/" == Pathname.new("///."   ).cleanpath().toPathStr()
            check "/" == Pathname.new("///.///").cleanpath().toPathStr()

            check "/" == Pathname.new("/.."     ).cleanpath().toPathStr()
            check "/" == Pathname.new("/../"    ).cleanpath().toPathStr()
            check "/" == Pathname.new("//.."    ).cleanpath().toPathStr()
            check "/" == Pathname.new("//..//"  ).cleanpath().toPathStr()
            check "/" == Pathname.new("///.."   ).cleanpath().toPathStr()
            check "/" == Pathname.new("///..///").cleanpath().toPathStr()

        when defined(Windows):
            check "." == Pathname.new("").cleanpath().toPathStr()

            check "a" == Pathname.new("a"  ).cleanpath().toPathStr()
            check "a" == Pathname.new("a\\" ).cleanpath().toPathStr()
            check "a" == Pathname.new("a\\\\").cleanpath().toPathStr()

            check "C:\\b" == Pathname.new("C:\\b"   ).cleanpath().toPathStr()
            check "C:\\b" == Pathname.new("C:\\b\\"  ).cleanpath().toPathStr()
            check "C:\\b" == Pathname.new("C:\\\\b\\\\").cleanpath().toPathStr()

            check "." == Pathname.new("."  ).cleanpath().toPathStr()
            check "." == Pathname.new(".\\" ).cleanpath().toPathStr()
            check "." == Pathname.new(".\\\\").cleanpath().toPathStr()

            check ".." == Pathname.new(".."  ).cleanpath().toPathStr()
            check ".." == Pathname.new("..\\" ).cleanpath().toPathStr()
            check ".." == Pathname.new("..\\\\").cleanpath().toPathStr()

            check "C:" == Pathname.new("C:\\."     ).cleanpath().toPathStr()
            check "C:" == Pathname.new("C:\\.\\"    ).cleanpath().toPathStr()
            check "C:" == Pathname.new("C:\\\\."    ).cleanpath().toPathStr()
            check "C:" == Pathname.new("C:\\\\.\\\\"  ).cleanpath().toPathStr()
            check "C:" == Pathname.new("C:\\\\\\."   ).cleanpath().toPathStr()
            check "C:" == Pathname.new("C:\\\\\\.\\\\\\").cleanpath().toPathStr()

            check "C:" == Pathname.new("C:\\.."     ).cleanpath().toPathStr()
            check "C:" == Pathname.new("C:\\..\\"    ).cleanpath().toPathStr()
            check "C:" == Pathname.new("C:\\\\.."    ).cleanpath().toPathStr()
            check "C:" == Pathname.new("C:\\\\..\\\\"  ).cleanpath().toPathStr()
            check "C:" == Pathname.new("C:\\\\\\.."   ).cleanpath().toPathStr()
            check "C:" == Pathname.new("C:\\\\\\..\\\\\\").cleanpath().toPathStr()


    test "#fileType() v1":
        check FileType.REGULAR_FILE == Pathname.new(fixturePath("sample_dir", "a_file")).fileType()

        check FileType.DIRECTORY == Pathname.new(fixturePath("sample_dir", "a_dir")).fileType()

        check FileType.NOT_EXISTING == Pathname.new(fixturePath("NON_EXISTING_FILE" )).fileType()
        check FileType.NOT_EXISTING == Pathname.new(fixturePath("NON_EXISTING_FILE", "")).fileType()

        check FileType.NOT_EXISTING == Pathname.new(fixturePath("sample_dir", "NON_EXISTING_FILE" )).fileType()
        check FileType.NOT_EXISTING == Pathname.new(fixturePath("sample_dir", "NON_EXISTING_FILE", "")).fileType()

        when defined(Posix):
            check FileType.SYMLINK      == Pathname.new(fixturePath("sample_dir", "a_symlink_to_file"  )).fileType()
            check FileType.NOT_EXISTING == Pathname.new(fixturePath("sample_dir", "a_symlink_to_file", "" )).fileType()
            check FileType.NOT_EXISTING == Pathname.new(fixturePath("sample_dir", "a_symlink_to_file", "", "")).fileType()

            check FileType.SYMLINK   == Pathname.new(fixturePath("sample_dir", "a_symlink_to_dir"  )).fileType()
            check FileType.DIRECTORY == Pathname.new(fixturePath("sample_dir", "a_symlink_to_dir", "" )).fileType()
            check FileType.DIRECTORY == Pathname.new(fixturePath("sample_dir", "a_symlink_to_dir", "", "")).fileType()

        when defined(Posix):
            check FileType.SOCKET_FILE == Pathname.new("/tmp/.X11-unix/X0").fileType()

        when defined(Posix):
            check FileType.CHARACTER_DEVICE == Pathname.new("/dev/null").fileType()
            check FileType.BLOCK_DEVICE     == Pathname.new("/dev/loop0").fileType()

        when defined(Posix):
            discard posix.mkfifo( fixturePath("sample_dir/a_pipe").cstring, 0o600)
            check FileType.PIPE_FILE == Pathname.new(fixturePath("sample_dir/a_pipe")).fileType()
            discard posix.unlink( fixturePath("sample_dir/a_pipe").cstring )



    test "#fileType() v2":
        check true == Pathname.new(fixturePath("sample_dir", "a_file")).fileType().isRegularFile()

        check true == Pathname.new(fixturePath("sample_dir", "a_dir")).fileType().isDirectory()

        check true == Pathname.new(fixturePath("sample_dir", "a_file"   )).fileType().isExisting()
        check true == Pathname.new(fixturePath("sample_dir", "a_dir"    )).fileType().isExisting()
        check true == Pathname.new(fixturePath("sample_dir", "a_symlink")).fileType().isExisting()

        check true == Pathname.new(fixturePath("NON_EXISTING_FILE" )).fileType().isNotExisting()
        check true == Pathname.new(fixturePath("NON_EXISTING_FILE", "")).fileType().isNotExisting()

        check true == Pathname.new(fixturePath("sample_dir", "NON_EXISTING_FILE"    )).fileType().isNotExisting()
        check true == Pathname.new(fixturePath("sample_dir", "NON_EXISTING_FILE", "")).fileType().isNotExisting()

        when defined(Posix):
            check true == Pathname.new(fixturePath("sample_dir/a_symlink_to_file")).fileType().isSymlink()

            check true == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir")).fileType().isSymlink()

        when defined(Posix):
            check true == Pathname.new("/dev/null" ).fileType().isDeviceFile()
            check true == Pathname.new("/dev/loop0").fileType().isDeviceFile()

        when defined(Posix):
            check true == Pathname.new("/dev/null" ).fileType().isCharacterDeviceFile()
            check true == Pathname.new("/dev/loop0").fileType().isBlockDeviceFile()

        when defined(Posix):
            check true == Pathname.new("/tmp/.X11-unix/X0").fileType().isSocketFile()

        when defined(Posix):
            discard posix.mkfifo( fixturePath("sample_dir/a_pipe").cstring, 0o600)
            check true == Pathname.new(fixturePath("sample_dir/a_pipe")).fileType().isPipeFile()
            discard posix.unlink( fixturePath("sample_dir/a_pipe").cstring )



    test "#isExisting() with regular files":
        check true == Pathname.new(fixturePath("README.md"  )).isExisting()

        check true == Pathname.new(fixturePath("sample_dir")).isExisting()
        check true == Pathname.new(fixturePath("sample_dir", "" )).isExisting()
        check true == Pathname.new(fixturePath("sample_dir", "", "")).isExisting()

        check true  == Pathname.new(fixturePath("sample_dir", "a_file")).isExisting()
        check false == Pathname.new(fixturePath("sample_dir", "a_file", "" )).isExisting()
        check false == Pathname.new(fixturePath("sample_dir", "a_file", "", "")).isExisting()

        check true  == Pathname.new(fixturePath("sample_dir", "a_file.no2")).isExisting()
        check false == Pathname.new(fixturePath("sample_dir", "a_file.no2", "")).isExisting()
        check false == Pathname.new(fixturePath("sample_dir", "a_file.no2", "", "")).isExisting()

        check false == Pathname.new(fixturePath("NON_EXISTING_FILE")).isExisting()
        check false == Pathname.new(fixturePath("NON_EXISTING_FILE", "" )).isExisting()
        check false == Pathname.new(fixturePath("NON_EXISTING_FILE", "", "")).isExisting()

        check false == Pathname.new(fixturePath("sample_dir", "", "NON_EXISTING_FILE")).isExisting()
        check false == Pathname.new(fixturePath("sample_dir", "", "NON_EXISTING_FILE", "")).isExisting()
        check false == Pathname.new(fixturePath("sample_dir", "", "NON_EXISTING_FILE", "", "")).isExisting()

        check false == Pathname.new(fixturePath("NON_EXISTING_DIR", "", "NON_EXISTING_FILE")).isExisting()
        check false == Pathname.new(fixturePath("NON_EXISTING_DIR", "", "NON_EXISTING_FILE", "")).isExisting()
        check false == Pathname.new(fixturePath("NON_EXISTING_DIR", "", "NON_EXISTING_FILE", "", "")).isExisting()

        when defined(Posix):
            check false == Pathname.new("/NON_EXISTING_FILE"  ).isExisting()
            check false == Pathname.new("/NON_EXISTING_FILE/" ).isExisting()
            check false == Pathname.new("/NON_EXISTING_FILE//").isExisting()

        when defined(Windows):
            check false == Pathname.new("C:\\NON_EXISTING_FILE"    ).isExisting()
            check false == Pathname.new("C:\\NON_EXISTING_FILE\\"  ).isExisting()
            check false == Pathname.new("C:\\NON_EXISTING_FILE\\\\").isExisting()



    test "#isExisting() with directories":
        check true == Pathname.new(fixturePath("sample_dir")).isExisting()
        check true == Pathname.new(fixturePath("sample_dir", "" )).isExisting()
        check true == Pathname.new(fixturePath("sample_dir", "", "")).isExisting()

        check true == Pathname.new(fixturePath("sample_dir", "a_dir")).isExisting()
        check true == Pathname.new(fixturePath("sample_dir", "a_dir", "" )).isExisting()
        check true == Pathname.new(fixturePath("sample_dir", "a_dir", "", "")).isExisting()

        check false == Pathname.new(fixturePath("NON_EXISTING_DIR")).isExisting()
        check false == Pathname.new(fixturePath("NON_EXISTING_DIR", "" )).isExisting()
        check false == Pathname.new(fixturePath("NON_EXISTING_DIR", "", "")).isExisting()

        when defined(Posix):
            check false == Pathname.new("/NON_EXISTING_DIR"  ).isExisting()
            check false == Pathname.new("/NON_EXISTING_DIR/" ).isExisting()
            check false == Pathname.new("/NON_EXISTING_DIR//").isExisting()

        when defined(Windows):
            check false == Pathname.new("C:\\NON_EXISTING_DIR"    ).isExisting()
            check false == Pathname.new("C:\\NON_EXISTING_DIR\\"  ).isExisting()
            check false == Pathname.new("C:\\NON_EXISTING_DIR\\\\").isExisting()



    when defined(Posix):
        test "#isExisting() with device-files":
            check true == Pathname.new("/dev/null"   ).isExisting()
            check true == Pathname.new("/dev/zero"   ).isExisting()
            check true == Pathname.new("/dev/random" ).isExisting()
            check true == Pathname.new("/dev/urandom").isExisting()

            check true == Pathname.new("/dev/loop0").isExisting()
            check true == Pathname.new("/dev/loop1").isExisting()

            check false == Pathname.new("/dev/NON_EXISTING_FILE" ).isExisting()
            check false == Pathname.new("/dev/NON_EXISTING_DIR/" ).isExisting()
            check false == Pathname.new("/dev/NON_EXISTING_DIR//").isExisting()



    when defined(Posix):
        test "#isExisting() with symlink-files":
            check true  == Pathname.new(fixturePath("sample_dir/a_symlink"  )).isExisting()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink/" )).isExisting()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink//")).isExisting()

            check true  == Pathname.new(fixturePath("sample_dir/a_symlink_to_file"  )).isExisting()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/" )).isExisting()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file//")).isExisting()

            check true == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir"  )).isExisting()
            check true == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/" )).isExisting()
            check true == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir//")).isExisting()

            check true  == Pathname.new(fixturePath("sample_dir/a_symlink_to_device"  )).isExisting()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device/" )).isExisting()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device//")).isExisting()

            check true  == Pathname.new(fixturePath("sample_dir/a_symlink_invalid"  )).isExisting()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid/" )).isExisting()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid//")).isExisting()

            check false == Pathname.new("/dev/NON_EXISTING_SYMLINK" ).isExisting()



    when defined(Posix):
        test "#isExisting() with SymLink-Files":
            check true == Pathname.new(fixturePath("sample_dir/a_symlink")).isExisting()



    when defined(Posix):
        test "#isExisting() with Socket-Files":
            check true == Pathname.new("/tmp/.X11-unix/X0").isExisting()



    test "#isNotExisting()":
        check false == Pathname.new(fixturePath("README.md")).isNotExisting()

        check false == Pathname.new(fixturePath("sample_dir")).isNotExisting()
        check false == Pathname.new(fixturePath("sample_dir","")).isNotExisting()
        check false == Pathname.new(fixturePath("sample_dir","","")).isNotExisting()

        check false == Pathname.new(fixturePath("sample_dir","a_file")).isNotExisting()
        check true  == Pathname.new(fixturePath("sample_dir","a_file","")).isNotExisting()
        check true  == Pathname.new(fixturePath("sample_dir","a_file","","")).isNotExisting()

        check false == Pathname.new(fixturePath("sample_dir","a_file.no2")).isNotExisting()
        check true  == Pathname.new(fixturePath("sample_dir","a_file.no2","")).isNotExisting()
        check true  == Pathname.new(fixturePath("sample_dir","a_file.no2","","")).isNotExisting()

        check true == Pathname.new(fixturePath("NON_EXISTING_FILE")).isNotExisting()
        check true == Pathname.new(fixturePath("NON_EXISTING_FILE","")).isNotExisting()
        check true == Pathname.new(fixturePath("NON_EXISTING_FILE","","")).isNotExisting()

        check true == Pathname.new(fixturePath("sample_dir","","NON_EXISTING_FILE")).isNotExisting()
        check true == Pathname.new(fixturePath("sample_dir","","NON_EXISTING_FILE","")).isNotExisting()
        check true == Pathname.new(fixturePath("sample_dir","","NON_EXISTING_FILE","","")).isNotExisting()

        check true == Pathname.new(fixturePath("NON_EXISTING_DIR","","NON_EXISTING_FILE")).isNotExisting()
        check true == Pathname.new(fixturePath("NON_EXISTING_DIR","","NON_EXISTING_FILE","")).isNotExisting()
        check true == Pathname.new(fixturePath("NON_EXISTING_DIR","","NON_EXISTING_FILE","","")).isNotExisting()

        # Socket-File
        when defined(Posix):
            check false == Pathname.new(fixturePath("sample_dir/a_symlink")).isNotExisting()

        # Socket-File
        when defined(Posix):
            check false == Pathname.new("/tmp/.X11-unix/X0").isNotExisting()

        when defined(Posix):
            check true == Pathname.new("/NON_EXISTING_FILE").isNotExisting()
            check true == Pathname.new("/NON_EXISTING_FILE/").isNotExisting()
            check true == Pathname.new("/NON_EXISTING_FILE//").isNotExisting()

        when defined(Windows):
            check true == Pathname.new("C:\\NON_EXISTING_FILE").isNotExisting()
            check true == Pathname.new("C:\\NON_EXISTING_FILE\\").isNotExisting()
            check true == Pathname.new("C:\\NON_EXISTING_FILE\\\\").isNotExisting()



    test "#isUnknownFileType()":
        check false == Pathname.new(fixturePath("sample_dir","a_file"  )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir","a_file","" )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir","a_file","","")).isUnknownFileType()

        check false == Pathname.new(fixturePath("sample_dir"  )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir","" )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir","","")).isUnknownFileType()

        check false == Pathname.new(fixturePath("sample_dir","a_dir"  )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir","a_dir","" )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir","a_dir","","")).isUnknownFileType()

        check false == Pathname.new(fixturePath("sample_dir","a_file.no2"  )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir","a_file.no2","" )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir","a_file.no2","","")).isUnknownFileType()

        check false == Pathname.new(fixturePath("NON_EXISTING_FILE"  )).isUnknownFileType()
        check false == Pathname.new(fixturePath("NON_EXISTING_FILE","" )).isUnknownFileType()
        check false == Pathname.new(fixturePath("NON_EXISTING_FILE","","")).isUnknownFileType()

        when defined(Posix):
            check false == Pathname.new("/dev/null").isUnknownFileType()
            check false == Pathname.new("/dev/zero").isUnknownFileType()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file"  )).isUnknownFileType()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/" )).isUnknownFileType()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file//")).isUnknownFileType()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir"  )).isUnknownFileType()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/" )).isUnknownFileType()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir//")).isUnknownFileType()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device"  )).isUnknownFileType()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device/" )).isUnknownFileType()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device//")).isUnknownFileType()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid"  )).isUnknownFileType()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid/" )).isUnknownFileType()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid//")).isUnknownFileType()

            check false == Pathname.new("/tmp/.X11-unix/X0").isUnknownFileType()



    test "#isRegularFile()":
        check true  == Pathname.new(fixturePath("sample_dir","a_file"  )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir","a_file","" )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir","a_file","","")).isRegularFile()

        check false == Pathname.new(fixturePath("sample_dir"  )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir","" )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir","","")).isRegularFile()

        check false == Pathname.new(fixturePath("sample_dir","a_dir"  )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir","a_dir","" )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir","a_dir","","")).isRegularFile()

        check true  == Pathname.new(fixturePath("sample_dir","a_file.no2"  )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir","a_file.no2","" )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir","a_file.no2","","")).isRegularFile()

        check false == Pathname.new(fixturePath("NON_EXISTING_FILE"  )).isRegularFile()
        check false == Pathname.new(fixturePath("NON_EXISTING_FILE","" )).isRegularFile()
        check false == Pathname.new(fixturePath("NON_EXISTING_FILE","","")).isRegularFile()

        when defined(Posix):
            check false == Pathname.new("/dev/null").isRegularFile()
            check false == Pathname.new("/dev/zero").isRegularFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file"  )).isRegularFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/" )).isRegularFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file//")).isRegularFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir"  )).isRegularFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/" )).isRegularFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir//")).isRegularFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device"  )).isRegularFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device/" )).isRegularFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device//")).isRegularFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid"  )).isRegularFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid/" )).isRegularFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid//")).isRegularFile()

            check false == Pathname.new("/tmp/.X11-unix/X0").isRegularFile()



    test "#isDirectory()":
        check true  == Pathname.new(fixturePath("sample_dir"  )).isDirectory()
        check true  == Pathname.new(fixturePath("sample_dir/" )).isDirectory()
        check true  == Pathname.new(fixturePath("sample_dir//")).isDirectory()

        check true  == Pathname.new(fixturePath("sample_dir/a_dir"  )).isDirectory()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir/" )).isDirectory()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir//")).isDirectory()

        check false == Pathname.new(fixturePath("sample_dir/a_file"  )).isDirectory()
        check false == Pathname.new(fixturePath("sample_dir/a_file/" )).isDirectory()
        check false == Pathname.new(fixturePath("sample_dir/a_file//")).isDirectory()

        check false == Pathname.new(fixturePath("sample_dir/a_file.no2"  )).isDirectory()
        check false == Pathname.new(fixturePath("sample_dir/a_file.no2/" )).isDirectory()
        check false == Pathname.new(fixturePath("sample_dir/a_file.no2//")).isDirectory()

        check false == Pathname.new(fixturePath("NON_EXISTING_DIR"  )).isDirectory()
        check false == Pathname.new(fixturePath("NON_EXISTING_DIR/" )).isDirectory()
        check false == Pathname.new(fixturePath("NON_EXISTING_DIR//")).isDirectory()

        when defined(Posix):
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file"  )).isDirectory()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/" )).isDirectory()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file//")).isDirectory()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir"  )).isDirectory()
            check true  == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/" )).isDirectory()
            check true  == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir//")).isDirectory()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device"  )).isDirectory()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device/" )).isDirectory()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device//")).isDirectory()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid"  )).isDirectory()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid/" )).isDirectory()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid//")).isDirectory()

            check false == Pathname.new("/tmp/.X11-unix/X0").isDirectory()



    test "#isSymlink()":
        when defined(Posix):
            check true  == Pathname.new(fixturePath("sample_dir/a_symlink"  )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink/" )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink//")).isSymlink()

            check true  == Pathname.new(fixturePath("sample_dir/a_symlink_to_file"  )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/" )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file//")).isSymlink()

            check true  == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir"  )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/" )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir//")).isSymlink()

            check true  == Pathname.new(fixturePath("sample_dir/a_symlink_to_device"  )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device/" )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device//")).isSymlink()

            check true  == Pathname.new(fixturePath("sample_dir/a_symlink_to_char_device"  )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_char_device/" )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_char_device//")).isSymlink()

            check true  == Pathname.new(fixturePath("sample_dir/a_symlink_to_block_device"  )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_block_device/" )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_block_device//")).isSymlink()

            check true  == Pathname.new(fixturePath("sample_dir/a_symlink_invalid"  )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid/" )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid//")).isSymlink()

            check false == Pathname.new(fixturePath("sample_dir"  )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/" )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir//")).isSymlink()

            check false == Pathname.new(fixturePath("sample_dir/a_dir"  )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_dir/" )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_dir//")).isSymlink()

            check false == Pathname.new(fixturePath("sample_dir/a_file"  )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_file/" )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_file//")).isSymlink()

            check false == Pathname.new(fixturePath("sample_dir/a_file.no2"  )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_file.no2/" )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir/a_file.no2//")).isSymlink()

            check false == Pathname.new(fixturePath("NON_EXISTING_DIR"  )).isSymlink()
            check false == Pathname.new(fixturePath("NON_EXISTING_DIR/" )).isSymlink()
            check false == Pathname.new(fixturePath("NON_EXISTING_DIR//")).isSymlink()

            check false == Pathname.new("/tmp/.X11-unix/X0").isSymlink()

        when defined(Windows):
            check false == Pathname.new(fixturePath("sample_dir"  )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir\\" )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir\\\\")).isSymlink()

            check false == Pathname.new(fixturePath("sample_dir\\a_dir"  )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir\\" )).isSymlink()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir\\\\")).isSymlink()



    test "#isDeviceFile()":
        when defined(Posix):
            check false == Pathname.new(fixturePath("sample_dir/a_file")).isDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir"       )).isDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/"      )).isDeviceFile()

            check true == Pathname.new("/dev/null"   ).isDeviceFile()
            check true == Pathname.new("/dev/zero"   ).isDeviceFile()
            check true == Pathname.new("/dev/random" ).isDeviceFile()
            check true == Pathname.new("/dev/urandom").isDeviceFile()

            check true == Pathname.new("/dev/loop0").isDeviceFile()
            check true == Pathname.new("/dev/loop1").isDeviceFile()

            check false == Pathname.new("/dev/NON_EXISTING"  ).isDeviceFile()
            check false == Pathname.new("/dev/NON_EXISTING/" ).isDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file"  )).isDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/" )).isDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir"  )).isDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/" )).isDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device"  )).isDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device/" )).isDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_char_device"  )).isDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_char_device/" )).isDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_block_device"  )).isDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_block_device/" )).isDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid"  )).isDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid/" )).isDeviceFile()

            check false == Pathname.new("/tmp/.X11-unix/X0").isDeviceFile()

        when defined(Windows):
            check false == Pathname.new(fixturePath("sample_dir\\a_file")).isDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir"        )).isDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir\\"      )).isDeviceFile()



    test "#isCharacterDeviceFile()":
        when defined(Posix):
            check false == Pathname.new(fixturePath("sample_dir/a_file")).isCharacterDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir"       )).isCharacterDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/"      )).isCharacterDeviceFile()

            check true == Pathname.new("/dev/null"   ).isCharacterDeviceFile()
            check true == Pathname.new("/dev/zero"   ).isCharacterDeviceFile()
            check true == Pathname.new("/dev/random" ).isCharacterDeviceFile()
            check true == Pathname.new("/dev/urandom").isCharacterDeviceFile()

            check false == Pathname.new("/dev/loop0").isCharacterDeviceFile()
            check false == Pathname.new("/dev/loop1").isCharacterDeviceFile()

            check false == Pathname.new("/dev/NON_EXISTING"  ).isCharacterDeviceFile()
            check false == Pathname.new("/dev/NON_EXISTING/" ).isCharacterDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file"  )).isCharacterDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/" )).isCharacterDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir"  )).isCharacterDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/" )).isCharacterDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device"  )).isCharacterDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device/" )).isCharacterDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_char_device"  )).isCharacterDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_char_device/" )).isCharacterDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_block_device"  )).isCharacterDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_block_device/" )).isCharacterDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid"  )).isCharacterDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid/" )).isCharacterDeviceFile()

            check false == Pathname.new("/tmp/.X11-unix/X0").isCharacterDeviceFile()

        when defined(Windows):
            check false == Pathname.new(fixturePath("sample_dir\\a_file")).isCharacterDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir"        )).isCharacterDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir\\"      )).isCharacterDeviceFile()



    test "#isBlockDeviceFile()":
        when defined(Posix):
            check false == Pathname.new(fixturePath("sample_dir/a_file")).isBlockDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir"       )).isBlockDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/"      )).isBlockDeviceFile()

            check false == Pathname.new("/dev/null"   ).isBlockDeviceFile()
            check false == Pathname.new("/dev/zero"   ).isBlockDeviceFile()
            check false == Pathname.new("/dev/random" ).isBlockDeviceFile()
            check false == Pathname.new("/dev/urandom").isBlockDeviceFile()

            check true == Pathname.new("/dev/loop0").isBlockDeviceFile()
            check true == Pathname.new("/dev/loop1").isBlockDeviceFile()

            check false == Pathname.new("/dev/NON_EXISTING"  ).isBlockDeviceFile()
            check false == Pathname.new("/dev/NON_EXISTING/" ).isBlockDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file"  )).isBlockDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/" )).isBlockDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir"  )).isBlockDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/" )).isBlockDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device"  )).isBlockDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device/" )).isBlockDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_char_device"  )).isBlockDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_char_device/" )).isBlockDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_block_device"  )).isBlockDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_block_device/" )).isBlockDeviceFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid"  )).isBlockDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid/" )).isBlockDeviceFile()

            check false == Pathname.new("/tmp/.X11-unix/X0").isBlockDeviceFile()

        when defined(Windows):
            check false == Pathname.new(fixturePath("sample_dir\\a_file")).isBlockDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir"        )).isBlockDeviceFile()
            check false == Pathname.new(fixturePath("sample_dir\\"      )).isBlockDeviceFile()



    test "#isSocketFile()":
        when defined(Posix):
            check true == Pathname.new("/tmp/.X11-unix/X0").isSocketFile()

            check false == Pathname.new(fixturePath("sample_dir/a_file"  )).isSocketFile()
            check false == Pathname.new(fixturePath("sample_dir/a_file/" )).isSocketFile()

            check false == Pathname.new(fixturePath("sample_dir"  )).isSocketFile()
            check false == Pathname.new(fixturePath("sample_dir/" )).isSocketFile()

            check false == Pathname.new(fixturePath("sample_dir/a_dir"  )).isSocketFile()
            check false == Pathname.new(fixturePath("sample_dir/a_dir/" )).isSocketFile()

            check false == Pathname.new(fixturePath("sample_dir/a_file.no2"  )).isSocketFile()
            check false == Pathname.new(fixturePath("sample_dir/a_file.no2/" )).isSocketFile()

            check false == Pathname.new(fixturePath("NON_EXISTING_FILE"  )).isSocketFile()
            check false == Pathname.new(fixturePath("NON_EXISTING_FILE/" )).isSocketFile()

            check false == Pathname.new("/dev/null").isSocketFile()
            check false == Pathname.new("/dev/zero").isSocketFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file"  )).isSocketFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/" )).isSocketFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir"  )).isSocketFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/" )).isSocketFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device"  )).isSocketFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device/" )).isSocketFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid"  )).isSocketFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid/" )).isSocketFile()

        when defined(Windows):
            check false == Pathname.new(fixturePath("sample_dir\\a_file"   )).isSocketFile()
            check false == Pathname.new(fixturePath("sample_dir\\a_file\\" )).isSocketFile()
            check false == Pathname.new(fixturePath("sample_dir"   )).isSocketFile()
            check false == Pathname.new(fixturePath("sample_dir\\" )).isSocketFile()



    test "#isPipeFile()":
        when defined(Posix):
            discard posix.mkfifo( fixturePath("sample_dir/a_pipe").cstring, 0o600)
            check true == Pathname.new(fixturePath("sample_dir/a_pipe")).isPipeFile()
            discard posix.unlink( fixturePath("sample_dir/a_pipe").cstring )

        when defined(Posix):
            check false == Pathname.new(fixturePath("sample_dir/a_file" )).isPipeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_file/")).isPipeFile()

            check false == Pathname.new(fixturePath("sample_dir"  )).isPipeFile()
            check false == Pathname.new(fixturePath("sample_dir/" )).isPipeFile()

            check false == Pathname.new(fixturePath("sample_dir/a_dir"  )).isPipeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_dir/" )).isPipeFile()

            check false == Pathname.new(fixturePath("sample_dir/a_file.no2"  )).isPipeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_file.no2/" )).isPipeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_file.no2//")).isPipeFile()

            check false == Pathname.new(fixturePath("NON_EXISTING_FILE"  )).isPipeFile()
            check false == Pathname.new(fixturePath("NON_EXISTING_FILE/" )).isPipeFile()

            check false == Pathname.new("/dev/null").isPipeFile()
            check false == Pathname.new("/dev/zero").isPipeFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file"  )).isPipeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/" )).isPipeFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir"  )).isPipeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/" )).isPipeFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device"  )).isPipeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device/" )).isPipeFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid"  )).isPipeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid/" )).isPipeFile()

            check false == Pathname.new("/tmp/.X11-unix/X0").isPipeFile()

        when defined(Windows):
            check false == Pathname.new(fixturePath("sample_dir\\a_file"  )).isPipeFile()
            check false == Pathname.new(fixturePath("sample_dir\\a_file\\")).isPipeFile()

            check false == Pathname.new(fixturePath("sample_dir"   )).isPipeFile()
            check false == Pathname.new(fixturePath("sample_dir\\" )).isPipeFile()



    test "#isHidden()":
        when defined(Posix):
            check true == Pathname.new(fixturePath("sample_dir/.a_hidden_file")).isHidden()
            check true == Pathname.new(fixturePath("sample_dir/.a_hidden_dir")).isHidden()
            check true == Pathname.new(fixturePath("sample_dir/.a_hidden_dir/.keep")).isHidden()

            check false == Pathname.new(fixturePath("sample_dir/a_file")).isHidden()
            check false == Pathname.new(fixturePath("sample_dir/a_dir")).isHidden()
            check false == Pathname.new(fixturePath("sample_dir/NOT_EXISTING")).isHidden()

            check false == Pathname.new(fixturePath("sample_dir/.NOT_EXISTING")).isHidden()

        when defined(Windows):
            check true == Pathname.new(fixturePath("sample_dir\\.a_hidden_file")).isHidden()
            check true == Pathname.new(fixturePath("sample_dir\\.a_hidden_dir")).isHidden()
            check true == Pathname.new(fixturePath("sample_dir\\.a_hidden_dir\\.keep")).isHidden()

            check false == Pathname.new(fixturePath("sample_dir\\a_file")).isHidden()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir")).isHidden()
            check false == Pathname.new(fixturePath("sample_dir\\NOT_EXISTING")).isHidden()

            check false == Pathname.new(fixturePath("sample_dir\\.NOT_EXISTING")).isHidden()



    test "#isVisible()":
        when defined(Posix):
            check true  == Pathname.new(fixturePath("sample_dir/a_file")).isVisible()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir")).isVisible()

            check false == Pathname.new(fixturePath("sample_dir/.a_hidden_file")).isVisible()
            check false == Pathname.new(fixturePath("sample_dir/.a_hidden_dir")).isVisible()
            check false == Pathname.new(fixturePath("sample_dir/.a_hidden_dir/.keep")).isVisible()
            check false == Pathname.new(fixturePath("sample_dir/NOT_EXISTING")).isVisible()
            check false == Pathname.new(fixturePath("sample_dir/.NOT_EXISTING")).isVisible()

        when defined(Windows):
            check true  == Pathname.new(fixturePath("sample_dir\\a_file")).isVisible()
            check true  == Pathname.new(fixturePath("sample_dir\\a_dir")).isVisible()

            check false == Pathname.new(fixturePath("sample_dir\\.a_hidden_file")).isVisible()
            check false == Pathname.new(fixturePath("sample_dir\\.a_hidden_dir")).isVisible()
            check false == Pathname.new(fixturePath("sample_dir\\.a_hidden_dir\\.keep")).isVisible()
            check false == Pathname.new(fixturePath("sample_dir\\NOT_EXISTING")).isVisible()
            check false == Pathname.new(fixturePath("sample_dir\\.NOT_EXISTING")).isVisible()


    test "#isZeroSizeFile()":
        when defined(Posix):
            check true  == Pathname.new(fixturePath("sample_dir/a_file" )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_file/")).isZeroSizeFile()

            check false == Pathname.new(fixturePath("README.md")).isZeroSizeFile()

            check false == Pathname.new(fixturePath("sample_dir"  )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/" )).isZeroSizeFile()

            check false == Pathname.new(fixturePath("sample_dir/a_dir"  )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_dir/" )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_dir//")).isZeroSizeFile()

            check true  == Pathname.new(fixturePath("sample_dir/a_file.no2"  )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_file.no2/" )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_file.no2//")).isZeroSizeFile()

            check false == Pathname.new(fixturePath("NON_EXISTING_FILE"  )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("NON_EXISTING_FILE/" )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("NON_EXISTING_FILE//")).isZeroSizeFile()

            check false == Pathname.new("/dev/null").isZeroSizeFile()
            check false == Pathname.new("/dev/zero").isZeroSizeFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file"  )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/" )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_file//")).isZeroSizeFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir"  )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/" )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir//")).isZeroSizeFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device"  )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device/" )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_device//")).isZeroSizeFile()

            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid"  )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid/" )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir/a_symlink_invalid//")).isZeroSizeFile()

        when defined(Windows):
            check true  == Pathname.new(fixturePath("sample_dir\\a_file"  )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir\\a_file\\")).isZeroSizeFile()

            check false == Pathname.new(fixturePath("README.md")).isZeroSizeFile()

            check false == Pathname.new(fixturePath("sample_dir"  )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir\\" )).isZeroSizeFile()

            check false == Pathname.new(fixturePath("sample_dir\\a_dir"  )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir\\" )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir\\\\")).isZeroSizeFile()

            check true  == Pathname.new(fixturePath("sample_dir\\a_file.no2"  )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir\\a_file.no2\\" )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("sample_dir\\a_file.no2\\\\")).isZeroSizeFile()

            check false == Pathname.new(fixturePath("NON_EXISTING_FILE"  )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("NON_EXISTING_FILE\\" )).isZeroSizeFile()
            check false == Pathname.new(fixturePath("NON_EXISTING_FILE\\\\")).isZeroSizeFile()



    test "#fileSizeInBytes()":
        when defined(Posix):
            check 0    == Pathname.new(fixturePath("sample_dir/a_file")).fileSizeInBytes()
            check 4096 == Pathname.new(fixturePath("sample_dir/a_dir" )).fileSizeInBytes()
            ## When needs update -> change to a file with fixed file size ...
            check 122 == Pathname.new(fixturePath("README.md")).fileSizeInBytes()

        when defined(Windows):
            check 0 == Pathname.new(fixturePath("sample_dir\\a_file")).fileSizeInBytes()
            check 0 == Pathname.new(fixturePath("sample_dir\\a_dir")).fileSizeInBytes()
            ## When needs update -> change to a file with fixed file size ...
            check 122 == Pathname.new(fixturePath("README.md")).fileSizeInBytes()



    test "#ioBlockSizeInBytes()":
        when defined(Posix):
            check 4096 == Pathname.new(fixturePath("sample_dir/a_file")).ioBlockSizeInBytes()
            check 4096 == Pathname.new(fixturePath("sample_dir/a_dir")).ioBlockSizeInBytes()
            ## When needs update -> change to a file with fixed file size ...
            check 4096 == Pathname.new(fixturePath("README.md")).ioBlockSizeInBytes()

        when defined(Windows):
            check -1 == Pathname.new(fixturePath("sample_dir/a_file")).ioBlockSizeInBytes()
            check -1 == Pathname.new(fixturePath("sample_dir/a_dir")).ioBlockSizeInBytes()
            check -1 == Pathname.new(fixturePath("README.md")).ioBlockSizeInBytes()



    test "#ioBlockCount()":
        when defined(Posix):
            check 0 == Pathname.new(fixturePath("sample_dir/a_file")).ioBlockCount()
            check 8 == Pathname.new(fixturePath("sample_dir/a_dir")).ioBlockCount()
            ## When needs update -> change to a file with fixed file size ...
            check 8 == Pathname.new(fixturePath("README.md")).ioBlockCount()

        when defined(Windows):
            check -1 == Pathname.new(fixturePath("sample_dir/a_file")).ioBlockCount()
            check -1 == Pathname.new(fixturePath("sample_dir/a_dir")).ioBlockCount()
            check -1 == Pathname.new(fixturePath("README.md")).ioBlockCount()



    test "#userId()":
        when defined(Posix):
            check 0    == Pathname.new("/").userId()
            check 1000 == Pathname.new(fixturePath("sample_dir/a_file")).userId()
            check -1   == Pathname.new(fixturePath("sample_dir/NOT_EXISTING")).userId()

        when defined(Windows):
            check -1 == Pathname.new("C:").userId()
            check -1 == Pathname.new(fixturePath("sample_dir\\a_file")).userId()
            check -1  == Pathname.new(fixturePath("sample_dir\\NOT_EXISTING")).userId()



    test "#groupId()":
        when defined(Posix):
            check 0    == Pathname.new("/").groupId()
            check 1000 == Pathname.new(fixturePath("sample_dir/a_file")).groupId()
            check -1   == Pathname.new(fixturePath("sample_dir/NOT_EXISTING")).groupId()

        when defined(Windows):
            check -1 == Pathname.new("/").groupId()
            check -1 == Pathname.new(fixturePath("sample_dir\\a_file")).groupId()
            check -1 == Pathname.new(fixturePath("sample_dir\\NOT_EXISTING")).groupId()



    test "#countHardlinks()":
        when defined(Posix):
            check 1 == Pathname.new(fixturePath("sample_dir/a_file")).countHardlinks()

        when defined(Windows):
            check 1 == Pathname.new(fixturePath("sample_dir\\a_file")).countHardlinks()



    test "#hasSetUidBit()":
        when defined(Posix):
            check true  == Pathname.new("/bin/su").hasSetUidBit()
            check false == Pathname.new(fixturePath("sample_dir/a_file" )).hasSetUidBit()
            check false == Pathname.new(fixturePath("sample_dir/a_dir"  )).hasSetUidBit()

        when defined(Windows):
            check false == Pathname.new(fixturePath("sample_dir\\a_file" )).hasSetUidBit()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir"  )).hasSetUidBit()


    test "#hasSetGidBit()":
        when defined(Posix):
            check true  == Pathname.new("/usr/bin/wall").hasSetGidBit()
            check false == Pathname.new(fixturePath("sample_dir/a_file" )).hasSetGidBit()
            check false == Pathname.new(fixturePath("sample_dir/a_dir"  )).hasSetGidBit()

        when defined(Windows):
            check false == Pathname.new(fixturePath("sample_dir\\a_file" )).hasSetGidBit()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir"  )).hasSetGidBit()



    test "#hasStickyBit()":
        when defined(Posix):
            check true  == Pathname.new("/tmp").hasStickyBit()
            check false == Pathname.new(fixturePath("sample_dir/a_file" )).hasStickyBit()
            check false == Pathname.new(fixturePath("sample_dir/a_dir"  )).hasStickyBit()

        when defined(Windows):
            check false == Pathname.new(fixturePath("sample_dir\\a_file" )).hasStickyBit()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir"  )).hasStickyBit()



    test "#getLastAccessTime()":
        let maxTime = times.getTime()
        let minTime = times.parse("2020-01-13", "yyyy-MM-dd").toTime()

        check maxTime >= minTime

        check maxTime >= Pathname.new(fixturePath("sample_dir/a_file" )).getLastAccessTime()
        check minTime <= Pathname.new(fixturePath("sample_dir/a_file" )).getLastAccessTime()

        check maxTime >= Pathname.new(fixturePath("sample_dir/a_dir")).getLastAccessTime()
        check minTime <= Pathname.new(fixturePath("sample_dir/a_dir")).getLastAccessTime()



    test "#getLastChangeTime()":
        let maxTime = times.getTime()
        let minTime = times.parse("2020-01-13", "yyyy-MM-dd").toTime()

        check maxTime >= minTime

        check maxTime >= Pathname.new(fixturePath("sample_dir","a_file" )).getLastChangeTime()
        check minTime <= Pathname.new(fixturePath("sample_dir","a_file" )).getLastChangeTime()

        check maxTime >= Pathname.new(fixturePath("sample_dir","a_dir")).getLastChangeTime()
        check minTime <= Pathname.new(fixturePath("sample_dir","a_dir")).getLastChangeTime()



    test "#getLastStatusChangeTime()":
        let maxTime = times.getTime()
        let minTime = times.parse("2020-01-13", "yyyy-MM-dd").toTime()

        check maxTime >= minTime

        check maxTime >= Pathname.new(fixturePath("sample_dir","a_file" )).getLastStatusChangeTime()
        check minTime <= Pathname.new(fixturePath("sample_dir","a_file" )).getLastStatusChangeTime()

        check maxTime >= Pathname.new(fixturePath("sample_dir","a_dir")).getLastStatusChangeTime()
        check minTime <= Pathname.new(fixturePath("sample_dir","a_dir")).getLastStatusChangeTime()



    test "#isUserOwned()":
        when defined(Posix):
            check true == Pathname.new(fixturePath("sample_dir/a_file")).isUserOwned()
            check true == Pathname.new(fixturePath("sample_dir/a_dir" )).isUserOwned()

            check false == Pathname.new("/"   ).isUserOwned()
            check false == Pathname.new("/tmp").isUserOwned()

        when defined(Windows):
            check false == Pathname.new(fixturePath("sample_dir\\a_file")).isUserOwned()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir" )).isUserOwned()

            check false == Pathname.new("C:").isUserOwned()



    test "#isGroupOwned()":
        when defined(Posix):
            check true == Pathname.new(fixturePath("sample_dir/a_file")).isGroupOwned()
            check true == Pathname.new(fixturePath("sample_dir/a_dir" )).isGroupOwned()

            check false == Pathname.new("/"   ).isGroupOwned()
            check false == Pathname.new("/tmp").isGroupOwned()

        when defined(Windows):
            check false == Pathname.new(fixturePath("sample_dir\\a_file")).isGroupOwned()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir" )).isGroupOwned()

            check false == Pathname.new("C:").isGroupOwned()


    test "#isGroupMember()":
        when defined(Posix):
            check true == Pathname.new(fixturePath("sample_dir/a_file")).isGroupMember()
            check true == Pathname.new(fixturePath("sample_dir/a_dir" )).isGroupMember()

            check false == Pathname.new("/"   ).isGroupMember()
            check false == Pathname.new("/tmp").isGroupMember()

        when defined(Posix):
            check false == Pathname.new(fixturePath("sample_dir\\a_file")).isGroupMember()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir" )).isGroupMember()

            check false == Pathname.new("C:").isGroupMember()



    test "#isReadable()":
        when defined(Posix):
            check false == Pathname.new("/var/log/syslog").isReadable()
            check true  == Pathname.new(fixturePath("sample_dir/a_file")).isReadable()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isReadable()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isReadable()

        when defined(Windows):
            check true  == Pathname.new("C:").isReadable()
            check true  == Pathname.new(fixturePath("sample_dir\\a_file")).isReadable()
            check true  == Pathname.new(fixturePath("sample_dir\\a_dir" )).isReadable()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isReadable()



    test "#isReadableByUser()":
        when defined(Posix):
            check false == Pathname.new("/var/log/syslog").isReadableByUser()
            check true  == Pathname.new(fixturePath("sample_dir/a_file")).isReadableByUser()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isReadableByUser()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isReadableByUser()

        when defined(Windows):
            check true  == Pathname.new("C:").isReadableByUser()
            check true  == Pathname.new(fixturePath("sample_dir\\a_file")).isReadableByUser()
            check true  == Pathname.new(fixturePath("sample_dir\\a_dir" )).isReadableByUser()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isReadableByUser()



    test "#isReadableByGroup()":
        when defined(Posix):
            check false == Pathname.new("/var/log/syslog").isReadableByGroup()
            check true  == Pathname.new(fixturePath("sample_dir/a_file")).isReadableByGroup()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isReadableByGroup()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isReadableByGroup()

        when defined(Windows):
            check true  == Pathname.new("C:").isReadableByGroup()
            check true  == Pathname.new(fixturePath("sample_dir\\a_file")).isReadableByGroup()
            check true  == Pathname.new(fixturePath("sample_dir\\a_dir" )).isReadableByGroup()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isReadableByGroup()



    test "#isReadableByOther()":
        when defined(Posix):
            check false == Pathname.new("/var/log/syslog").isReadableByOther()
            check true  == Pathname.new(fixturePath("sample_dir/a_file")).isReadableByOther()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isReadableByOther()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isReadableByOther()

        when defined(Windows):
            check true  == Pathname.new("C:").isReadableByOther()
            check true  == Pathname.new(fixturePath("sample_dir\\a_file")).isReadableByOther()
            check true  == Pathname.new(fixturePath("sample_dir\\a_dir" )).isReadableByOther()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isReadableByOther()



    test "#isWritable()":
        when defined(Posix):
            check false == Pathname.new("/var/log/syslog").isWritable()
            check true  == Pathname.new(fixturePath("sample_dir/a_file")).isWritable()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isWritable()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isWritable()

        when defined(Windows):
            check true  == Pathname.new("C:").isWritable()
            check true  == Pathname.new(fixturePath("sample_dir\\a_file")).isWritable()
            check true  == Pathname.new(fixturePath("sample_dir\\a_dir" )).isWritable()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isWritable()



    test "#isWritableByUser()":
        when defined(Posix):
            check false == Pathname.new("/var/log/syslog").isWritableByUser()
            check true  == Pathname.new(fixturePath("sample_dir/a_file")).isWritableByUser()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isWritableByUser()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isWritableByUser()

        when defined(Windows):
            check true  == Pathname.new("C:").isWritableByUser()
            check true  == Pathname.new(fixturePath("sample_dir\\a_file")).isWritableByUser()
            check true  == Pathname.new(fixturePath("sample_dir\\a_dir" )).isWritableByUser()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isWritableByUser()



    test "#isWritableByGroup()":
        when defined(Posix):
            check false == Pathname.new("/var/log/syslog").isWritableByGroup()
            check false == Pathname.new(fixturePath("sample_dir/a_file")).isWritableByGroup()
            check false == Pathname.new(fixturePath("sample_dir/a_dir" )).isWritableByGroup()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isWritableByGroup()

        when defined(Windows):
            check true  == Pathname.new("C:").isWritableByGroup()
            check true  == Pathname.new(fixturePath("sample_dir\\a_file")).isWritableByGroup()
            check true  == Pathname.new(fixturePath("sample_dir\\a_dir" )).isWritableByGroup()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isWritableByGroup()



    test "#isWritableByOther()":
        when defined(Posix):
            check false == Pathname.new("/var/log/syslog"               ).isWritableByOther()
            check false == Pathname.new(fixturePath("sample_dir/a_file")).isWritableByOther()
            check false == Pathname.new(fixturePath("sample_dir/a_dir" )).isWritableByOther()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isWritableByOther()

        when defined(Windows):
            check true  == Pathname.new("C:").isWritableByOther()
            check true  == Pathname.new(fixturePath("sample_dir\\a_file")).isWritableByOther()
            check true  == Pathname.new(fixturePath("sample_dir\\a_dir" )).isWritableByOther()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isWritableByOther()



    test "#isExecutable()":
        when defined(Posix):
            check true  == Pathname.new("/bin/cat").isExecutable()
            check false == Pathname.new(fixturePath("sample_dir/a_file")).isExecutable()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isExecutable()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isExecutable()

        when defined(Windows):
            check true  == Pathname.new("C:\\windows\\notepad.exe").isExecutable()
            check false == Pathname.new("C:\\windows\\system.ini").isExecutable()
            check false == Pathname.new("C:").isExecutable()
            check false == Pathname.new(fixturePath("sample_dir\\a_file")).isExecutable()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir" )).isExecutable()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isExecutable()


    test "#isExecutableByUser()":
        when defined(Posix):
            check false == Pathname.new("/bin/cat").isExecutableByUser()
            check false == Pathname.new(fixturePath("sample_dir/a_file")).isExecutableByUser()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isExecutableByUser()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isExecutableByUser()

        when defined(Windows):
            check true  == Pathname.new("C:\\windows\\notepad.exe").isExecutableByUser()
            check false == Pathname.new("C:\\windows\\system.ini").isExecutableByUser()
            check false == Pathname.new("C:").isExecutableByUser()
            check false == Pathname.new(fixturePath("sample_dir\\a_file")).isExecutableByUser()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir" )).isExecutableByUser()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isExecutableByUser()



    test "#isExecutableByGroup()":
        when defined(Posix):
            check false == Pathname.new("/bin/cat").isExecutableByGroup()
            check false == Pathname.new(fixturePath("sample_dir/a_file")).isExecutableByGroup()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isExecutableByGroup()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isExecutableByGroup()

        when defined(Windows):
            check true  == Pathname.new("C:\\windows\\notepad.exe").isExecutableByGroup()
            check false == Pathname.new("C:\\windows\\system.ini").isExecutableByGroup()
            check false == Pathname.new("C:").isExecutableByGroup()
            check false == Pathname.new(fixturePath("sample_dir\\a_file")).isExecutableByGroup()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir" )).isExecutableByGroup()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isExecutableByGroup()



    test "#isExecutableByOther()":
        when defined(Posix):
            check true  == Pathname.new("/bin/cat"                      ).isExecutableByOther()
            check false == Pathname.new(fixturePath("sample_dir/a_file")).isExecutableByOther()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isExecutableByOther()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isExecutableByOther()

        when defined(Windows):
            check true  == Pathname.new("C:\\windows\\notepad.exe").isExecutableByOther()
            check false == Pathname.new("C:\\windows\\system.ini").isExecutableByOther()
            check false == Pathname.new("C:").isExecutableByOther()
            check false == Pathname.new(fixturePath("sample_dir\\a_file")).isExecutableByOther()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir" )).isExecutableByOther()
            check false == Pathname.new(fixturePath("NOT_EXISTENT")).isExecutableByOther()



    test "#isMountpoint()":
        when defined(Posix):
            check true  == Pathname.new("/").isMountpoint()
            check true  == Pathname.new("//").isMountpoint()
            check true  == Pathname.new("/proc" ).isMountpoint()
            check true  == Pathname.new("/proc/").isMountpoint()
            check true  == Pathname.new("/sys" ).isMountpoint()
            check true  == Pathname.new("/sys/").isMountpoint()

            check false == Pathname.new("/bin"    ).isMountpoint()
            check false == Pathname.new("/etc"    ).isMountpoint()
            check false == Pathname.new("/bin/cat").isMountpoint()

        when defined(Windows):
            check false == Pathname.new("C:").isMountpoint()
            check false == Pathname.new("C:\\").isMountpoint()
            check false == Pathname.new("C:\\windows").isMountpoint()
            check false == Pathname.new("C:\\windows\\").isMountpoint()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname#fileInfo()
#-----------------------------------------------------------------------------------------------------------------------



    test "#fileInfo()":
        check pcFile == Pathname.new(fixturePath("sample_dir","a_file")).fileInfo().kind
        check pcDir  == Pathname.new(fixturePath("sample_dir","a_dir" )).fileInfo().kind

        try:
            discard Pathname.new(fixturePath("NOT_EXISTENT")).fileInfo().kind
            fail
        except OSError:
            discard

        when defined(Posix):
            check pcLinkToFile == Pathname.new(fixturePath("sample_dir","a_symlink_to_file")).fileInfo().kind
            check pcLinkToDir  == Pathname.new(fixturePath("sample_dir","a_symlink_to_dir" )).fileInfo().kind
            check pcDir        == Pathname.new(fixturePath("sample_dir","a_symlink_to_dir","")).fileInfo().kind

            check pcDir  == Pathname.new("/").fileInfo().kind
            check pcFile == Pathname.new("/dev/null" ).fileInfo().kind
            check pcFile == Pathname.new("/dev/loop0").fileInfo().kind

        when defined(Windows):
            check pcDir  == Pathname.new("C:").fileInfo().kind
            check pcDir  == Pathname.new("C:\\windows").fileInfo().kind
            check pcFile == Pathname.new("C:\\windows\\notepad.exe").fileInfo().kind



#-----------------------------------------------------------------------------------------------------------------------
# Pathname#fileStatus()
#-----------------------------------------------------------------------------------------------------------------------



    test "#fileStatus().fileType()":
        when true: # Common
            check FileType.REGULAR_FILE == Pathname.new(fixturePath("sample_dir","a_file")).fileStatus().fileType()
            check FileType.DIRECTORY    == Pathname.new(fixturePath("sample_dir","a_dir" )).fileStatus().fileType()
            check FileType.NOT_EXISTING == Pathname.new(fixturePath("NON_EXISTING_FILE"  )).fileStatus().fileType()
            check FileType.NOT_EXISTING == Pathname.new(fixturePath("NON_EXISTING_FILE/" )).fileStatus().fileType()

        when defined(Posix):
            check FileType.SYMLINK      == Pathname.new(fixturePath("sample_dir/a_symlink_to_file" )).fileStatus().fileType()
            check FileType.NOT_EXISTING == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/")).fileStatus().fileType()

            check FileType.SYMLINK   == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir" )).fileStatus().fileType()
            check FileType.DIRECTORY == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/")).fileStatus().fileType()

            check FileType.CHARACTER_DEVICE == Pathname.new("/dev/null").fileStatus().fileType()

            check FileType.BLOCK_DEVICE == Pathname.new("/dev/loop0").fileStatus().fileType()

            check FileType.SOCKET_FILE == Pathname.new("/tmp/.X11-unix/X0").fileStatus().fileType()

            discard posix.mkfifo( fixturePath("sample_dir/a_pipe").cstring, 0o600)
            check FileType.PIPE_FILE == Pathname.new(fixturePath("sample_dir/a_pipe")).fileStatus().fileType()
            discard posix.unlink( fixturePath("sample_dir/a_pipe").cstring )



    test "#fileStatus() - Sample00":
        when true: # Common
            check true == Pathname.new(fixturePath("sample_dir","a_file")).fileStatus().isRegularFile()
            check true == Pathname.new(fixturePath("sample_dir","a_dir" )).fileStatus().isDirectory()

            check true == Pathname.new(fixturePath("NON_EXISTING_FILE"   )).fileStatus().isNotExisting()
            check true == Pathname.new(fixturePath("NON_EXISTING_FILE","")).fileStatus().isNotExisting()

            check true == Pathname.new(fixturePath("sample_dir","NON_EXISTING_FILE"   )).fileStatus().isNotExisting()
            check true == Pathname.new(fixturePath("sample_dir","NON_EXISTING_FILE","")).fileStatus().isNotExisting()

            check true == Pathname.new(fixturePath("sample_dir","a_file"   )).fileStatus().isExisting()
            check true == Pathname.new(fixturePath("sample_dir","a_dir"    )).fileStatus().isExisting()
            check true == Pathname.new(fixturePath("sample_dir","a_symlink")).fileStatus().isExisting()

        when defined(Posix):
            check true  == Pathname.new("/dev/null" ).fileStatus().isDeviceFile()
            check true  == Pathname.new("/dev/null" ).fileStatus().isCharacterDeviceFile()
            check false == Pathname.new("/dev/null" ).fileStatus().isBlockDeviceFile()

            check true  == Pathname.new("/dev/loop0").fileStatus().isDeviceFile()
            check false == Pathname.new("/dev/loop0").fileStatus().isCharacterDeviceFile()
            check true  == Pathname.new("/dev/loop0").fileStatus().isBlockDeviceFile()

        when defined(Posix):
            check true == Pathname.new("/tmp/.X11-unix/X0").fileStatus().isSocketFile()

        when defined(Posix):
            check true == Pathname.new(fixturePath("sample_dir","a_symlink_to_file")).fileStatus().isSymlink()
            check true == Pathname.new(fixturePath("sample_dir","a_symlink_to_file"   )).fileStatus().isExisting()
            check true == Pathname.new(fixturePath("sample_dir","a_symlink_to_file","")).fileStatus().isNotExisting()

            check true  == Pathname.new(fixturePath("sample_dir","a_symlink_to_dir" )).fileStatus().isSymlink()
            check false == Pathname.new(fixturePath("sample_dir","a_symlink_to_dir" )).fileStatus().isDirectory()

            check false == Pathname.new(fixturePath("sample_dir","a_symlink_to_dir","")).fileStatus().isSymlink()
            check true  == Pathname.new(fixturePath("sample_dir","a_symlink_to_dir","")).fileStatus().isDirectory()

        when defined(Posix):
            discard posix.mkfifo( fixturePath("sample_dir/a_pipe").cstring, 0o600)
            check true == Pathname.new(fixturePath("sample_dir/a_pipe")).fileStatus().isPipeFile()
            discard posix.unlink( fixturePath("sample_dir/a_pipe").cstring)

        when defined(Windows):
            check false == Pathname.new(fixturePath("sample_dir\\a_symlink_to_file"  )).fileStatus().isSymlink()
            check true  == Pathname.new(fixturePath("sample_dir\\a_symlink_to_file"  )).fileStatus().isExisting()
            check true  == Pathname.new(fixturePath("sample_dir\\a_symlink_to_file\\")).fileStatus().isNotExisting()

            check false == Pathname.new(fixturePath("sample_dir\\a_symlink_to_dir")).fileStatus().isSymlink()
            check true  == Pathname.new(fixturePath("sample_dir\\a_symlink_to_dir")).fileStatus().isDirectory() #wine?

            check false == Pathname.new(fixturePath("sample_dir\\a_symlink_to_dir\\")).fileStatus().isSymlink()
            check true  == Pathname.new(fixturePath("sample_dir\\a_symlink_to_dir\\")).fileStatus().isDirectory() #wine?



    test "#fileStatus() - Sample01":
        when true: # Common
            check true  == Pathname.new(fixturePath("sample_dir","a_file")).fileStatus().isReadable()
            check true  == Pathname.new(fixturePath("sample_dir","a_dir" )).fileStatus().isReadable()
            check false == Pathname.new(fixturePath("NOT_EXISTING"       )).fileStatus().isReadable()

            check true  == Pathname.new(fixturePath("sample_dir","a_file")).fileStatus().isWritable()
            check true  == Pathname.new(fixturePath("sample_dir","a_dir" )).fileStatus().isWritable()
            check false == Pathname.new(fixturePath("NOT_EXISTING"       )).fileStatus().isWritable()

            check false == Pathname.new(fixturePath("sample_dir","a_file")).fileStatus().isExecutable()
            #check false == Pathname.new(fixturePath("sample_dir","a_dir")).fileStatus().isExecutable() # Posix vs. Windows
            check false == Pathname.new(fixturePath("NOT_EXISTING"       )).fileStatus().isExecutable()

        when defined(Posix):
            check false == Pathname.new("/var/log/syslog").fileStatus().isReadable()
            check true  == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().isReadable()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).fileStatus().isReadable()
            check false == Pathname.new(fixturePath("NOT_EXISTING"     )).fileStatus().isReadable()

            check false == Pathname.new("/var/log/syslog").fileStatus().isWritable()
            check true  == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().isWritable()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).fileStatus().isWritable()
            check false == Pathname.new(fixturePath("NOT_EXISTING"     )).fileStatus().isWritable()

            check true  == Pathname.new("/bin/cat").fileStatus().isExecutable()
            check false == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().isExecutable()
            check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).fileStatus().isExecutable()
            check false == Pathname.new(fixturePath("NOT_EXISTING"     )).fileStatus().isExecutable()

        when defined(Windows):
            check true  == Pathname.new(fixturePath("sample_dir\\a_file")).fileStatus().isReadable()
            check true  == Pathname.new(fixturePath("sample_dir\\a_dir" )).fileStatus().isReadable()
            check false == Pathname.new(fixturePath("NOT_EXISTING"      )).fileStatus().isReadable()

            check true  == Pathname.new(fixturePath("sample_dir\\a_file")).fileStatus().isWritable()
            check true  == Pathname.new(fixturePath("sample_dir\\a_dir" )).fileStatus().isWritable()
            check false == Pathname.new(fixturePath("NOT_EXISTING"      )).fileStatus().isWritable()

            check false == Pathname.new(fixturePath("sample_dir\\a_file")).fileStatus().isExecutable()
            check false == Pathname.new(fixturePath("sample_dir\\a_dir" )).fileStatus().isExecutable()
            check false == Pathname.new(fixturePath("NOT_EXISTING"      )).fileStatus().isExecutable()



    test "#fileStatus() - Sample02()":
        when true: # Common
            check fixturePath("sample_dir","a_file") == Pathname.new(fixturePath("sample_dir","a_file")).fileStatus().pathStr()
            check fixturePath("sample_dir","a_dir")  == Pathname.new(fixturePath("sample_dir","a_dir" )).fileStatus().pathStr()
            check   0 == Pathname.new(fixturePath("sample_dir","a_file")).fileStatus().fileSizeInBytes()
            check 122 == Pathname.new(fixturePath("README.md")).fileStatus().fileSizeInBytes()

        when defined(Posix):
            check    0 == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().fileSizeInBytes()
            check  122 == Pathname.new(fixturePath("README.md")).fileStatus().fileSizeInBytes()
            check 4096 == Pathname.new(fixturePath("sample_dir/a_dir")).fileSizeInBytes()

        when defined(Windows):
            check   0 == Pathname.new(fixturePath("sample_dir\\a_file")).fileStatus().fileSizeInBytes()
            check 122 == Pathname.new(fixturePath("README.md")).fileStatus().fileSizeInBytes()
            check   0 == Pathname.new(fixturePath("sample_dir\\a_dir")).fileSizeInBytes()



    test "#fileStatus() - Sample03()":
        when defined(Posix):
            check 0    == Pathname.new("/").fileStatus().userId()
            check 1000 == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().userId()

            check 0    == Pathname.new("/").fileStatus().groupId()
            check 1000 == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().groupId()

        when defined(Windows):
            check -1 == Pathname.new("C:").fileStatus().userId()
            check -1 == Pathname.new(fixturePath("sample_dir\\a_file")).fileStatus().userId()

            check -1 == Pathname.new("C:").fileStatus().groupId()
            check -1 == Pathname.new(fixturePath("sample_dir\\a_file")).fileStatus().groupId()



#-----------------------------------------------------------------------------------------------------------------------
# Pathname - tap()
#-----------------------------------------------------------------------------------------------------------------------



    test "#tap() Usage-Sample":
        when true: # Common
            let pathname = Pathname.new(fixturePath("TEST_TAP_DIR_USAGE_SAMPLE")).removeDirectoryTree()
            check false == pathname.isExisting()
            pathname.tap do (testDir: Pathname):
                testDir.createDirectory(mode=0o750)
                testDir.createDirectory("bin", mode=0o700)
                testDir.createDirectory("src")
                testDir.createDirectory("tests")
                testDir.createDirectory("DIR_TO_REMOVE")
                testDir.removeDirectory("DIR_TO_REMOVE")
                testDir.createRegularFile("FILE_A1")
                testDir.createRegularFile("FILE_A2", mode=0o640)
                testDir.createFile("FILE_B1")
                testDir.createFile("FILE_B2", mode=0o640)
                testDir.touch("FILE_C1")
                testDir.touch("FILE_C2", mode=0o640)
                testDir.createRegularFile("FILE_TO_REMOVE")
                testDir.removeRegularFile("FILE_TO_REMOVE")
            check true == pathname.isDirectory()
            pathname.removeDirectoryTree()



    test "#tap() should take a function providing self as param":
        when true: # Common
            let pathname = Pathname.new(fixturePath("TEST_TAP_DIR"))
            pathname.tap do (inner: Pathname):
                check inner == pathname



    test "#tap() should return self for Method-Chaining":
        when true: # Common
            let pathname = Pathname.new(fixturePath("TEST_TAP_DIR"))
            let pathname2 = pathname.tap do (inner: Pathname):
                discard
            check pathname2 == pathname
