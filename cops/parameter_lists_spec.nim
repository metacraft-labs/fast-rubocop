
import
  parameter_lists, test_tools

RSpec.describe(ParameterLists, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"Max": 4, "CountKeywordArgs": true}.newTable())
  test "registers an offense for a method def with 5 parameters":
    expectOffense("""      def meth(a, b, c, d, e)
              ^^^^^^^^^^^^^^^ Avoid parameter lists longer than 4 parameters. [5/4]
      end
""".stripIndent)
  test "accepts a method def with 4 parameters":
    expectNoOffenses("""      def meth(a, b, c, d)
      end
""".stripIndent)
  test "accepts a proc with more than 4 parameters":
    expectNoOffenses("      proc { |a, b, c, d, e| }\n".stripIndent)
  test "accepts a lambda with more than 4 parameters":
    expectNoOffenses("      ->(a, b, c, d, e) { }\n".stripIndent)
  context("When CountKeywordArgs is true", proc (): void =
    test "counts keyword arguments as well":
      expectOffense("""        def meth(a, b, c, d: 1, e: 2)
                ^^^^^^^^^^^^^^^^^^^^^ Avoid parameter lists longer than 4 parameters. [5/4]
        end
""".stripIndent))
  context("When CountKeywordArgs is false", proc (): void =
    before(proc (): void =
      copConfig().[]=("CountKeywordArgs", false))
    test "does not count keyword arguments":
      expectNoOffenses("""        def meth(a, b, c, d: 1, e: 2)
        end
""".stripIndent)
    test "does not count keyword arguments without default values":
      expectNoOffenses("""        def meth(a, b, c, d:, e:)
        end
""".stripIndent)))
