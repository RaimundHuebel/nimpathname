###
# Test for Pathname-Module in Nim.
#
# Run Tests:
# ----------
#     $ nim compile --run tests/pathname_000_test
#
# :Author:   Raimund Hübel <raimund.huebel@googlemail.com>
###


import pathname

import os
import unittest
import test_helper


suite "Pathname Tests 000":


    test "Pathname is defined":
        check compiles(Pathname)


    test "Pathname.new()":
        let aPathname: Pathname = Pathname.new()
        check os.getCurrentDir() == aPathname.toPathStr()


    test "Pathname.new(path)":
        let aPathname: Pathname = Pathname.new("hello")
        check "hello" == aPathname.toPathStr()

        check ""      == Pathname.new(""     ).toPathStr()
        check " "     == Pathname.new(" "    ).toPathStr()
        check "/"     == Pathname.new("/"    ).toPathStr()
        check "/abc"  == Pathname.new("/abc" ).toPathStr()
        check "/abc/" == Pathname.new("/abc/").toPathStr()
        check "abc"   == Pathname.new("abc"  ).toPathStr()
        check "cde/"  == Pathname.new("cde/" ).toPathStr()


    test "Pathname.fromCurrentDir()":
        let aPathname: Pathname = Pathname.fromCurrentDir()
        check os.getCurrentDir() == aPathname.toPathStr()


    test "Pathname.fromAppDir()":
        let aPathname: Pathname = Pathname.fromAppDir()
        check os.getAppDir() == aPathname.toPathStr()


    test "Pathname.fromAppFile()":
        let aPathname: Pathname = Pathname.fromAppFile()
        check os.getAppFilename() == aPathname.toPathStr()


    test "Pathname.fromRootDir()":
        let aPathname: Pathname = Pathname.fromRootDir()
        check "/" == aPathname.toPathStr()


    test "Pathname.fromUserConfigDir()":
        let aPathname: Pathname = Pathname.fromUserConfigDir()
        check os.getConfigDir() == aPathname.toPathStr()


    test "Pathname.fromUserHomeDir()":
        let aPathname: Pathname = Pathname.fromUserHomeDir()
        check os.getHomeDir() == aPathname.toPathStr()


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
        check os.getCurrentDir() == Pathname.new().toPathStr()

        check ""      == Pathname.new(""   ).toPathStr()
        check " "     == Pathname.new(" "  ).toPathStr()
        check "   "   == Pathname.new("   ").toPathStr()
        check "/"     == Pathname.new("/").toPathStr()
        check "/abc"  == Pathname.new("/abc").toPathStr()
        check "/abc/" == Pathname.new("/abc/").toPathStr()
        check "abc"   == Pathname.new("abc").toPathStr()
        check "cde/"  == Pathname.new("cde/").toPathStr()


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


    test "#dirname()":
        check "/" == Pathname.new("/"  ).dirname().toPathStr()
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


    test "#extname() (edgcase_00)":
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


    test "#extname() (edgcase_01)":
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


    test "#extname() (edgcase_02)":
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


    test "#extname() (edgcase_03)":
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


    test "#extname() (edgcase_04)":
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


    test "#extname() (edgcase_05a)":
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


    test "#extname() (edgcase_05b)":
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


    test "#extname() (edgcase_05c)":
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


    test "#extname() (edgcase_06a)":
        check "" == Pathname.new("a.").extname()
        check "" == Pathname.new("/a.").extname()
        check "" == Pathname.new("//a.").extname()
        check "" == Pathname.new("///a.").extname()


    test "#extname() (edgcase_06b)":
        check "" == Pathname.new(" .").extname()
        check "" == Pathname.new("/ .").extname()
        check "" == Pathname.new("// .").extname()
        check "" == Pathname.new("/// .").extname()


    test "#extname() (edgcase_06c)":
        check "" == Pathname.new("a./").extname()
        check "" == Pathname.new("/a.//").extname()
        check "" == Pathname.new("//a.///").extname()
        check "" == Pathname.new("///a.////").extname()


    test "#extname() (edgcase_06d)":
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



    test "#isExisting() with regular files":
        check true == Pathname.new(fixturePath("README.md"  )).isExisting()

        check true == Pathname.new(fixturePath("sample_dir"  )).isExisting()
        check true == Pathname.new(fixturePath("sample_dir/" )).isExisting()
        check true == Pathname.new(fixturePath("sample_dir//")).isExisting()

        check true == Pathname.new(fixturePath("sample_dir/a_file"  )).isExisting()
        #check true == Pathname.new(fixturePath("sample_dir/a_file/" )).isExisting() # TODO: fails
        #check true == Pathname.new(fixturePath("sample_dir/a_file//")).isExisting() # TODO: fails

        check true == Pathname.new(fixturePath("sample_dir/a_file.no2"  )).isExisting()
        #check true == Pathname.new(fixturePath("sample_dir/a_file.no2/" )).isExisting() # TODO: fails
        #check true == Pathname.new(fixturePath("sample_dir/a_file.no2//")).isExisting() # TODO: fails

        check false == Pathname.new(fixturePath("non_existing_file"  )).isExisting()
        check false == Pathname.new(fixturePath("non_existing_file/" )).isExisting()
        check false == Pathname.new(fixturePath("non_existing_file//")).isExisting()

        check false == Pathname.new(fixturePath("sample_dir//non_existing_file"  )).isExisting()
        check false == Pathname.new(fixturePath("sample_dir//non_existing_file/" )).isExisting()
        check false == Pathname.new(fixturePath("sample_dir//non_existing_file//")).isExisting()

        check false == Pathname.new(fixturePath("non_existing_dir//non_existing_file"  )).isExisting()
        check false == Pathname.new(fixturePath("non_existing_dir//non_existing_file/" )).isExisting()
        check false == Pathname.new(fixturePath("non_existing_dir//non_existing_file//")).isExisting()

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

        check false == Pathname.new(fixturePath("non_existing_dir"  )).isExisting()
        check false == Pathname.new(fixturePath("non_existing_dir/" )).isExisting()
        check false == Pathname.new(fixturePath("non_existing_dir//")).isExisting()

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


    test "#isRegularFile()":
        check true == Pathname.new(fixturePath("sample_dir/a_file"  )).isRegularFile()
        #check true == Pathname.new(fixturePath("sample_dir/a_file/" )).isRegularFile() # TODO: fails
        #check true == Pathname.new(fixturePath("sample_dir/a_file//")).isRegularFile() # TODO: fails

        check false == Pathname.new(fixturePath("sample_dir"  )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir/" )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir//")).isRegularFile()

        check false == Pathname.new(fixturePath("sample_dir/a_dir"  )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir/a_dir/" )).isRegularFile()
        check false == Pathname.new(fixturePath("sample_dir/a_dir//")).isRegularFile()

        check true == Pathname.new(fixturePath("sample_dir/a_file.no2"  )).isRegularFile()
        #check true == Pathname.new(fixturePath("sample_dir/a_file.no2/" )).isRegularFile() # TODO: fails
        #check true == Pathname.new(fixturePath("sample_dir/a_file.no2//")).isRegularFile() # TODO: fails

        check false == Pathname.new(fixturePath("non_existing_file"  )).isRegularFile()
        check false == Pathname.new(fixturePath("non_existing_file/" )).isRegularFile()
        check false == Pathname.new(fixturePath("non_existing_file//")).isRegularFile()

        check false == Pathname.new("/dev/null").isRegularFile()
        check false == Pathname.new("/dev/zero").isRegularFile()


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

        check false == Pathname.new(fixturePath("non_existing_dir"  )).isDirectory()
        check false == Pathname.new(fixturePath("non_existing_dir/" )).isDirectory()
        check false == Pathname.new(fixturePath("non_existing_dir//")).isDirectory()


    test "#isSymlink()":
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

        check false == Pathname.new(fixturePath("non_existing_dir"  )).isSymlink()
        check false == Pathname.new(fixturePath("non_existing_dir/" )).isSymlink()
        check false == Pathname.new(fixturePath("non_existing_dir//")).isSymlink()

        check "TODO: further Tests on #isSymlink" == ""



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
        check false == Pathname.new("/dev/NON_EXISTING//").isDeviceFile()


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
        check false == Pathname.new("/dev/NON_EXISTING//").isCharacterDeviceFile()


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
        check false == Pathname.new("/dev/NON_EXISTING//").isBlockDeviceFile()



    test "#fileType()":
        check true == Pathname.new(fixturePath("sample_dir/a_file")).fileType().isRegularFile()

        check true == Pathname.new(fixturePath("sample_dir")).fileType().isDirectory()

        check true == Pathname.new(fixturePath("/dev/null")).fileType().isCharacterDeviceFile()

        check true == Pathname.new(fixturePath("/dev/loop0")).fileType().isBlockDeviceFile()

        check true == Pathname.new(fixturePath("/dev/null") ).fileType().isDeviceFile()
        check true == Pathname.new(fixturePath("/dev/loop0")).fileType().isDeviceFile()

        check "TODO: Further test Pathname#fileType (also bad-cases)" == ""
