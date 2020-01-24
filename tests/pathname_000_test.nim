###
# Test for Pathname-Module in Nim.
#
# Run Tests:
# ----------
#     $ nim compile --run tests/pathname_000_test
#
# :Author:   Raimund Hübel <raimund.huebel@googlemail.com>
###

import unittest
import pathname


suite "Pathname 000 Tests":

    test "TODO: Adding more functionality to Pathname":
        check false

    test "Pathname is defined":
        check compiles(Pathname)

    test "#add()":
        check pathname.add(1, 2) == 3
