
import
  inherit_exception, test_tools

RSpec.describe(InheritException, "config", proc (): void =
  var cop = ()
  context("when class inherits from `Exception`", proc (): void =
    context("with enforced style set to `runtime_error`", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyle": "runtime_error"}.newTable())
      test "registers an offense":
        expectOffense("""          class C < Exception; end
                    ^^^^^^^^^ Inherit from `RuntimeError` instead of `Exception`.
""".stripIndent)
      test "auto-corrects":
        var corrected = autocorrectSource("class C < Exception; end")
        expect(corrected).to(eq("class C < RuntimeError; end")))
    context("with enforced style set to `standard_error`", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyle": "standard_error"}.newTable())
      test "registers an offense":
        expectOffense("""          class C < Exception; end
                    ^^^^^^^^^ Inherit from `StandardError` instead of `Exception`.
""".stripIndent)
      test "auto-corrects":
        var corrected = autocorrectSource("class C < Exception; end")
        expect(corrected).to(eq("class C < StandardError; end")))))
