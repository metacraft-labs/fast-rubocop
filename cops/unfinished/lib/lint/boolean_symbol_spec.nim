
import
  types

import
  boolean_symbol, test_tools

RSpec.describe(BooleanSymbol, "config", proc () =
  var cop = ()
  test "registers an offense when using `:true`":
    expectOffense("""      :true
      ^^^^^ Symbol with a boolean name - you probably meant to use `true`.
""".stripIndent)
  test "registers an offense when using `:false`":
    expectOffense("""      :false
      ^^^^^^ Symbol with a boolean name - you probably meant to use `false`.
""".stripIndent)
  context("when using the new hash syntax", proc () =
    test "registers an offense when using `true:`":
      expectOffense("""        { true: 'Foo' }
          ^^^^ Symbol with a boolean name - you probably meant to use `true`.
""".stripIndent)
    test "registers an offense when using `false:`":
      expectOffense("""        { false: 'Bar' }
          ^^^^^ Symbol with a boolean name - you probably meant to use `false`.
""".stripIndent))
  test "does not register an offense when using regular symbol":
    expectNoOffenses("      :something\n".stripIndent)
  test "does not register an offense when using `true`":
    expectNoOffenses("      true\n".stripIndent)
  test "does not register an offense when using `false`":
    expectNoOffenses("      false\n".stripIndent))
