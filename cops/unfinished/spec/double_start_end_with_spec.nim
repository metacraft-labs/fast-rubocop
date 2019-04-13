
import
  double_start_end_with, test_tools

suite "DoubleStartEndWith":
  var cop = DoubleStartEndWith()
  context("IncludeActiveSupportAliases: false", proc (): void =
    let("config", proc (): void =
      Config.new())
    context("two #start_with? calls", proc (): void =
      context("with the same receiver", proc (): void =
        context("all parameters of the second call are pure", proc (): void =
          let("source", proc (): void =
            "x.start_with?(a, b) || x.start_with?(\"c\", D)")
          test "registers an offense":
            inspectSource(source())
            expect(cop().offenses.size).to(eq(1))
            expect(cop().offenses[0].message).to(eq("""Use `x.start_with?(a, b, "c", D)` instead of `x.start_with?(a, b) || x.start_with?("c", D)`."""))
            expect(cop().highlights).to(eq(
                @["x.start_with?(a, b) || x.start_with?(\"c\", D)"]))
          test "corrects to a single start_with?":
            var newSource = autocorrectSource(source())
            expect(newSource).to(eq("x.start_with?(a, b, \"c\", D)")))
        context("one of the parameters of the second call is not pure", proc (): void =
          test "doesn\'t register an offense":
            expectNoOffenses("x.start_with?(a, \"b\") || x.start_with?(C, d)")))
      context("with different receivers", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("x.start_with?(\"a\") || y.start_with?(\"b\")")))
    context("two #end_with? calls", proc (): void =
      context("with the same receiver", proc (): void =
        context("all parameters of the second call are pure", proc (): void =
          let("source", proc (): void =
            "x.end_with?(a, b) || x.end_with?(\"c\", D)")
          test "registers an offense":
            inspectSource(source())
            expect(cop().offenses.size).to(eq(1))
            expect(cop().offenses[0].message).to(eq("""Use `x.end_with?(a, b, "c", D)` instead of `x.end_with?(a, b) || x.end_with?("c", D)`."""))
            expect(cop().highlights).to(eq(
                @["x.end_with?(a, b) || x.end_with?(\"c\", D)"]))
          test "corrects to a single end_with?":
            var newSource = autocorrectSource(source())
            expect(newSource).to(eq("x.end_with?(a, b, \"c\", D)")))
        context("one of the parameters of the second call is not pure", proc (): void =
          test "doesn\'t register an offense":
            expectNoOffenses("x.end_with?(a, \"b\") || x.end_with?(C, d)")))
      context("with different receivers", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("x.end_with?(\"a\") || y.end_with?(\"b\")")))
    context("a .start_with? and .end_with? call with the same receiver", proc (): void =
      test "doesn\'t register an offense":
        expectNoOffenses("x.start_with?(\"a\") || x.end_with?(\"b\")"))
    context("two #starts_with? calls", proc (): void =
      test "doesn\'t register an offense":
        expectNoOffenses("x.starts_with?(a, b) || x.starts_with?(\"c\", D)"))
    context("two #ends_with? calls", proc (): void =
      test "doesn\'t register an offense":
        expectNoOffenses("x.ends_with?(a, b) || x.ends_with?(\"c\", D)")))
  context("IncludeActiveSupportAliases: true", proc (): void =
    let("config", proc (): void =
      Config.new())
    context("two #start_with? calls", proc (): void =
      context("with the same receiver", proc (): void =
        context("all parameters of the second call are pure", proc (): void =
          let("source", proc (): void =
            "x.start_with?(a, b) || x.start_with?(\"c\", D)")
          test "registers an offense":
            inspectSource(source())
            expect(cop().offenses.size).to(eq(1))
            expect(cop().offenses[0].message).to(eq("""Use `x.start_with?(a, b, "c", D)` instead of `x.start_with?(a, b) || x.start_with?("c", D)`."""))
            expect(cop().highlights).to(eq(
                @["x.start_with?(a, b) || x.start_with?(\"c\", D)"]))
          test "corrects to a single start_with?":
            var newSource = autocorrectSource(source())
            expect(newSource).to(eq("x.start_with?(a, b, \"c\", D)")))))
    context("two #end_with? calls", proc (): void =
      context("with the same receiver", proc (): void =
        context("all parameters of the second call are pure", proc (): void =
          let("source", proc (): void =
            "x.end_with?(a, b) || x.end_with?(\"c\", D)")
          test "registers an offense":
            inspectSource(source())
            expect(cop().offenses.size).to(eq(1))
            expect(cop().offenses[0].message).to(eq("""Use `x.end_with?(a, b, "c", D)` instead of `x.end_with?(a, b) || x.end_with?("c", D)`."""))
            expect(cop().highlights).to(eq(
                @["x.end_with?(a, b) || x.end_with?(\"c\", D)"]))
          test "corrects to a single end_with?":
            var newSource = autocorrectSource(source())
            expect(newSource).to(eq("x.end_with?(a, b, \"c\", D)")))))
    context("two #starts_with? calls", proc (): void =
      context("with the same receiver", proc (): void =
        context("all parameters of the second call are pure", proc (): void =
          let("source", proc (): void =
            "x.starts_with?(a, b) || x.starts_with?(\"c\", D)")
          test "registers an offense":
            inspectSource(source())
            expect(cop().offenses.size).to(eq(1))
            expect(cop().offenses[0].message).to(eq("""Use `x.starts_with?(a, b, "c", D)` instead of `x.starts_with?(a, b) || x.starts_with?("c", D)`."""))
            expect(cop().highlights).to(eq(
                @["x.starts_with?(a, b) || x.starts_with?(\"c\", D)"]))
          test "corrects to a single starts_with?":
            var newSource = autocorrectSource(source())
            expect(newSource).to(eq("x.starts_with?(a, b, \"c\", D)")))
        context("one of the parameters of the second call is not pure", proc (): void =
          test "doesn\'t register an offense":
            expectNoOffenses("              x.starts_with?(a, \"b\") || x.starts_with?(C, d)\n".stripIndent)))
      context("with different receivers", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("x.starts_with?(\"a\") || y.starts_with?(\"b\")")))
    context("two #ends_with? calls", proc (): void =
      context("with the same receiver", proc (): void =
        context("all parameters of the second call are pure", proc (): void =
          let("source", proc (): void =
            "x.ends_with?(a, b) || x.ends_with?(\"c\", D)")
          test "registers an offense":
            inspectSource(source())
            expect(cop().offenses.size).to(eq(1))
            expect(cop().offenses[0].message).to(eq("""Use `x.ends_with?(a, b, "c", D)` instead of `x.ends_with?(a, b) || x.ends_with?("c", D)`."""))
            expect(cop().highlights).to(eq(
                @["x.ends_with?(a, b) || x.ends_with?(\"c\", D)"]))
          test "corrects to a single ends_with?":
            var newSource = autocorrectSource(source())
            expect(newSource).to(eq("x.ends_with?(a, b, \"c\", D)")))
        context("one of the parameters of the second call is not pure", proc (): void =
          test "doesn\'t register an offense":
            expectNoOffenses("x.ends_with?(a, \"b\") || x.ends_with?(C, d)")))
      context("with different receivers", proc (): void =
        test "doesn\'t register an offense":
          expectNoOffenses("x.ends_with?(\"a\") || y.ends_with?(\"b\")"))))
