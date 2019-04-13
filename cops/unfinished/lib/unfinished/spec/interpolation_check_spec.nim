
import
  interpolation_check, test_tools

suite "InterpolationCheck":
  var cop = InterpolationCheck()
  test "registers an offense for interpolation in single quoted string":
    expectOffense("""      'foo #{bar}'
      ^^^^^^^^^^^^ Interpolation in single quoted string detected. Use double quoted strings if you need interpolation.
""".stripIndent)
  test "does not register an offense for properly interpolation strings":
    expectNoOffenses("      hello = \"foo #{bar}\"\n".stripIndent)
  test "does not register an offense for interpolation in nested strings":
    expectNoOffenses("      foo = \"bar \'#{baz}\' qux\"\n".stripIndent)
  test "does not register an offense for interpolation in a regexp":
    expectNoOffenses("      /\\#{20}/\n".stripIndent)
  test "does not register an offense for an escaped interpolation":
    expectNoOffenses("      \"\\#{msg}\"\n".stripIndent)
  test "does not crash for \\xff":
    expectNoOffenses("      foo = \"\\xff\"\n".stripIndent)
  test "does not register an offense for escaped crab claws in dstr":
    expectNoOffenses("      foo = \"alpha #{variable} beta \\#{gamma}\\\" delta\"\n".stripIndent)
