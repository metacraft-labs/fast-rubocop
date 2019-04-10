
import
  string_methods, test_tools

RSpec.describe(StringMethods, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"intern": "to_sym"}.newTable())
  test "registers an offense":
    expectOffense("""      'something'.intern
                  ^^^^^^ Prefer `to_sym` over `intern`.
""".stripIndent)
  test "auto-corrects":
    var corrected = autocorrectSource("\'something\'.intern")
    expect(corrected).to(eq("\'something\'.to_sym"))
  context("when using safe navigation operator", "ruby23", proc (): void =
    test "registers an offense":
      expectOffense("""      something&.intern
                 ^^^^^^ Prefer `to_sym` over `intern`.
""".stripIndent)
    test "auto-corrects":
      var corrected = autocorrectSource("something&.intern")
      expect(corrected).to(eq("something&.to_sym"))))
