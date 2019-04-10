
import
  range_include, test_tools

suite "RangeInclude":
  var cop = RangeInclude()
  test "autocorrects (a..b).include? without parens":
    var newSource = autocorrectSource("(a..b).include? 1")
    expect(newSource).to(eq("(a..b).cover? 1"))
  test "autocorrects (a...b).include? without parens":
    var newSource = autocorrectSource("(a...b).include? 1")
    expect(newSource).to(eq("(a...b).cover? 1"))
  test "autocorrects (a..b).include? with parens":
    var newSource = autocorrectSource("(a..b).include?(1)")
    expect(newSource).to(eq("(a..b).cover?(1)"))
  test "autocorrects (a...b).include? with parens":
    var newSource = autocorrectSource("(a...b).include?(1)")
    expect(newSource).to(eq("(a...b).cover?(1)"))
  test "formats the error message correctly for (a..b).include? 1":
    expectOffense("""      (a..b).include? 1
             ^^^^^^^^ Use `Range#cover?` instead of `Range#include?`.
""".stripIndent)
