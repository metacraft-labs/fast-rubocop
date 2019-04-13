
import
  else_layout, test_tools

suite "ElseLayout":
  var cop = ElseLayout()
  test "registers an offense for expr on same line as else":
    expectOffense("""      if something
        test
      else ala
           ^^^ Odd `else` layout detected. Did you mean to use `elsif`?
        something
        test
      end
""".stripIndent)
  test "accepts proper else":
    expectNoOffenses("""      if something
        test
      else
        something
        test
      end
""".stripIndent)
  test "accepts single-expr else regardless of layout":
    expectNoOffenses("""      if something
        test
      else bala
      end
""".stripIndent)
  test "can handle elsifs":
    expectOffense("""      if something
        test
      elsif something
        bala
      else ala
           ^^^ Odd `else` layout detected. Did you mean to use `elsif`?
        something
        test
      end
""".stripIndent)
  test "handles ternary ops":
    expectNoOffenses("x ? a : b")
  test "handles modifier forms":
    expectNoOffenses("x if something")
