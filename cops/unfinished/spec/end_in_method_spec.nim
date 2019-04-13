
import
  end_in_method, test_tools

suite "EndInMethod":
  var cop = EndInMethod()
  test "registers an offense for def with an END inside":
    expectOffense("""      def test
        END { something }
        ^^^ `END` found in method definition. Use `at_exit` instead.
      end
""".stripIndent)
  test "registers an offense for defs with an END inside":
    expectOffense("""      def self.test
        END { something }
        ^^^ `END` found in method definition. Use `at_exit` instead.
      end
""".stripIndent)
  test "accepts END outside of def(s)":
    expectNoOffenses("END { something }")
