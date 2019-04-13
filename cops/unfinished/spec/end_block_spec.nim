
import
  end_block, test_tools

suite "EndBlock":
  var cop = EndBlock()
  test "reports an offense for an END block":
    expectOffense("""      END { test }
      ^^^ Avoid the use of `END` blocks. Use `Kernel#at_exit` instead.
""".stripIndent)
