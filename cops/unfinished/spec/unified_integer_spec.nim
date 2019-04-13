
import
  unified_integer, test_tools

suite "UnifiedInteger":
  var cop = UnifiedInteger()
  let("config", proc (): void =
    Config.new)
  sharedExamples("registers an offense", proc (klass: string): void =
    context("""when (lvar :klass)""", proc (): void =
      context("without any decorations", proc (): void =
        let("source", proc (): void =
          """1.is_a?((lvar :klass))""")
        test "registers an offense":
          inspectSource(source())
          expect(cop().offenses.size).to(eq(1))
          expect(cop().messages).to(eq(@[
              """Use `Integer` instead of `(lvar :klass)`."""]))
        test "autocorrects":
          var newSource = autocorrectSource(source())
          expect(newSource).to(eq("1.is_a?(Integer)")))
      context("when explicitly specified as toplevel constant", proc (): void =
        let("source", proc (): void =
          """1.is_a?(::(lvar :klass))""")
        test "registers an offense":
          inspectSource(source())
          expect(cop().offenses.size).to(eq(1))
          expect(cop().messages).to(eq(@[
              """Use `Integer` instead of `(lvar :klass)`."""]))
        test "autocorrects":
          var newSource = autocorrectSource(source())
          expect(newSource).to(eq("1.is_a?(::Integer)")))
      context("with MyNamespace", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""1.is_a?(MyNamespace::(lvar :klass))"""))))
  includeExamples("registers an offense", "Fixnum")
  includeExamples("registers an offense", "Bignum")
  context("when Integer", proc (): void =
    context("without any decorations", proc (): void =
      test "does not register an offense":
        expectNoOffenses("1.is_a?(Integer)"))
    context("when explicitly specified as toplevel constant", proc (): void =
      test "does not register an offense":
        expectNoOffenses("1.is_a?(::Integer)"))
    context("with MyNamespace", proc (): void =
      test "does not register an offense":
        expectNoOffenses("1.is_a?(MyNamespace::Integer)")))
