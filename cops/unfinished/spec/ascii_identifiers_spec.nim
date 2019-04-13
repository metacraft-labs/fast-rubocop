
import
  ascii_identifiers, test_tools

suite "AsciiIdentifiers":
  var cop = AsciiIdentifiers()
  test "registers an offense for a variable name with non-ascii chars":
    expectOffense("""      älg = 1
      ^ Use only ascii symbols in identifiers.
""".stripIndent)
  test "registers an offense for a variable name with mixed chars":
    expectOffense("""      foo∂∂bar = baz
         ^^ Use only ascii symbols in identifiers.
""".stripIndent)
  test "accepts identifiers with only ascii chars":
    expectNoOffenses("x.empty?")
  test "does not get confused by a byte order mark":
    expectNoOffenses("""      ﻿
      puts 'foo'
""".stripIndent)
  test "does not get confused by an empty file":
    expectNoOffenses("")
