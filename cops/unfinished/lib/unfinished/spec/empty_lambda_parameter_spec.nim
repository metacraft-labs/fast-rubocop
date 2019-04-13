
import
  empty_lambda_parameter, test_tools

suite "EmptyLambdaParameter":
  var cop = EmptyLambdaParameter()
  let("config", proc (): void =
    Config.new)
  test "registers an offense for an empty block parameter with a lambda":
    expectOffense("""      -> () { do_something }
         ^^ Omit parentheses for the empty lambda parameters.
""".stripIndent)
    expectCorrection("      -> { do_something }\n".stripIndent)
  test "accepts a keyword lambda":
    expectNoOffenses("      lambda { || do_something }\n")
  test "does not crash on a super":
    expectNoOffenses("""      def foo
        super { || do_something }
      end
""")
