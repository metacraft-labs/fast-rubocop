
import
  types

import
  if_with_semicolon, test_tools

suite "IfWithSemicolon":
  var cop = IfWithSemicolon()
  test "registers an offense for one line if/;/end":
    expectOffense("""      if cond; run else dont end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use if x; Use the ternary operator instead.
""".stripIndent)
  test "accepts one line if/then/end":
    expectNoOffenses("if cond then run else dont end")
  test "can handle modifier conditionals":
    expectNoOffenses("""      class Hash
      end if RUBY_VERSION < "1.8.7"
""".stripIndent)
