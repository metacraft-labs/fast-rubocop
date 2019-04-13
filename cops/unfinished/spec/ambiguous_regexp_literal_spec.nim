
import
  ambiguous_regexp_literal, test_tools

suite "AmbiguousRegexpLiteral":
  var cop = AmbiguousRegexpLiteral()
  context("with a regexp literal in the first argument", proc (): void =
    context("without parentheses", proc (): void =
      test "registers an offense":
        expectOffense("""          p /pattern/
            ^ Ambiguous regexp literal. Parenthesize the method arguments if it's surely a regexp literal, or add a whitespace to the right of the `/` if it should be a division.
""".stripIndent))
    context("with parentheses", proc (): void =
      test "accepts":
        expectNoOffenses("p(/pattern/)")))
