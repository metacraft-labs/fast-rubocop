
import
  symbol_literal, test_tools

suite "SymbolLiteral":
  var cop = SymbolLiteral()
  test "registers an offense for word-line symbols using string syntax":
    expectOffense("""      x = { :"test" => 0 }
            ^^^^^^^ Do not use strings for word-like symbol literals.
""".stripIndent)
  test "accepts string syntax when symbols have whitespaces in them":
    expectNoOffenses("x = { :\"t o\" => 0 }")
  test "accepts string syntax when symbols have special chars in them":
    expectNoOffenses("x = { :\"\\tab\" => 1 }")
  test "accepts string syntax when symbol start with a digit":
    expectNoOffenses("x = { :\"1\" => 1 }")
  test "auto-corrects by removing quotes":
    var newSource = autocorrectSource("{ :\"ala\" => 1, :\"bala\" => 2 }")
    expect(newSource).to(eq("{ :ala => 1, :bala => 2 }"))
