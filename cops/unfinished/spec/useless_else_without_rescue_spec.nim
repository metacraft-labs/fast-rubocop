
import
  useless_else_without_rescue, test_tools

suite "UselessElseWithoutRescue":
  var cop = UselessElseWithoutRescue()
  context("with `else` without `rescue`", proc (): void =
    test "registers an offense":
      expectOffense("""        begin
          do_something
        else
        ^^^^ `else` without `rescue` is useless.
          handle_unknown_errors
        end
""".stripIndent))
  context("with `else` with `rescue`", proc (): void =
    test "accepts":
      expectNoOffenses("""        begin
          do_something
        rescue ArgumentError
          handle_argument_error
        else
          handle_unknown_errors
        end
""".stripIndent))
