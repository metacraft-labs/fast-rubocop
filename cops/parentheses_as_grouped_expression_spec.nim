
import
  parentheses_as_grouped_expression, test_tools

suite "ParenthesesAsGroupedExpression":
  var cop = ParenthesesAsGroupedExpression()
  test """registers an offense for method call with space before the parenthesis""":
    expectOffense("""      a.func (x)
            ^ `(...)` interpreted as grouped expression.
""".stripIndent)
  test """registers an offense for predicate method call with space before the parenthesis""":
    expectOffense("""      is? (x)
         ^ `(...)` interpreted as grouped expression.
""".stripIndent)
  test "registers an offense for math expression":
    expectOffense("""      puts (2 + 3) * 4
          ^ `(...)` interpreted as grouped expression.
""".stripIndent)
  test "accepts a method call without arguments":
    expectNoOffenses("func")
  test "accepts a method call with arguments but no parentheses":
    expectNoOffenses("puts x")
  test "accepts a chain of method calls":
    expectNoOffenses("""      a.b
      a.b 1
      a.b(1)
""".stripIndent)
  test "accepts method with parens as arg to method without":
    expectNoOffenses("a b(c)")
  test "accepts an operator call with argument in parentheses":
    expectNoOffenses("""      a % (b + c)
      a.b = (c == d)
""".stripIndent)
  test "accepts a space inside opening paren followed by left paren":
    expectNoOffenses("a( (b) )")
  test "does not register an offense for a call with multiple arguments":
    expectNoOffenses("assert_equal (0..1.9), acceleration.domain")
  context("when using safe navigation operator", "ruby23", proc (): void =
    test """registers an offense for method call with space before the parenthesis""":
      expectOffense("""        a&.func (x)
               ^ `(...)` interpreted as grouped expression.
""".stripIndent))
