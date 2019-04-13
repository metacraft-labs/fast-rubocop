
import
  percent_q_literals, test_tools

RSpec.describe(PercentQLiterals, "config", proc (): void =
  var cop = ()
  sharedExamples("accepts quote characters", proc (): void =
    test "accepts single quotes":
      expectNoOffenses("\'hi\'")
    test "accepts double quotes":
      expectNoOffenses("\"hi\""))
  sharedExamples("accepts any q string with backslash t", proc (): void =
    context("with special characters", proc (): void =
      test "accepts %q":
        expectNoOffenses("%q(\\t)")
      test "accepts %Q":
        expectNoOffenses("%Q(\\t)")))
  context("when EnforcedStyle is lower_case_q", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "lower_case_q"}.newTable())
    context("without interpolation", proc (): void =
      test "accepts %q":
        expectNoOffenses("%q(hi)")
      test "registers offense for %Q":
        expectOffense("""          %Q(hi)
          ^^^ Do not use `%Q` unless interpolation is needed. Use `%q`.
""".stripIndent)
      test "auto-corrects":
        var newSource = autocorrectSource("%Q(hi)")
        expect(newSource).to(eq("%q(hi)"))
      includeExamples("accepts quote characters")
      includeExamples("accepts any q string with backslash t"))
    context("with interpolation", proc (): void =
      test "accepts %Q":
        expectNoOffenses("%Q(#{1 + 2})")
      test "accepts %q":
        expectNoOffenses("%q(#{1 + 2})")
      includeExamples("accepts quote characters")))
  context("when EnforcedStyle is upper_case_q", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "upper_case_q"}.newTable())
    context("without interpolation", proc (): void =
      test "registers offense for %q":
        expectOffense("""          %q(hi)
          ^^^ Use `%Q` instead of `%q`.
""".stripIndent)
      test "accepts %Q":
        expectNoOffenses("%Q(hi)")
      test "auto-corrects":
        var newSource = autocorrectSource("%q[hi]")
        expect(newSource).to(eq("%Q[hi]"))
      includeExamples("accepts quote characters")
      includeExamples("accepts any q string with backslash t"))
    context("with interpolation", proc (): void =
      test "accepts %Q":
        expectNoOffenses("%Q(#{1 + 2})")
      test "accepts %q":
        expectNoOffenses("%q(#{1 + 2})")
      test "does not auto-correct":
        var
          source = "%q(#{1 + 2})"
          newSource = autocorrectSource(source)
        expect(newSource).to(eq(source))
      includeExamples("accepts quote characters"))))
