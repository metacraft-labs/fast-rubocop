
import
  stabby_lambda_parentheses, test_tools

RSpec.describe(StabbyLambdaParentheses, "config", proc (): void =
  var cop = ()
  sharedExamples("common", proc (): void =
    test "does not check the old lambda syntax":
      expectNoOffenses("lambda(&:nil?)")
    test "does not check a stabby lambda without arguments":
      expectNoOffenses("-> { true }")
    test "does not check a method call named lambda":
      expectNoOffenses("o.lambda"))
  context("require_parentheses", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "require_parentheses"}.newTable())
    itBehavesLike("common")
    test "registers an offense for a stabby lambda without parentheses":
      expectOffense("""        ->a,b,c { a + b + c }
          ^^^^^ Wrap stabby lambda arguments with parentheses.
""".stripIndent)
    test "does not register an offense for a stabby lambda with parentheses":
      expectNoOffenses("->(a,b,c) { a + b + c }")
    test "autocorrects when a stabby lambda has no parentheses":
      var corrected = autocorrectSource("->a,b,c { a + b + c }")
      expect(corrected).to(eq("->(a,b,c) { a + b + c }")))
  context("require_no_parentheses", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "require_no_parentheses"}.newTable())
    itBehavesLike("common")
    test "registers an offense for a stabby lambda with parentheses":
      expectOffense("""        ->(a,b,c) { a + b + c }
          ^^^^^^^ Do not wrap stabby lambda arguments with parentheses.
""".stripIndent)
    test "autocorrects when a stabby lambda does not parentheses":
      var corrected = autocorrectSource("->(a,b,c) { a + b + c }")
      expect(corrected).to(eq("->a,b,c { a + b + c }"))))
