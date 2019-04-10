
import
  array_join, test_tools

suite "ArrayJoin":
  var cop = ArrayJoin()
  test "registers an offense for an array followed by string":
    expectOffense("""      %w(one two three) * ", "
                        ^ Favor `Array#join` over `Array#*`.
""".stripIndent)
  test "autocorrects \'*\' to \'join\' when there are spaces":
    var corrected = autocorrectSource("%w(one two three) * \", \"")
    expect(corrected).to(eq("%w(one two three).join(\", \")"))
  test "autocorrects \'*\' to \'join\' when there are no spaces":
    var corrected = autocorrectSource("%w(one two three)*\", \"")
    expect(corrected).to(eq("%w(one two three).join(\", \")"))
  test "autocorrects \'*\' to \'join\' when setting to a variable":
    var corrected = autocorrectSource("foo = %w(one two three)*\", \"")
    expect(corrected).to(eq("foo = %w(one two three).join(\", \")"))
  test "does not register an offense for numbers":
    expectNoOffenses("%w(one two three) * 4")
  test "does not register an offense for ambiguous cases":
    expectNoOffenses("%w(one two three) * test")
