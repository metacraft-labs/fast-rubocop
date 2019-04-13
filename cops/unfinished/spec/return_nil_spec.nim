
import
  return_nil, test_tools

suite "ReturnNil":
  var cop = ReturnNil()
  context("when enforced style is `return`", proc (): void =
    let("config", proc (): void =
      Config.new())
    test "registers an offense for return nil":
      expectOffense("""        return nil
        ^^^^^^^^^^ Use `return` instead of `return nil`.
""".stripIndent)
    test "auto-corrects `return nil` into `return`":
      expect(autocorrectSource("return nil")).to(eq("return"))
    test "does not register an offense for return":
      expectNoOffenses("return")
    test "does not register an offense for returning others":
      expectNoOffenses("return 2")
    test "does not register an offense for return nil from iterators":
      expectNoOffenses("""        loop do
          return if x
        end
"""))
  context("when enforced style is `return_nil`", proc (): void =
    let("config", proc (): void =
      Config.new())
    test "registers an offense for return":
      expectOffense("""        return
        ^^^^^^ Use `return nil` instead of `return`.
""".stripIndent)
    test "auto-corrects `return` into `return nil`":
      expect(autocorrectSource("return")).to(eq("return nil"))
    test "does not register an offense for return nil":
      expectNoOffenses("return nil")
    test "does not register an offense for returning others":
      expectNoOffenses("return 2"))
