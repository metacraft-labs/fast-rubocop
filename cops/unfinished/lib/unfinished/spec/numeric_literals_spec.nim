
import
  numeric_literals, test_tools

RSpec.describe(NumericLiterals, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"MinDigits": 5}.newTable())
  test "registers an offense for a long undelimited integer":
    expectOffense("""      a = 12345
          ^^^^^ Use underscores(_) as thousands separator and separate every 3 digits with them.
""".stripIndent)
  test "registers an offense for a float with a long undelimited integer part":
    expectOffense("""      a = 123456.789
          ^^^^^^^^^^ Use underscores(_) as thousands separator and separate every 3 digits with them.
""".stripIndent)
  test "accepts integers with less than three places at the end":
    expectNoOffenses("""      a = 123_456_789_00
      b = 819_2
""".stripIndent)
  test "registers an offense for an integer with misplaced underscore":
    inspectSource("""      a = 123_456_78_90_00
      b = 1_8192
""".stripIndent)
    expect(cop().offenses.size).to(eq(2))
    expect(cop().configToAllowOffenses).to(eq())
  test "accepts long numbers with underscore":
    expectNoOffenses("""      a = 123_456
      b = 123_456.55
""".stripIndent)
  test "accepts a short integer without underscore":
    expectNoOffenses("a = 123")
  test "does not count a leading minus sign as a digit":
    expectNoOffenses("a = -1230")
  test "accepts short numbers without underscore":
    expectNoOffenses("""      a = 123
      b = 123.456
""".stripIndent)
  test "ignores non-decimal literals":
    expectNoOffenses("""      a = 0b1010101010101
      b = 01717171717171
      c = 0xab11111111bb
""".stripIndent)
  test "autocorrects a long integer offense":
    var corrected = autocorrectSource("a = 123456")
    expect(corrected).to(eq("a = 123_456"))
  test "autocorrects an integer with misplaced underscore":
    var corrected = autocorrectSource("a = 123_456_78_90_00")
    expect(corrected).to(eq("a = 123_456_789_000"))
  test "autocorrects negative numbers":
    var corrected = autocorrectSource("a = -123456")
    expect(corrected).to(eq("a = -123_456"))
  test "autocorrects floating-point numbers":
    var corrected = autocorrectSource("a = 123456.78")
    expect(corrected).to(eq("a = 123_456.78"))
  test "autocorrects negative floating-point numbers":
    var corrected = autocorrectSource("a = -123456.78")
    expect(corrected).to(eq("a = -123_456.78"))
  context("strict", proc (): void =
    let("cop_config", proc (): void =
      {"MinDigits": 5, "Strict": true}.newTable())
    test "registers an offense for an integer with misplaced underscore":
      expectOffense("""        a = 123_456_78_90_00
            ^^^^^^^^^^^^^^^^ Use underscores(_) as thousands separator and separate every 3 digits with them.
""".stripIndent)))
