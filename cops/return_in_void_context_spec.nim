
import
  return_in_void_context, test_tools

suite "ReturnInVoidContext":
  var cop = ReturnInVoidContext()
  context("with an initialize method containing a return with a value", proc (): void =
    test "registers an offense":
      expectOffense("""        class A
          def initialize
            return :qux if bar?
            ^^^^^^ Do not return a value in `initialize`.
          end
        end
""".stripIndent))
  context("with an initialize method containing a return without a value", proc (): void =
    test "accepts":
      expectNoOffenses("""        class A
          def initialize
            return if bar?
          end
        end
""".stripIndent))
  context("with a setter method containing a return with a value", proc (): void =
    test "registers an offense":
      expectOffense("""        class A
          def foo=(bar)
            return 42
            ^^^^^^ Do not return a value in `foo=`.
          end
        end
""".stripIndent))
  context("with a setter method containing a return without a value", proc (): void =
    test "accepts":
      expectNoOffenses("""        class A
          def foo=(bar)
            return
          end
        end
""".stripIndent))
  context("with a non initialize method containing a return", proc (): void =
    test "accepts":
      expectNoOffenses("""        class A
          def bar
            foo
            return :qux if bar?
            foo
          end
        end
""".stripIndent))
  context("with a class method called initialize containing a return", proc (): void =
    test "accepts":
      expectNoOffenses("""        class A
          def self.initialize
            foo
            return :qux if bar?
            foo
          end
        end
""".stripIndent))
  context("when return is in top scope", proc (): void =
    test "accepts":
      expectNoOffenses("        return if true\n".stripIndent))
