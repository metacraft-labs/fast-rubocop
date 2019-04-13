
import
  types

import
  nested_ternary_operator, test_tools

suite "NestedTernaryOperator":
  var cop = NestedTernaryOperator()
  test "registers an offense for a nested ternary operator expression":
    expectOffense("""      a ? (b ? b1 : b2) : a2
           ^^^^^^^^^^^ Ternary operators must not be nested. Prefer `if` or `else` constructs instead.
""".stripIndent)
  test "accepts a non-nested ternary operator within an if":
    expectNoOffenses("""      a = if x
        cond ? b : c
      else
        d
      end
""".stripIndent)
