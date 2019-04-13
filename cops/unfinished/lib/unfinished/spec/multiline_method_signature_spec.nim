
import
  multiline_method_signature, test_tools

RSpec.describe(MultilineMethodSignature, "config", proc (): void =
  var cop = ()
  context("when arguments span multiple lines", proc (): void =
    context("when defining an instance method", proc (): void =
      test "registers an offense when `end` is on the following line":
        expectOffense("""          def foo(bar,
          ^^^^^^^^^^^^ Avoid multi-line method signatures.
                  baz)
          end
""".stripIndent)
      test "registers an offense when `end` is on the same line":
        expectOffense("""          def foo(bar,
          ^^^^^^^^^^^^ Avoid multi-line method signatures.
                  baz); end
""".stripIndent))
    context("when arguments span a single line", proc (): void =
      test "registers an offense when closing paren is on the following line":
        expectOffense("""          def foo(bar
          ^^^^^^^^^^^ Avoid multi-line method signatures.
              )
          end
""".stripIndent))
    context("when method signature is on a single line", proc (): void =
      test "does not register an offense for parameterized method":
        expectNoOffenses("""          def foo(bar, baz)
          end
""".stripIndent)
      test "does not register an offense for unparameterized method":
        expectNoOffenses("""          def foo
          end
""".stripIndent)))
  context("when arguments span multiple lines", proc (): void =
    context("when defining an class method", proc (): void =
      test "registers an offense when `end` is on the following line":
        expectOffense("""          def self.foo(bar,
          ^^^^^^^^^^^^^^^^^ Avoid multi-line method signatures.
                  baz)
          end
""".stripIndent)
      test "registers an offense when `end` is on the same line":
        expectOffense("""          def self.foo(bar,
          ^^^^^^^^^^^^^^^^^ Avoid multi-line method signatures.
                  baz); end
""".stripIndent))
    context("when arguments span a single line", proc (): void =
      test "registers an offense when closing paren is on the following line":
        expectOffense("""          def self.foo(bar
          ^^^^^^^^^^^^^^^^ Avoid multi-line method signatures.
              )
          end
""".stripIndent))
    context("when method signature is on a single line", proc (): void =
      test "does not register an offense for parameterized method":
        expectNoOffenses("""          def self.foo(bar, baz)
          end
""".stripIndent)
      test "does not register an offense for unparameterized method":
        expectNoOffenses("""          def self.foo
          end
""".stripIndent))
    context("when correction would exceed maximum line length", proc (): void =
      let("other_cops", proc (): void =
        {"Metrics/LineLength": {"Max": 5}.newTable()}.newTable())
      test "does not register an offense":
        expectNoOffenses("""          def foo(bar,
                  baz)
          end
""".stripIndent))
    context("when correction would not exceed maximum line length", proc (): void =
      let("other_cops", proc (): void =
        {"Metrics/LineLength": {"Max": 25}.newTable()}.newTable())
      test "registers an offense":
        expectOffense("""          def foo(bar,
          ^^^^^^^^^^^^ Avoid multi-line method signatures.
                  baz)
            qux.qux
          end
""".stripIndent))))
