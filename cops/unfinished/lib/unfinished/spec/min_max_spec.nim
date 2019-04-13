
import
  min_max, test_tools

RSpec.describe(MinMax, "config", proc (): void =
  var cop = ()
  context("with an array literal containing calls to `#min` and `#max`", proc (): void =
    context("when the expression stands alone", proc (): void =
      test "registers an offense if the receivers match":
        expectOffense("""          [foo.min, foo.max]
          ^^^^^^^^^^^^^^^^^^ Use `foo.minmax` instead of `[foo.min, foo.max]`.
""".stripIndent)
      test "does not register an offense if the receivers do not match":
        expectNoOffenses("          [foo.min, bar.max]\n".stripIndent)
      test "does not register an offense if there are additional elements":
        expectNoOffenses("          [foo.min, foo.baz, foo.max]\n".stripIndent)
      test "does not register an offense if the receiver is implicit":
        expectNoOffenses("          [min, max]\n".stripIndent)
      test "auto-corrects an offense to use `#minmax`":
        var corrected = autocorrectSource("          [foo.bar.min, foo.bar.max]\n".stripIndent)
        expect(corrected).to(eq("          foo.bar.minmax\n".stripIndent)))
    context("when the expression is used in a parallel assignment", proc (): void =
      test "registers an offense if the receivers match":
        expectOffense("""          bar = foo.min, foo.max
                ^^^^^^^^^^^^^^^^ Use `foo.minmax` instead of `foo.min, foo.max`.
""".stripIndent)
      test "does not register an offense if the receivers do not match":
        expectNoOffenses("          baz = foo.min, bar.max\n".stripIndent)
      test "does not register an offense if there are additional elements":
        expectNoOffenses("          bar = foo.min, foo.baz, foo.max\n".stripIndent)
      test "does not register an offense if the receiver is implicit":
        expectNoOffenses("          bar = min, max\n".stripIndent)
      test "auto-corrects an offense to use `#minmax`":
        var corrected = autocorrectSource("          baz = foo.bar.min, foo.bar.max\n".stripIndent)
        expect(corrected).to(eq("          baz = foo.bar.minmax\n".stripIndent)))
    context("when the expression is used as a return value", proc (): void =
      test "registers an offense if the receivers match":
        expectOffense("""          return foo.min, foo.max
                 ^^^^^^^^^^^^^^^^ Use `foo.minmax` instead of `foo.min, foo.max`.
""".stripIndent)
      test "does not register an offense if the receivers do not match":
        expectNoOffenses("          return foo.min, bar.max\n".stripIndent)
      test "does not register an offense if there are additional elements":
        expectNoOffenses("          return foo.min, foo.baz, foo.max\n".stripIndent)
      test "does not register an offense if the receiver is implicit":
        expectNoOffenses("          return min, max\n".stripIndent)
      test "auto-corrects an offense to use `#minmax`":
        var corrected = autocorrectSource("          return foo.bar.min, foo.bar.max\n".stripIndent)
        expect(corrected).to(eq("          return foo.bar.minmax\n".stripIndent)))))
