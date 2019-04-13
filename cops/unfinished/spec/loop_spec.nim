
import
  loop, test_tools

suite "Loop":
  var cop = Loop()
  test "registers an offense for begin/end/while":
    expectOffense("""      begin something; top; end while test
                                ^^^^^ Use `Kernel#loop` with `break` rather than `begin/end/until`(or `while`).
""".stripIndent)
  test "registers an offense for begin/end/until":
    expectOffense("""      begin something; top; end until test
                                ^^^^^ Use `Kernel#loop` with `break` rather than `begin/end/until`(or `while`).
""".stripIndent)
  test "accepts normal while":
    expectNoOffenses("while test; one; two; end")
  test "accepts normal until":
    expectNoOffenses("until test; one; two; end")
