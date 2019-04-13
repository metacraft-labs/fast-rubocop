
import
  ensure_return, test_tools

suite "EnsureReturn":
  var cop = EnsureReturn()
  test "registers an offense for return in ensure":
    expectOffense("""      begin
        something
      ensure
        file.close
        return
        ^^^^^^ Do not return from an `ensure` block.
      end
""".stripIndent)
  test "does not register an offense for return outside ensure":
    expectNoOffenses("""      begin
        something
        return
      ensure
        file.close
      end
""".stripIndent)
  test "does not check when ensure block has no body":
    expectNoOffenses("""      begin
        something
      ensure
      end
""".stripIndent)
