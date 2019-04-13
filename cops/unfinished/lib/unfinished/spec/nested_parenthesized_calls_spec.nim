
import
  nested_parenthesized_calls, test_tools

suite "NestedParenthesizedCalls":
  var cop = NestedParenthesizedCalls()
  let("config", proc (): void =
    Config.new())
  context("on a non-parenthesized method call", proc (): void =
    test "doesn\'t register an offense":
      expectNoOffenses("puts 1, 2"))
  context("on a method call with no arguments", proc (): void =
    test "doesn\'t register an offense":
      expectNoOffenses("puts"))
  context("on a nested, parenthesized method call", proc (): void =
    test "doesn\'t register an offense":
      expectNoOffenses("puts(compute(something))"))
  context("on a non-parenthesized call nested in a parenthesized one", proc (): void =
    context("with a single argument to the nested call", proc (): void =
      test "registers an offense":
        expectOffense("""          puts(compute something)
               ^^^^^^^^^^^^^^^^^ Add parentheses to nested method call `compute something`.
""".stripIndent)
        expectCorrection("          puts(compute(something))\n".stripIndent)
      context("when using safe navigation operator", "ruby23", proc (): void =
        let("source", proc (): void =
          "puts(receiver&.compute something)")
        test "registers an offense":
          expectOffense("""            puts(receiver&.compute something)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add parentheses to nested method call `receiver&.compute something`.
""".stripIndent)
        test "auto-corrects by adding parentheses":
          var newSource = autocorrectSource(source())
          expect(newSource).to(eq("puts(receiver&.compute(something))"))))
    context("with multiple arguments to the nested call", proc (): void =
      test "registers an offense":
        expectOffense("""          puts(compute first, second)
               ^^^^^^^^^^^^^^^^^^^^^ Add parentheses to nested method call `compute first, second`.
""".stripIndent)
        expectCorrection("          puts(compute(first, second))\n".stripIndent)))
  context("on a call with no arguments, nested in a parenthesized one", proc (): void =
    test "doesn\'t register an offense":
      expectNoOffenses("puts(compute)"))
  context("on an aref, nested in a parenthesized method call", proc (): void =
    test "doesn\'t register an offense":
      expectNoOffenses("method(obj[1])"))
  context("on a deeply nested argument", proc (): void =
    test "doesn\'t register an offense":
      expectNoOffenses("method(block_taker { another_method 1 })"))
  context("on a whitelisted method", proc (): void =
    test "doesn\'t register an offense":
      expectNoOffenses("expect(obj).to(be true)"))
  context("on a call to a setter method", proc (): void =
    test "doesn\'t register an offense":
      expectNoOffenses("expect(object1.attr = 1).to eq 1"))
