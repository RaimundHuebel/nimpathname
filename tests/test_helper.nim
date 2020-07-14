###
# Testhelper-Module intended to be included for all other Test-Modules.
# Provides to get access to different Test-Utilities, -Data and -Fixtures
#
# compile and run + tooling:
#
#   $ nim compile --run all_tests.nim
#
# author:
#   Raimund Hübel <raimund.huebel@googlemail.com>
###

import os
import strutils


## The Path to the Fixture-Directory.
const FixtureDirectoryPath*: string =
    currentSourcePath().parentDir().joinPath("_fixtures")


proc fixturePath*(additionalPathComponents: varargs[string]): string =
    ## Returns a resolved/absolute Path to a Fixture-File/-Directory, adopted to the running plattform,
    ## for the given a relative Path to the Fixture-Directory ("_fixtures").
    ## @example fixturePath() -> "/home/aUser/.../_fixtures"  |  "C:\users\aUser\...\_fixtures"
    ## @example fixturePath("SAMPLE.txt") -> "/home/aUser/.../_fixtures/SAMPLE.txt"  |  "C:\users\aUser\...\_fixtures\SAMPLE.txt"
    ## @example fixturePath("test", "SAMPLE.txt") -> "/home/aUser/.../_fixtures/test/SAMPLE.txt"  |  "C:\users\aUser\...\_fixtures\test\SAMPLE.txt"
    if additionalPathComponents.len == 0:
        return FixtureDirectoryPath
    var resultPathComponents = newSeq[string](additionalPathComponents.len + 1)
    resultPathComponents[0] = FixtureDirectoryPath
    for idx in (0..<additionalPathComponents.len):
        resultPathComponents[idx+1] = additionalPathComponents[idx]
    return resultPathComponents.join($os.DirSep)


proc readFixtureFile*(relativeToFixturesPath: string): string =
    ## Reads a file from Fixture-Directory and returns it contents as string.
    ## Raises an error if this is not possible.
    return fixturePath(relativeToFixturesPath).readFile()
