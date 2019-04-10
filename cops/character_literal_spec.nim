
import
  character_literal, test_tools

suite "CharacterLiteral":
  var cop = CharacterLiteral()
  test "registers an offense for character literals":
    expectOffense("""      x = ?x
          ^^ Do not use the character literal - use string literal instead.
""".stripIndent)
  test "registers an offense for literals like \\n":
    expectOffense("""      x = ?\n
          ^^^ Do not use the character literal - use string literal instead.
""".stripIndent)
  test "accepts literals like ?\\C-\\M-d":
    expectNoOffenses("x = ?\\C-\\M-d")
  test "accepts ? in a %w literal":
    expectNoOffenses("%w{? A}")
  test "auto-corrects ?x to \'x\'":
    var newSource = autocorrectSource("x = ?x")
    expect(newSource).to(eq("x = \'x\'"))
  test "auto-corrects ?\\n to \"\\n\"":
    var newSource = autocorrectSource("x = ?\\n")
    expect(newSource).to(eq("x = \"\\n\""))
  test "auto-corrects ?\' to \"\'\"":
    var newSource = autocorrectSource("x = ?\'")
    expect(newSource).to(eq("x = \"\'\""))
