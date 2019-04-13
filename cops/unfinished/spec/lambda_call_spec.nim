
import
  lambda_call, test_tools

RSpec.describe(LambdaCall, "config", proc (): void =
  var cop = ()
  context("when style is set to call", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "call"}.newTable())
    test "registers an offense for x.()":
      expectOffense("""        x.(a, b)
        ^^^^^^^^ Prefer the use of `lambda.call(...)` over `lambda.(...)`.
""".stripIndent)
    test "registers an offense for correct + opposite":
      expectOffense("""        x.call(a, b)
        x.(a, b)
        ^^^^^^^^ Prefer the use of `lambda.call(...)` over `lambda.(...)`.
""".stripIndent)
    test "accepts x.call()":
      expectNoOffenses("x.call(a, b)")
    test "auto-corrects x.() to x.call()":
      var newSource = autocorrectSource("a.(x)")
      expect(newSource).to(eq("a.call(x)")))
  context("when style is set to braces", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "braces"}.newTable())
    test "registers an offense for x.call()":
      expectOffense("""        x.call(a, b)
        ^^^^^^^^^^^^ Prefer the use of `lambda.(...)` over `lambda.call(...)`.
""".stripIndent)
    test "registers an offense for opposite + correct":
      expectOffense("""        x.call(a, b)
        ^^^^^^^^^^^^ Prefer the use of `lambda.(...)` over `lambda.call(...)`.
        x.(a, b)
""".stripIndent)
    test "accepts x.()":
      expectNoOffenses("x.(a, b)")
    test "accepts a call without receiver":
      expectNoOffenses("call(a, b)")
    test "auto-corrects x.call() to x.()":
      var newSource = autocorrectSource("a.call(x)")
      expect(newSource).to(eq("a.(x)"))
    test "auto-corrects x.call to x.()":
      var newSource = autocorrectSource("a.call")
      expect(newSource).to(eq("a.()"))
    test "auto-corrects x.call asdf, x123 to x.(asdf, x123)":
      var newSource = autocorrectSource("a.call asdf, x123")
      expect(newSource).to(eq("a.(asdf, x123)"))))
