
import
  multiline_ternary_operator, test_tools

suite "MultilineTernaryOperator":
  var cop = MultilineTernaryOperator()
  test """registers offense when the if branch and the else branch are on a separate line from the condition""":
    expectOffense("""      a = cond ?
          ^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
        b : c
""".stripIndent)
  test "registers an offense when the false branch is on a separate line":
    expectOffense("""      a = cond ? b :
          ^^^^^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
          c
""".stripIndent)
  test "registers an offense when everything is on a separate line":
    expectOffense("""      a = cond ?
          ^^^^^^ Avoid multi-line ternary operators, use `if` or `unless` instead.
          b :
          c
""".stripIndent)
  test "accepts a single line ternary operator expression":
    expectNoOffenses("a = cond ? b : c")
