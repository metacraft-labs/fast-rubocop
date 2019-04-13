
import
  string_conversion_in_interpolation, test_tools

suite "StringConversionInInterpolation":
  var cop = StringConversionInInterpolation()
  test "registers an offense for #to_s in interpolation":
    expectOffense("""      "this is the #{result.to_s}"
                            ^^^^ Redundant use of `Object#to_s` in interpolation.
""".stripIndent)
  test "detects #to_s in an interpolation with several expressions":
    expectOffense("""      "this is the #{top; result.to_s}"
                                 ^^^^ Redundant use of `Object#to_s` in interpolation.
""".stripIndent)
  test "accepts #to_s with arguments in an interpolation":
    expectNoOffenses("\"this is a #{result.to_s(8)}\"")
  test "accepts interpolation without #to_s":
    expectNoOffenses("\"this is the #{result}\"")
  test "does not explode on implicit receiver":
    expectOffense("""      "#{to_s}"
         ^^^^ Use `self` instead of `Object#to_s` in interpolation.
""".stripIndent)
  test "does not explode on empty interpolation":
    expectNoOffenses("\"this is #{} silly\"")
  test "autocorrects by removing the redundant to_s":
    var corrected = autocorrectSource("\"some #{something.to_s}\"")
    expect(corrected).to(eq("\"some #{something}\""))
  test "autocorrects implicit receiver by replacing to_s with self":
    var corrected = autocorrectSource("\"some #{to_s}\"")
    expect(corrected).to(eq("\"some #{self}\""))
