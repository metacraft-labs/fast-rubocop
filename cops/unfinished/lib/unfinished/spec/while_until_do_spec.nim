
import
  while_until_do, test_tools

suite "WhileUntilDo":
  var cop = WhileUntilDo()
  test "registers an offense for do in multiline while":
    expectOffense("""      while cond do
                 ^^ Do not use `do` with multi-line `while`.
      end
""".stripIndent)
    expectCorrection("""      while cond
      end
""".stripIndent)
  test "registers an offense for do in multiline until":
    expectOffense("""      until cond do
                 ^^ Do not use `do` with multi-line `until`.
      end
""".stripIndent)
    expectCorrection("""      until cond
      end
""".stripIndent)
  test "accepts do in single-line while":
    expectNoOffenses("while cond do something end")
  test "accepts do in single-line until":
    expectNoOffenses("until cond do something end")
  test "accepts multi-line while without do":
    expectNoOffenses("""      while cond
      end
""".stripIndent)
  test "accepts multi-line until without do":
    expectNoOffenses("""      until cond
      end
""".stripIndent)
