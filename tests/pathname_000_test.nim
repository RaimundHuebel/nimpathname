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
            check nil == noPathname
        block:
            os.putEnv("SAMPLE_PATH_ENV_VAR", "/tmp/ABC/123")
            let aPathname: Pathname = Pathname.fromEnvVarOrNil("SAMPLE_PATH_ENV_VAR")
            check nil != aPathname
            check "/tmp/ABC/123" == aPathname.toPathStr()
        block:
            os.delEnv("SAMPLE_PATH_ENV_VAR")
            let noPathname: Pathname = Pathname.fromEnvVarOrNil("SAMPLE_PATH_ENV_VAR")
            check nil == noPathname


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
        check true  == Pathname.new("/"  ).isAbsolute()
        check true  == Pathname.new("/a" ).isAbsolute()
        check true  == Pathname.new("/." ).isAbsolute()
        check true  == Pathname.new("/..").isAbsolute()
        check true  == Pathname.new("/a/../b/.").isAbsolute()
        check true  == Pathname.new("/a/./b/..").isAbsolute()

        check false == Pathname.new(""  ).isAbsolute()
        check false == Pathname.new("a" ).isAbsolute()
        check false == Pathname.new("." ).isAbsolute()
        check false == Pathname.new("..").isAbsolute()
        check false == Pathname.new("a/../b/.").isAbsolute()
        check false == Pathname.new("a/./b/..").isAbsolute()


    test "#isRelative()":
        check false == Pathname.new("/"  ).isRelative()
        check false == Pathname.new("/a" ).isRelative()
        check false == Pathname.new("/." ).isRelative()
        check false == Pathname.new("/..").isRelative()
        check false == Pathname.new("/a/../b/.").isRelative()
        check false == Pathname.new("/a/./b/..").isRelative()

        check true  == Pathname.new(""  ).isRelative()
        check true  == Pathname.new("a" ).isRelative()
        check true  == Pathname.new("." ).isRelative()
        check true  == Pathname.new("..").isRelative()
        check true  == Pathname.new("a/../b/.").isRelative()
        check true  == Pathname.new("a/./b/..").isRelative()


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


    test "#basename()":
        check "/" == Pathname.new("/"  ).basename().toPathStr()

        check ""  == Pathname.new(""   ).basename().toPathStr()

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



    test "#dirname() with absolute paths":
        check "/"    == Pathname.new("/"      ).dirname().toPathStr()
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


    test "#dirname() with absolute paths (edgecase_00)":
        check "//a"  == Pathname.new("//a//b").dirname().toPathStr()
        check "//a"  == Pathname.new("//a//b//").dirname().toPathStr()

        check "//a"  == Pathname.new("//a// ").dirname().toPathStr()
        check "//a"  == Pathname.new("//a// //").dirname().toPathStr()

        check "//a"  == Pathname.new("//a//.").dirname().toPathStr()
        check "//a"  == Pathname.new("//a//.//").dirname().toPathStr()

        check "//a"  == Pathname.new("//a//..").dirname().toPathStr()
        check "//a"  == Pathname.new("//a//..//").dirname().toPathStr()


    test "#dirname() with absolute paths (edgecase_01)":
        check "// "  == Pathname.new("// //a").dirname().toPathStr()
        check "// "  == Pathname.new("// //a//").dirname().toPathStr()

        check "// "  == Pathname.new("// // ").dirname().toPathStr()
        check "// "  == Pathname.new("// // //").dirname().toPathStr()

        check "// "  == Pathname.new("// //.").dirname().toPathStr()
        check "// "  == Pathname.new("// //.//").dirname().toPathStr()

        check "// "  == Pathname.new("// //..").dirname().toPathStr()
        check "// "  == Pathname.new("// //..//").dirname().toPathStr()


    test "#dirname() with absolute paths (edgecase_02)":
        check "/"  == Pathname.new("/ /"  ).dirname().toPathStr()
        check "/"  == Pathname.new("/ //" ).dirname().toPathStr()
        check "/"  == Pathname.new("/ ///").dirname().toPathStr()

        check "//"  == Pathname.new("// /"  ).dirname().toPathStr()
        check "//"  == Pathname.new("// //" ).dirname().toPathStr()
        check "//"  == Pathname.new("// ///").dirname().toPathStr()

        check "///"  == Pathname.new("/// /"  ).dirname().toPathStr()
        check "///"  == Pathname.new("/// //" ).dirname().toPathStr()
        check "///"  == Pathname.new("/// ///").dirname().toPathStr()


    test "#dirname() with relative paths":
        check "."   == Pathname.new("a"     ).dirname().toPathStr()
        check "."   == Pathname.new("a/"    ).dirname().toPathStr()
        check "a"   == Pathname.new("a/b"   ).dirname().toPathStr()
        check "a"   == Pathname.new("a/b/"  ).dirname().toPathStr()
        check "a/b" == Pathname.new("a/b/c" ).dirname().toPathStr()
        check "a/b" == Pathname.new("a/b/c/").dirname().toPathStr()

        check "."     == Pathname.new(""      ).dirname().toPathStr()
        check "."     == Pathname.new(" "     ).dirname().toPathStr()
        check "."     == Pathname.new(" /"    ).dirname().toPathStr()
        check " "     == Pathname.new(" /a"   ).dirname().toPathStr()
        check " "     == Pathname.new(" /a/"  ).dirname().toPathStr()
        check " /a"   == Pathname.new(" /a/b" ).dirname().toPathStr()
        check " /a"   == Pathname.new(" /a/b/").dirname().toPathStr()

        check "."     == Pathname.new("."     ).dirname().toPathStr()
        check "."     == Pathname.new("./"    ).dirname().toPathStr()
        check "."     == Pathname.new("./a"   ).dirname().toPathStr()
        check "."     == Pathname.new("./a/"  ).dirname().toPathStr()
        check "./a"   == Pathname.new("./a/b" ).dirname().toPathStr()
        check "./a"   == Pathname.new("./a/b/").dirname().toPathStr()

        check "."     == Pathname.new(".."     ).dirname().toPathStr()
        check "."     == Pathname.new("../"    ).dirname().toPathStr()
        check ".."    == Pathname.new("../a"   ).dirname().toPathStr()
        check ".."    == Pathname.new("../a/"  ).dirname().toPathStr()
        check "../a"  == Pathname.new("../a/b" ).dirname().toPathStr()
        check "../a"  == Pathname.new("../a/b/").dirname().toPathStr()


    test "#extname() file-form":
        check ""  == Pathname.new("."   ).extname()
        check ""  == Pathname.new("/."  ).extname()
        check ""  == Pathname.new("//." ).extname()
        check ""  == Pathname.new("///.").extname()

        check ""  == Pathname.new(".x"   ).extname()
        check ""  == Pathname.new("/.x"  ).extname()
        check ""  == Pathname.new("//.x" ).extname()
        check ""  == Pathname.new("///.x").extname()

        check ".x"  == Pathname.new("a.x"   ).extname()
        check ".x"  == Pathname.new("/a.x"  ).extname()
        check ".x"  == Pathname.new("//a.x" ).extname()
        check ".x"  == Pathname.new("///a.x").extname()

        check ".xy" == Pathname.new("a.xy"   ).extname()
        check ".xy" == Pathname.new("/a.xy"  ).extname()
        check ".xy" == Pathname.new("//a.xy" ).extname()
        check ".xy"  == Pathname.new("///a.xy").extname()

        check "" == Pathname.new("a/.x"   ).extname()
        check "" == Pathname.new("/a/.x"  ).extname()
        check "" == Pathname.new("//a//.x" ).extname()
        check ""  == Pathname.new("///a///.x").extname()

        check ".x" == Pathname.new("a/b.x"   ).extname()
        check ".x" == Pathname.new("/a/b.x"  ).extname()
        check ".x" == Pathname.new("//a//b.x" ).extname()
        check ".x"  == Pathname.new("///a///b.x").extname()

        check ".xy" == Pathname.new("a/b.xy"   ).extname()
        check ".xy" == Pathname.new("/a/b.xy"  ).extname()
        check ".xy" == Pathname.new("//a//b.xy" ).extname()
        check ".xy"  == Pathname.new("///a///b.xy").extname()


    test "#extname() directory-form":
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


    test "#extname() (edgecase_00)":
        check "" == Pathname.new(".x" ).extname()
        check "" == Pathname.new(".xy").extname()
        check "" == Pathname.new(".x" ).extname()
        check "" == Pathname.new(".xy").extname()

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


    test "#extname() (edgecase_01)":
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


    test "#extname() (edgecase_02)":
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


    test "#extname() (edgecase_03)":
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


    test "#extname() (edgecase_04)":
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


    test "#extname() (edgecase_05a)":
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


    test "#extname() (edgecase_05b)":
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


    test "#extname() (edgecase_05c)":
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


    test "#extname() (edgecase_06a)":
        check "" == Pathname.new("a.").extname()
        check "" == Pathname.new("/a.").extname()
        check "" == Pathname.new("//a.").extname()
        check "" == Pathname.new("///a.").extname()


    test "#extname() (edgecase_06b)":
        check "" == Pathname.new(" .").extname()
        check "" == Pathname.new("/ .").extname()
        check "" == Pathname.new("// .").extname()
        check "" == Pathname.new("/// .").extname()


    test "#extname() (edgecase_06c)":
        check "" == Pathname.new("a./").extname()
        check "" == Pathname.new("/a.//").extname()
        check "" == Pathname.new("//a.///").extname()
        check "" == Pathname.new("///a.////").extname()


    test "#extname() (edgecase_06d)":
        check "" == Pathname.new(" ./").extname()
        check "" == Pathname.new("/ .//").extname()
        check "" == Pathname.new("// .///").extname()
        check "" == Pathname.new("/// .////").extname()


    test "#normalize()":
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


    test "#cleanpath()":
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


    test "#fileType() v1":
        check FileType.REGULAR_FILE == Pathname.new(fixturePath("sample_dir/a_file")).fileType()

        check FileType.DIRECTORY == Pathname.new(fixturePath("sample_dir/a_dir")).fileType()

        check FileType.SYMLINK      == Pathname.new(fixturePath("sample_dir/a_symlink_to_file"  )).fileType()
        check FileType.NOT_EXISTING == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/" )).fileType()
        check FileType.NOT_EXISTING == Pathname.new(fixturePath("sample_dir/a_symlink_to_file//")).fileType()

        check FileType.SYMLINK   == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir"  )).fileType()
        check FileType.DIRECTORY == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/" )).fileType()
        check FileType.DIRECTORY == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir//")).fileType()

        check FileType.CHARACTER_DEVICE == Pathname.new("/dev/null").fileType()

        check FileType.BLOCK_DEVICE == Pathname.new("/dev/loop0").fileType()

        check FileType.NOT_EXISTING == Pathname.new(fixturePath("NON_EXISTING_FILE" )).fileType()
        check FileType.NOT_EXISTING == Pathname.new(fixturePath("NON_EXISTING_FILE/")).fileType()

        check FileType.NOT_EXISTING == Pathname.new(fixturePath("sample_dir/NON_EXISTING_FILE" )).fileType()
        check FileType.NOT_EXISTING == Pathname.new(fixturePath("sample_dir/NON_EXISTING_FILE/")).fileType()

        check FileType.SOCKET_FILE == Pathname.new("/tmp/.X11-unix/X0").fileType()

        when defined(Posix):
            discard posix.mkfifo( fixturePath("sample_dir/a_pipe"), 0o600)
            check FileType.PIPE_FILE == Pathname.new(fixturePath("sample_dir/a_pipe")).fileType()
            discard posix.unlink( fixturePath("sample_dir/a_pipe") )



    test "#fileType() v2":
        check true == Pathname.new(fixturePath("sample_dir/a_file")).fileType().isRegularFile()

        check true == Pathname.new(fixturePath("sample_dir/a_dir")).fileType().isDirectory()

        check true == Pathname.new(fixturePath("sample_dir/a_symlink_to_file")).fileType().isSymlink()

        check true == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir")).fileType().isSymlink()

        check true == Pathname.new("/dev/null" ).fileType().isDeviceFile()
        check true == Pathname.new("/dev/loop0").fileType().isDeviceFile()

        check true == Pathname.new("/dev/null" ).fileType().isCharacterDeviceFile()
        check true == Pathname.new("/dev/loop0").fileType().isBlockDeviceFile()

        check true == Pathname.new(fixturePath("sample_dir/a_file"   )).fileType().isExisting()
        check true == Pathname.new(fixturePath("sample_dir/a_dir"    )).fileType().isExisting()
        check true == Pathname.new(fixturePath("sample_dir/a_symlink")).fileType().isExisting()

        check true == Pathname.new(fixturePath("NON_EXISTING_FILE" )).fileType().isNotExisting()
        check true == Pathname.new(fixturePath("NON_EXISTING_FILE/")).fileType().isNotExisting()

        check true == Pathname.new(fixturePath("sample_dir/NON_EXISTING_FILE" )).fileType().isNotExisting()
        check true == Pathname.new(fixturePath("sample_dir/NON_EXISTING_FILE/")).fileType().isNotExisting()

        check true == Pathname.new("/tmp/.X11-unix/X0").fileType().isSocketFile()

        when defined(Posix):
            discard posix.mkfifo( fixturePath("sample_dir/a_pipe"), 0o600)
            check true == Pathname.new(fixturePath("sample_dir/a_pipe")).fileType().isPipeFile()
            discard posix.unlink( fixturePath("sample_dir/a_pipe") )



    test "#isExisting() with regular files":
        check true == Pathname.new(fixturePath("README.md"  )).isExisting()

        check true == Pathname.new(fixturePath("sample_dir"  )).isExisting()
        check true == Pathname.new(fixturePath("sample_dir/" )).isExisting()
        check true == Pathname.new(fixturePath("sample_dir//")).isExisting()

        check true  == Pathname.new(fixturePath("sample_dir/a_file"  )).isExisting()
        check false == Pathname.new(fixturePath("sample_dir/a_file/" )).isExisting()
        check false == Pathname.new(fixturePath("sample_dir/a_file//")).isExisting()

        check true  == Pathname.new(fixturePath("sample_dir/a_file.no2"  )).isExisting()
        check false == Pathname.new(fixturePath("sample_dir/a_file.no2/" )).isExisting()
        check false == Pathname.new(fixturePath("sample_dir/a_file.no2//")).isExisting()

        check false == Pathname.new(fixturePath("NON_EXISTING_FILE"  )).isExisting()
        check false == Pathname.new(fixturePath("NON_EXISTING_FILE/" )).isExisting()
        check false == Pathname.new(fixturePath("NON_EXISTING_FILE//")).isExisting()

        check false == Pathname.new(fixturePath("sample_dir//NON_EXISTING_FILE"  )).isExisting()
        check false == Pathname.new(fixturePath("sample_dir//NON_EXISTING_FILE/" )).isExisting()
        check false == Pathname.new(fixturePath("sample_dir//NON_EXISTING_FILE//")).isExisting()

        check false == Pathname.new(fixturePath("NON_EXISTING_DIR//NON_EXISTING_FILE"  )).isExisting()
        check false == Pathname.new(fixturePath("NON_EXISTING_DIR//NON_EXISTING_FILE/" )).isExisting()
        check false == Pathname.new(fixturePath("NON_EXISTING_DIR//NON_EXISTING_FILE//")).isExisting()

        check false == Pathname.new("/NON_EXISTING_FILE"  ).isExisting()
        check false == Pathname.new("/NON_EXISTING_FILE/" ).isExisting()
        check false == Pathname.new("/NON_EXISTING_FILE//").isExisting()



    test "#isExisting() with directories":
        check true == Pathname.new(fixturePath("sample_dir"  )).isExisting()
        check true == Pathname.new(fixturePath("sample_dir/" )).isExisting()
        check true == Pathname.new(fixturePath("sample_dir//")).isExisting()

        check true == Pathname.new(fixturePath("sample_dir/a_dir"  )).isExisting()
        check true == Pathname.new(fixturePath("sample_dir/a_dir/" )).isExisting()
        check true == Pathname.new(fixturePath("sample_dir/a_dir//")).isExisting()

        check false == Pathname.new(fixturePath("NON_EXISTING_DIR"  )).isExisting()
        check false == Pathname.new(fixturePath("NON_EXISTING_DIR/" )).isExisting()
        check false == Pathname.new(fixturePath("NON_EXISTING_DIR//")).isExisting()

        check false == Pathname.new("/NON_EXISTING_DIR"  ).isExisting()
        check false == Pathname.new("/NON_EXISTING_DIR/" ).isExisting()
        check false == Pathname.new("/NON_EXISTING_DIR//").isExisting()



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



    test "#isNotExisting()":
        check false == Pathname.new(fixturePath("README.md"  )).isNotExisting()

        check false == Pathname.new(fixturePath("sample_dir"  )).isNotExisting()
        check false == Pathname.new(fixturePath("sample_dir/" )).isNotExisting()
        check false == Pathname.new(fixturePath("sample_dir//")).isNotExisting()

        check false == Pathname.new(fixturePath("sample_dir/a_file"  )).isNotExisting()
        check true  == Pathname.new(fixturePath("sample_dir/a_file/" )).isNotExisting()
        check true  == Pathname.new(fixturePath("sample_dir/a_file//")).isNotExisting()

        check false == Pathname.new(fixturePath("sample_dir/a_file.no2"  )).isNotExisting()
        check true  == Pathname.new(fixturePath("sample_dir/a_file.no2/" )).isNotExisting()
        check true  == Pathname.new(fixturePath("sample_dir/a_file.no2//")).isNotExisting()

        check true == Pathname.new(fixturePath("NON_EXISTING_FILE"  )).isNotExisting()
        check true == Pathname.new(fixturePath("NON_EXISTING_FILE/" )).isNotExisting()
        check true == Pathname.new(fixturePath("NON_EXISTING_FILE//")).isNotExisting()

        check true == Pathname.new(fixturePath("sample_dir//NON_EXISTING_FILE"  )).isNotExisting()
        check true == Pathname.new(fixturePath("sample_dir//NON_EXISTING_FILE/" )).isNotExisting()
        check true == Pathname.new(fixturePath("sample_dir//NON_EXISTING_FILE//")).isNotExisting()

        check true == Pathname.new(fixturePath("NON_EXISTING_DIR//NON_EXISTING_FILE"  )).isNotExisting()
        check true == Pathname.new(fixturePath("NON_EXISTING_DIR//NON_EXISTING_FILE/" )).isNotExisting()
        check true == Pathname.new(fixturePath("NON_EXISTING_DIR//NON_EXISTING_FILE//")).isNotExisting()

        check true == Pathname.new("/NON_EXISTING_FILE"  ).isNotExisting()
        check true == Pathname.new("/NON_EXISTING_FILE/" ).isNotExisting()
        check true == Pathname.new("/NON_EXISTING_FILE//").isNotExisting()

        check false == Pathname.new("/tmp/.X11-unix/X0").isNotExisting()



    test "#isUnknownFileType()":
        check false == Pathname.new(fixturePath("sample_dir/a_file"  )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir/a_file/" )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir/a_file//")).isUnknownFileType()

        check false == Pathname.new(fixturePath("sample_dir"  )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir/" )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir//")).isUnknownFileType()

        check false == Pathname.new(fixturePath("sample_dir/a_dir"  )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir/a_dir/" )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir/a_dir//")).isUnknownFileType()

        check false == Pathname.new(fixturePath("sample_dir/a_file.no2"  )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir/a_file.no2/" )).isUnknownFileType()
        check false == Pathname.new(fixturePath("sample_dir/a_file.no2//")).isUnknownFileType()

        check false == Pathname.new(fixturePath("NON_EXISTING_FILE"  )).isUnknownFileType()
        check false == Pathname.new(fixturePath("NON_EXISTING_FILE/" )).isUnknownFileType()
        check false == Pathname.new(fixturePath("NON_EXISTING_FILE//")).isUnknownFileType()

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
        check true  == Pathname.new(fixturePath("sample_dir/a_file"  )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir/a_file/" )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir/a_file//")).isRegularFile()

        check false == Pathname.new(fixturePath("sample_dir"  )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir/" )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir//")).isRegularFile()

        check false == Pathname.new(fixturePath("sample_dir/a_dir"  )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir/a_dir/" )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir/a_dir//")).isRegularFile()

        check true  == Pathname.new(fixturePath("sample_dir/a_file.no2"  )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir/a_file.no2/" )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir/a_file.no2//")).isRegularFile()

        check false == Pathname.new(fixturePath("NON_EXISTING_FILE"  )).isRegularFile()
        check false == Pathname.new(fixturePath("NON_EXISTING_FILE/" )).isRegularFile()
        check false == Pathname.new(fixturePath("NON_EXISTING_FILE//")).isRegularFile()

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



    test "#isDeviceFile()":
        check false == Pathname.new(fixturePath("sample_dir/a_file")).isDeviceFile()
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



    test "#isCharacterDeviceFile()":
        check false == Pathname.new(fixturePath("sample_dir/a_file")).isCharacterDeviceFile()
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



    test "#isBlockDeviceFile()":
        check false == Pathname.new(fixturePath("sample_dir/a_file")).isBlockDeviceFile()
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



    test "#isSocketFile()":
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



    test "#isPipeFile()":
        when defined(Posix):
            discard posix.mkfifo( fixturePath("sample_dir/a_pipe"), 0o600)
            check true == Pathname.new(fixturePath("sample_dir/a_pipe")).isPipeFile()
            discard posix.unlink( fixturePath("sample_dir/a_pipe") )

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



    test "#isHidden()":
        check true == Pathname.new(fixturePath("sample_dir/.a_hidden_file")).isHidden()
        check true == Pathname.new(fixturePath("sample_dir/.a_hidden_dir")).isHidden()
        check true == Pathname.new(fixturePath("sample_dir/.a_hidden_dir/.keep")).isHidden()

        check false == Pathname.new(fixturePath("sample_dir/a_file")).isHidden()
        check false == Pathname.new(fixturePath("sample_dir/a_dir")).isHidden()
        check false == Pathname.new(fixturePath("sample_dir/NOT_EXISTING")).isHidden()

        check false == Pathname.new(fixturePath("sample_dir/.NOT_EXISTING")).isHidden()



    test "#isVisible()":
        check true  == Pathname.new(fixturePath("sample_dir/a_file")).isVisible()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir")).isVisible()

        check false == Pathname.new(fixturePath("sample_dir/.a_hidden_file")).isVisible()
        check false == Pathname.new(fixturePath("sample_dir/.a_hidden_dir")).isVisible()
        check false == Pathname.new(fixturePath("sample_dir/.a_hidden_dir/.keep")).isVisible()
        check false == Pathname.new(fixturePath("sample_dir/NOT_EXISTING")).isVisible()
        check false == Pathname.new(fixturePath("sample_dir/.NOT_EXISTING")).isVisible()



    test "#isZeroSizeFile()":
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



    test "#getFileSizeInBytes()":
        check 0 == Pathname.new(fixturePath("sample_dir/a_file")).getFileSizeInBytes()
        check 4096 == Pathname.new(fixturePath("sample_dir/a_dir")).getFileSizeInBytes()
        ## When needs update -> change to a file with fixed file size ...
        check 122 == Pathname.new(fixturePath("README.md")).getFileSizeInBytes()



    test "#getIoBlockSizeInBytes()":
        check 4096 == Pathname.new(fixturePath("sample_dir/a_file")).getIoBlockSizeInBytes()
        check 4096 == Pathname.new(fixturePath("sample_dir/a_dir")).getIoBlockSizeInBytes()
        ## When needs update -> change to a file with fixed file size ...
        check 4096 == Pathname.new(fixturePath("README.md")).getIoBlockSizeInBytes()



    test "#getUserId()":
        check 0    == Pathname.new("/").getUserId()
        check 1000 == Pathname.new(fixturePath("sample_dir/a_file")).getUserId()



    test "#getGroupId()":
        check 0    == Pathname.new("/").getGroupId()
        check 1000 == Pathname.new(fixturePath("sample_dir/a_file")).getGroupId()



    test "#getCountHardlinks()":
        check 1 == Pathname.new(fixturePath("sample_dir/a_file")).getCountHardlinks()



    test "#hasSetUidBit()":
        check true == Pathname.new("/bin/su").hasSetUidBit()

        check false == Pathname.new(fixturePath("sample_dir/a_file" )).hasSetUidBit()
        check false == Pathname.new(fixturePath("sample_dir/a_dir"  )).hasSetUidBit()


    test "#hasSetGidBit()":
        check true == Pathname.new("/usr/bin/wall").hasSetGidBit()

        check false == Pathname.new(fixturePath("sample_dir/a_file" )).hasSetGidBit()
        check false == Pathname.new(fixturePath("sample_dir/a_dir"  )).hasSetGidBit()



    test "#hasStickyBit()":
        check true == Pathname.new("/tmp").hasStickyBit()

        check false == Pathname.new(fixturePath("sample_dir/a_file" )).hasStickyBit()
        check false == Pathname.new(fixturePath("sample_dir/a_dir"  )).hasStickyBit()



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

        check maxTime >= Pathname.new(fixturePath("sample_dir/a_file" )).getLastChangeTime()
        check minTime <= Pathname.new(fixturePath("sample_dir/a_file" )).getLastChangeTime()

        check maxTime >= Pathname.new(fixturePath("sample_dir/a_dir")).getLastChangeTime()
        check minTime <= Pathname.new(fixturePath("sample_dir/a_dir")).getLastChangeTime()



    test "#getLastStatusChangeTime()":
        let maxTime = times.getTime()
        let minTime = times.parse("2020-01-13", "yyyy-MM-dd").toTime()

        check maxTime >= minTime

        check maxTime >= Pathname.new(fixturePath("sample_dir/a_file" )).getLastStatusChangeTime()
        check minTime <= Pathname.new(fixturePath("sample_dir/a_file" )).getLastStatusChangeTime()

        check maxTime >= Pathname.new(fixturePath("sample_dir/a_dir")).getLastStatusChangeTime()
        check minTime <= Pathname.new(fixturePath("sample_dir/a_dir")).getLastStatusChangeTime()



    test "#isUserOwned()":
        check true == Pathname.new(fixturePath("sample_dir/a_file")).isUserOwned()
        check true == Pathname.new(fixturePath("sample_dir/a_dir" )).isUserOwned()

        check false == Pathname.new("/"   ).isUserOwned()
        check false == Pathname.new("/tmp").isUserOwned()



    test "#isGroupOwned()":
        check true == Pathname.new(fixturePath("sample_dir/a_file")).isGroupOwned()
        check true == Pathname.new(fixturePath("sample_dir/a_dir" )).isGroupOwned()

        check false == Pathname.new("/"   ).isGroupOwned()
        check false == Pathname.new("/tmp").isGroupOwned()



    test "#isGroupMember()":
        check true == Pathname.new(fixturePath("sample_dir/a_file")).isGroupMember()
        check true == Pathname.new(fixturePath("sample_dir/a_dir" )).isGroupMember()

        check false == Pathname.new("/"   ).isGroupMember()
        check false == Pathname.new("/tmp").isGroupMember()



    test "#isReadable()":
        check false == Pathname.new("/var/log/syslog"               ).isReadable()
        check true  == Pathname.new(fixturePath("sample_dir/a_file")).isReadable()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isReadable()



    test "#isReadableByUser()":
        check false == Pathname.new("/var/log/syslog"               ).isReadableByUser()
        check true  == Pathname.new(fixturePath("sample_dir/a_file")).isReadableByUser()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isReadableByUser()



    test "#isReadableByGroup()":
        check false == Pathname.new("/var/log/syslog"               ).isReadableByGroup()
        check true  == Pathname.new(fixturePath("sample_dir/a_file")).isReadableByGroup()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isReadableByGroup()



    test "#isReadableByOther()":
        check false == Pathname.new("/var/log/syslog"               ).isReadableByOther()
        check true  == Pathname.new(fixturePath("sample_dir/a_file")).isReadableByOther()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isReadableByOther()



    test "#isWritable()":
        check false == Pathname.new("/var/log/syslog"               ).isWritable()
        check true  == Pathname.new(fixturePath("sample_dir/a_file")).isWritable()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isWritable()



    test "#isWritableByUser()":
        check false == Pathname.new("/var/log/syslog"               ).isWritableByUser()
        check true  == Pathname.new(fixturePath("sample_dir/a_file")).isWritableByUser()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isWritableByUser()



    test "#isWritableByGroup()":
        check false == Pathname.new("/var/log/syslog"               ).isWritableByGroup()
        check false == Pathname.new(fixturePath("sample_dir/a_file")).isWritableByGroup()
        check false == Pathname.new(fixturePath("sample_dir/a_dir" )).isWritableByGroup()



    test "#isWritableByOther()":
        check false == Pathname.new("/var/log/syslog"               ).isWritableByOther()
        check false == Pathname.new(fixturePath("sample_dir/a_file")).isWritableByOther()
        check false == Pathname.new(fixturePath("sample_dir/a_dir" )).isWritableByOther()



    test "#isExecutable()":
        check true  == Pathname.new("/bin/cat"                      ).isExecutable()
        check false == Pathname.new(fixturePath("sample_dir/a_file")).isExecutable()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isExecutable()



    test "#isExecutableByUser()":
        check false == Pathname.new("/bin/cat"                      ).isExecutableByUser()
        check false == Pathname.new(fixturePath("sample_dir/a_file")).isExecutableByUser()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isExecutableByUser()



    test "#isExecutableByGroup()":
        check false == Pathname.new("/bin/cat"                      ).isExecutableByGroup()
        check false == Pathname.new(fixturePath("sample_dir/a_file")).isExecutableByGroup()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isExecutableByGroup()



    test "#isExecutableByOther()":
        check true  == Pathname.new("/bin/cat"                      ).isExecutableByOther()
        check false == Pathname.new(fixturePath("sample_dir/a_file")).isExecutableByOther()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir" )).isExecutableByOther()




#-----------------------------------------------------------------------------------------------------------------------
# Pathname#fileInfo()
#-----------------------------------------------------------------------------------------------------------------------


    test "#fileInfo() - is<FileMode>()":
        check pcFile  == Pathname.new(fixturePath("sample_dir/a_file")).fileInfo().kind

        check pcDir  == Pathname.new(fixturePath("sample_dir/a_dir")).fileInfo().kind

        check pcLinkToFile == Pathname.new(fixturePath("sample_dir/a_symlink_to_file")).fileInfo().kind

        check pcLinkToDir == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir")).fileInfo().kind
        check pcDir       == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/")).fileInfo().kind

        check pcFile == Pathname.new("/dev/null" ).fileInfo().kind
        check pcFile == Pathname.new("/dev/loop0").fileInfo().kind



#-----------------------------------------------------------------------------------------------------------------------
# Pathname#fileStatus()
#-----------------------------------------------------------------------------------------------------------------------


    test "#fileStatus() - getFileType()":
        check FileType.REGULAR_FILE == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().getFileType()

        check FileType.DIRECTORY == Pathname.new(fixturePath("sample_dir/a_dir")).fileStatus().getFileType()

        check FileType.SYMLINK      == Pathname.new(fixturePath("sample_dir/a_symlink_to_file")).fileStatus().getFileType()
        check FileType.NOT_EXISTING == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/")).fileStatus().getFileType()

        check FileType.SYMLINK   == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir" )).fileStatus().getFileType()
        check FileType.DIRECTORY == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/")).fileStatus().getFileType()

        check FileType.CHARACTER_DEVICE == Pathname.new("/dev/null" ).fileStatus().getFileType()

        check FileType.BLOCK_DEVICE == Pathname.new("/dev/loop0" ).fileStatus().getFileType()

        check FileType.NOT_EXISTING == Pathname.new(fixturePath("NON_EXISTING_FILE" )).fileStatus().getFileType()
        check FileType.NOT_EXISTING == Pathname.new(fixturePath("NON_EXISTING_FILE/")).fileStatus().getFileType()

        check FileType.SOCKET_FILE == Pathname.new("/tmp/.X11-unix/X0").fileStatus().getFileType()

        when defined(Posix):
            discard posix.mkfifo( fixturePath("sample_dir/a_pipe"), 0o600)
            check FileType.PIPE_FILE == Pathname.new(fixturePath("sample_dir/a_pipe")).fileStatus().getFileType()
            discard posix.unlink( fixturePath("sample_dir/a_pipe") )



    test "#fileStatus() - Sample00":
        check true == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().isRegularFile()

        check true == Pathname.new(fixturePath("sample_dir/a_dir")).fileStatus().isDirectory()

        check true == Pathname.new(fixturePath("sample_dir/a_symlink_to_file")).fileStatus().isSymlink()
        check true == Pathname.new(fixturePath("sample_dir/a_symlink_to_file")).fileStatus().isExisting()
        check true == Pathname.new(fixturePath("sample_dir/a_symlink_to_file/")).fileStatus().isNotExisting()

        check true  == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir" )).fileStatus().isSymlink()
        check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir" )).fileStatus().isDirectory()

        check false == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/")).fileStatus().isSymlink()
        check true  == Pathname.new(fixturePath("sample_dir/a_symlink_to_dir/")).fileStatus().isDirectory()

        check true == Pathname.new("/dev/null" ).fileStatus().isDeviceFile()
        check true == Pathname.new("/dev/loop0").fileStatus().isDeviceFile()

        check true == Pathname.new("/dev/null" ).fileStatus().isCharacterDeviceFile()
        check true == Pathname.new("/dev/loop0").fileStatus().isBlockDeviceFile()

        check true == Pathname.new(fixturePath("sample_dir/a_file"   )).fileStatus().isExisting()
        check true == Pathname.new(fixturePath("sample_dir/a_dir"    )).fileStatus().isExisting()
        check true == Pathname.new(fixturePath("sample_dir/a_symlink")).fileStatus().isExisting()

        check true == Pathname.new(fixturePath("NON_EXISTING_FILE" )).fileStatus().isNotExisting()
        check true == Pathname.new(fixturePath("NON_EXISTING_FILE/")).fileStatus().isNotExisting()

        check true == Pathname.new(fixturePath("sample_dir/NON_EXISTING_FILE" )).fileStatus().isNotExisting()
        check true == Pathname.new(fixturePath("sample_dir/NON_EXISTING_FILE/")).fileStatus().isNotExisting()

        check true == Pathname.new("/tmp/.X11-unix/X0").fileStatus().isSocketFile()

        when defined(Posix):
            discard posix.mkfifo( fixturePath("sample_dir/a_pipe"), 0o600)
            check true == Pathname.new(fixturePath("sample_dir/a_pipe")).fileStatus().isPipeFile()
            discard posix.unlink( fixturePath("sample_dir/a_pipe") )



    test "#fileStatus() - Sample01":
        check false == Pathname.new("/var/log/syslog").fileStatus().isReadable()
        check true  == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().isReadable()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir")).fileStatus().isReadable()

        check false == Pathname.new("/var/log/syslog").fileStatus().isWritable()
        check true  == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().isWritable()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir")).fileStatus().isWritable()

        check true  == Pathname.new("/bin/cat").fileStatus().isExecutable()
        check false == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().isExecutable()
        check true  == Pathname.new(fixturePath("sample_dir/a_dir")).fileStatus().isExecutable()



    test "#fileStatus() - Sample02()":
        check fixturePath("sample_dir/a_file") == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().getPathStr()
        check fixturePath("sample_dir/a_dir")  == Pathname.new(fixturePath("sample_dir/a_dir" )).fileStatus().getPathStr()

        check 0 == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().getFileSizeInBytes()
        check 4096 == Pathname.new(fixturePath("sample_dir/a_dir")).getFileSizeInBytes()
        ## When needs update -> change to a file with fixed file size ...
        check 122 == Pathname.new(fixturePath("README.md")).fileStatus().getFileSizeInBytes()



    test "#fileStatus() - Sample03()":
        check 0    == Pathname.new("/").fileStatus().getUserId()
        check 1000 == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().getUserId()

        check 0    == Pathname.new("/").fileStatus().getGroupId()
        check 1000 == Pathname.new(fixturePath("sample_dir/a_file")).fileStatus().getGroupId()


#-----------------------------------------------------------------------------------------------------------------------
# Pathname - tap()
#-----------------------------------------------------------------------------------------------------------------------


    test "#tap() Usage-Sample":

        let pathname = Pathname.new(fixturePath("TEST_TAP_DIR_USAGE_SAMPLE")).removeDirectoryTree()
        check false == pathname.isExisting()
        pathname.tap do (testDir: Pathname):
            testDir.createDirectory()
            #testDir.createDirectory("bin")
            #testDir.createDirectory("src")
            #testDir.createDirectory("tests")
            testDir.createFile("FILE_A")
            testDir.createRegularFile("FILE_B")
        check true == pathname.isDirectory()
        pathname.removeDirectoryTree()


    test "#tap() should take a function providing self as param":
        let pathname = Pathname.new(fixturePath("TEST_TAP_DIR"))
        pathname.tap do (inner: Pathname):
            check inner == pathname


    test "#tap() should return self for Method-Chaining":
        let pathname = Pathname.new(fixturePath("TEST_TAP_DIR"))
        let pathname2 = pathname.tap do (inner: Pathname):
            discard
        check pathname2 == pathname
