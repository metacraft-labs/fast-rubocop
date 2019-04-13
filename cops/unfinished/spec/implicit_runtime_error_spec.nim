
import
  implicit_runtime_error, test_tools

suite "ImplicitRuntimeError":
  var cop = ImplicitRuntimeError()
  test "registers an offense for `raise` without error class":
    expectOffense("""      raise 'message'
      ^^^^^^^^^^^^^^^ Use `raise` with an explicit exception class and message, rather than just a message.
""".stripIndent)
  test "registers an offense for `fail` without error class":
    expectOffense("""      fail 'message'
      ^^^^^^^^^^^^^^ Use `fail` with an explicit exception class and message, rather than just a message.
""".stripIndent)
  test "registers an offense for `raise` with a multiline string":
    expectOffense("""      raise 'message' \
      ^^^^^^^^^^^^^^^^^ Use `raise` with an explicit exception class and message, rather than just a message.
            '2nd line'
""".stripIndent)
  test "registers an offense for `fail` with a multiline string":
    expectOffense("""      fail 'message' \
      ^^^^^^^^^^^^^^^^ Use `fail` with an explicit exception class and message, rather than just a message.
            '2nd line'
""".stripIndent)
  test "does not register an offense for `raise` with an error class":
    expectNoOffenses("      raise StandardError, \'message\'\n".stripIndent)
  test "does not register an offense for `fail` with an error class":
    expectNoOffenses("      fail StandardError, \'message\'\n".stripIndent)
  test "does not register an offense for `raise` without arguments":
    expectNoOffenses("raise")
  test "does not register an offense for `fail` without arguments":
    expectNoOffenses("fail")
