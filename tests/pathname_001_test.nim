###
# Test for Pathname-Module in Nim.
#
# INFO:
#   pathname_check_entries_posix.json wurde durch das ruby-script pathnames_test_generator.rb erzeugt.
#
# Run Tests:
# ----------
#     $ nim compile --run tests/pathname_001_test
#
# :Author:   Raimund Hübel <raimund.huebel@googlemail.com>
###



import pathname

import json
import unittest
import test_helper


type PathnameCheckEntry = object
    path:       string
    isAbsolute: bool
    basename:   string
    dirname:    string
    extname:    string
    parent:     string
    cleanpath:  string


const pathnameCheckEntriesJsonStr = readFixtureFile("pathname_check_entries_posix.json")
let pathnameCheckEntriesJson = pathnameCheckEntriesJsonStr.parseJson()
let pathnameCheckEntries = pathnameCheckEntriesJson.to(seq[PathnameCheckEntry])
#echo pathnameCheckEntriesJson
#echo pathnameCheckEntries[10].path


suite "utils.pathname - type Pathname - Check Entries for Posix":


    test "PathnameCheckEntries are available":
        check pathnameCheckEntries.len > 60000


    test "Pathname.new(path) & toPathStr()":
        for checkEntry in pathnameCheckEntries:
            #echo "#Pathname.new & toPathStr - check: '" & checkEntry.path & "'"
            check checkEntry.path == Pathname.new(checkEntry.path).toPathStr()


    test "#isAbsolute()":
        for checkEntry in pathnameCheckEntries:
            #echo "#isAbsolute - check: '" & checkEntry.path & "'"
            check checkEntry.isAbsolute == Pathname.new(checkEntry.path).isAbsolute()


    test "#isRelative()":
        for checkEntry in pathnameCheckEntries:
            #echo "#isRelative - check: '" & checkEntry.path & "'"
            check (not checkEntry.isAbsolute) == Pathname.new(checkEntry.path).isRelative()


    test "#basename()":
        for checkEntry in pathnameCheckEntries:
            #echo "#basename - check: '" & checkEntry.path & "'"
            check checkEntry.basename == Pathname.new(checkEntry.path).basename().toPathStr()


    test "#dirname()":
        for checkEntry in pathnameCheckEntries:
            #echo "#dirname - check: '" & checkEntry.path & "'"
            check checkEntry.dirname == Pathname.new(checkEntry.path).dirname().toPathStr()


    test "#extname()":
        for checkEntry in pathnameCheckEntries:
            #echo "#extname - check: '" & checkEntry.path & "'"
            check checkEntry.extname == Pathname.new(checkEntry.path).extname()


    test "#normalize()":
        #info: alias for: #cleanpath()
        for checkEntry in pathnameCheckEntries:
            #echo "#normalize - check: '" & checkEntry.path & "'"
            check checkEntry.cleanpath == Pathname.new(checkEntry.path).normalize().toPathStr()


    test "#cleanpath()":
        #info: alias for: #normalize()
        for checkEntry in pathnameCheckEntries:
            #echo "#cleanpath - check: '" & checkEntry.path & "'"
            check checkEntry.cleanpath == Pathname.new(checkEntry.path).cleanpath().toPathStr()
