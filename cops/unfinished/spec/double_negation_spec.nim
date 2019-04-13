
import
  double_negation, test_tools

suite "DoubleNegation":
  var cop = DoubleNegation()
  test "registers an offense for !!":
    expectOffense("""      !!test.something
      ^ Avoid the use of double negation (`!!`).
""".stripIndent)
  test "does not register an offense for !":
    expectNoOffenses("!test.something")
  test "does not register an offense for not not":
    expectNoOffenses("not not test.something")
