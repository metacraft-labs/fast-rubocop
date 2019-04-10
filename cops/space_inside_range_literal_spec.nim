
import
  space_inside_range_literal, test_tools

suite "SpaceInsideRangeLiteral":
  var cop = SpaceInsideRangeLiteral()
  test "registers an offense for space inside .. literal":
    expectOffense("""      1 .. 2
      ^^^^^^ Space inside range literal.
      1.. 2
      ^^^^^ Space inside range literal.
      1 ..2
      ^^^^^ Space inside range literal.
""".stripIndent)
  test "accepts no space inside .. literal":
    expectNoOffenses("1..2")
  test "registers an offense for space inside ... literal":
    expectOffense("""      1 ... 2
      ^^^^^^^ Space inside range literal.
      1... 2
      ^^^^^^ Space inside range literal.
      1 ...2
      ^^^^^^ Space inside range literal.
""".stripIndent)
  test "accepts no space inside ... literal":
    expectNoOffenses("1...2")
  test "accepts complex range literal with space in it":
    expectNoOffenses("0...(line - 1)")
  test "accepts multiline range literal with no space in it":
    expectNoOffenses("""      x = 0..
          10
""".stripIndent)
  test "registers an offense in multiline range literal with space in it":
    expectOffense("""      x = 0 ..
          ^^^^ Space inside range literal.
          10
""".stripIndent)
  test "autocorrects space around .. literal":
    var corrected = autocorrectSource("1  .. 2")
    expect(corrected).to(eq("1..2"))
  test "autocorrects space around ... literal":
    var corrected = autocorrectSource("1  ... 2")
    expect(corrected).to(eq("1...2"))
