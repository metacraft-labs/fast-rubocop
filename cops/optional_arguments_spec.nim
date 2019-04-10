
import
  optional_arguments, test_tools

suite "OptionalArguments":
  var cop = OptionalArguments()
  test """registers an offense when an optional argument is followed by a required argument""":
    expectOffense("""      def foo(a = 1, b)
              ^^^^^ Optional arguments should appear at the end of the argument list.
      end
""".stripIndent)
  test """registers an offense for each optional argument when multiple optional arguments are followed by a required argument""":
    expectOffense("""      def foo(a = 1, b = 2, c)
              ^^^^^ Optional arguments should appear at the end of the argument list.
                     ^^^^^ Optional arguments should appear at the end of the argument list.
      end
""".stripIndent)
  test "allows methods without arguments":
    expectNoOffenses("""      def foo
      end
""".stripIndent)
  test "allows methods with only one required argument":
    expectNoOffenses("""      def foo(a)
      end
""".stripIndent)
  test "allows methods with only required arguments":
    expectNoOffenses("""      def foo(a, b, c)
      end
""".stripIndent)
  test "allows methods with only one optional argument":
    expectNoOffenses("""      def foo(a = 1)
      end
""".stripIndent)
  test "allows methods with only optional arguments":
    expectNoOffenses("""      def foo(a = 1, b = 2, c = 3)
      end
""".stripIndent)
  test "allows methods with multiple optional arguments at the end":
    expectNoOffenses("""      def foo(a, b = 2, c = 3)
      end
""".stripIndent)
  context("named params", proc (): void =
    context("with default values", proc (): void =
      test "allows optional arguments before an optional named argument":
        expectNoOffenses("""          def foo(a = 1, b: 2)
          end
""".stripIndent))
    context("required params", proc (): void =
      test """registers an offense for optional arguments that come before required arguments where there are name arguments""":
        expectOffense("""          def foo(a = 1, b, c:, d: 4)
                  ^^^^^ Optional arguments should appear at the end of the argument list.
          end
""".stripIndent)
      test "allows optional arguments before required named arguments":
        expectNoOffenses("""          def foo(a = 1, b:)
          end
""".stripIndent)
      test """allows optional arguments to come before a mix of required and optional named argument""":
        expectNoOffenses("""          def foo(a = 1, b:, c: 3)
          end
""".stripIndent)))
