
import
  empty_interpolation, test_tools

suite "EmptyInterpolation":
  var cop = EmptyInterpolation()
  test "registers an offense for #{} in interpolation":
    expectOffense("""      "this is the #{}"
                   ^^^ Empty interpolation detected.
""".stripIndent)
  test "registers an offense for #{ } in interpolation":
    expectOffense("""      "this is the #{ }"
                   ^^^^ Empty interpolation detected.
""".stripIndent)
  test "accepts non-empty interpolation":
    expectNoOffenses("\"this is #{top} silly\"")
  test "autocorrects empty interpolation":
    var newSource = autocorrectSource("\"this is the #{}\"")
    expect(newSource).to(eq("\"this is the \""))
  test "autocorrects empty interpolation containing a space":
    var newSource = autocorrectSource("\"this is the #{ }\"")
    expect(newSource).to(eq("\"this is the \""))
