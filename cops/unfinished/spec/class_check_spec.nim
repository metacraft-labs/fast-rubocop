
import
  class_check, test_tools

RSpec.describe(ClassCheck, "config", proc (): void =
  var cop = ()
  context("when enforced style is is_a?", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "is_a?"}.newTable())
    test "registers an offense for kind_of?":
      expectOffense("""        x.kind_of? y
          ^^^^^^^^ Prefer `Object#is_a?` over `Object#kind_of?`.
""".stripIndent)
    test "auto-corrects kind_of? to is_a?":
      var corrected = autocorrectSource("x.kind_of? y")
      expect(corrected).to(eq("x.is_a? y")))
  context("when enforced style is kind_of?", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "kind_of?"}.newTable())
    test "registers an offense for is_a?":
      expectOffense("""        x.is_a? y
          ^^^^^ Prefer `Object#kind_of?` over `Object#is_a?`.
""".stripIndent)
    test "auto-corrects is_a? to kind_of?":
      var corrected = autocorrectSource("x.is_a? y")
      expect(corrected).to(eq("x.kind_of? y"))))
