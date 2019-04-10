
import
  send, test_tools

suite "Send":
  var cop = Send()
  context("with send", proc (): void =
    context("and with a receiver", proc (): void =
      test "registers an offense for an invocation with args":
        expectOffense("""          Object.send(:inspect)
                 ^^^^ Prefer `Object#__send__` or `Object#public_send` to `send`.
""".stripIndent)
      context("when using safe navigation operator", "ruby23", proc (): void =
        test "registers an offense for an invocation with args":
          expectOffense("""            Object&.send(:inspect)
                    ^^^^ Prefer `Object#__send__` or `Object#public_send` to `send`.
""".stripIndent))
      test "does not register an offense for an invocation without args":
        expectNoOffenses("Object.send"))
    context("and without a receiver", proc (): void =
      test "registers an offense for an invocation with args":
        expectOffense("""          send(:inspect)
          ^^^^ Prefer `Object#__send__` or `Object#public_send` to `send`.
""".stripIndent)
      test "does not register an offense for an invocation without args":
        expectNoOffenses("send")))
  context("with __send__", proc (): void =
    context("and with a receiver", proc (): void =
      test "does not register an offense for an invocation with args":
        expectNoOffenses("Object.__send__(:inspect)")
      test "does not register an offense for an invocation without args":
        expectNoOffenses("Object.__send__"))
    context("and without a receiver", proc (): void =
      test "does not register an offense for an invocation with args":
        expectNoOffenses("__send__(:inspect)")
      test "does not register an offense for an invocation without args":
        expectNoOffenses("__send__")))
  context("with public_send", proc (): void =
    context("and with a receiver", proc (): void =
      test "does not register an offense for an invocation with args":
        expectNoOffenses("Object.public_send(:inspect)")
      test "does not register an offense for an invocation without args":
        expectNoOffenses("Object.public_send"))
    context("and without a receiver", proc (): void =
      test "does not register an offense for an invocation with args":
        expectNoOffenses("public_send(:inspect)")
      test "does not register an offense for an invocation without args":
        expectNoOffenses("public_send")))
