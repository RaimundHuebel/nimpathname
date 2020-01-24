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


## The Path to the Fixture-Directory.
const FixtureDirectoryPath*: string =
    currentSourcePath().parentDir().joinPath("_fixtures")


## Returns a resolved/absolute Path to a Fixture-File/-Directory,
## for the given a relative Path to the Fixture-Directory ("_fixtures").
## @example fixturePath("SAMPLE.txt") -> "/home/aUser/.../_fixtures/SAMPLE.txt"
proc fixturePath*(relativeToFixturesPath: string): string =
    return FixtureDirectoryPath & "/" & relativeToFixturesPath


## Reads a file from Fixture-Directory and returns it contents as string.
## Raises an error if this is not possible.
proc readFixtureFile*(relativeToFixturesPath: string): string =
    return fixturePath(relativeToFixturesPath).readFile()
