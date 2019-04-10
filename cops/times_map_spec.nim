
import
  times_map, test_tools

suite "TimesMap":
  var cop = TimesMap()
  before(proc (): void =
    inspectSource(source()))
  sharedExamples("map_or_collect", proc (method: string): void =
    context(""".times.(lvar :method)""", proc (): void =
      context("with a block", proc (): void =
        let("source", proc (): void =
          """4.times.(lvar :method) { |i| i.to_s }""")
        test "registers an offense":
          expect(cop().offenses.size).to(eq(1))
          expect(cop().offenses[0].message).to(eq("""Use `Array.new(4)` with a block instead of `.times.(lvar :method)`."""))
          expect(cop().highlights).to(eq(
              @["""4.times.(lvar :method) { |i| i.to_s }"""]))
        test "auto-corrects":
          var corrected = autocorrectSource(source())
          expect(corrected).to(eq("Array.new(4) { |i| i.to_s }")))
      context("for non-literal receiver", proc (): void =
        let("source", proc (): void =
          """n.times.(lvar :method) { |i| i.to_s }""")
        test "registers an offense":
          expect(cop().offenses.size).to(eq(1))
          expect(cop().offenses[0].message).to(eq("""(str "Use `Array.new(n)` with a block instead of `.times.")only if `n` is always 0 or more."""))
          expect(cop().highlights).to(eq(
              @["""n.times.(lvar :method) { |i| i.to_s }"""])))
      context("with an explicitly passed block", proc (): void =
        let("source", proc (): void =
          """4.times.(lvar :method)(&method(:foo))""")
        test "registers an offense":
          expect(cop().offenses.size).to(eq(1))
          expect(cop().offenses[0].message).to(eq("""Use `Array.new(4)` with a block instead of `.times.(lvar :method)`."""))
          expect(cop().highlights).to(eq(
              @["""4.times.(lvar :method)(&method(:foo))"""]))
        test "auto-corrects":
          var corrected = autocorrectSource(source())
          expect(corrected).to(eq("Array.new(4, &method(:foo))")))
      context("without a block", proc (): void =
        let("source", proc (): void =
          """4.times.(lvar :method)""")
        test "doesn\'t register an offense":
          expect(cop().offenses.isEmpty).to(be(true)))
      context("called on nothing", proc (): void =
        let("source", proc (): void =
          """times.(lvar :method) { |i| i.to_s }""")
        test "doesn\'t register an offense":
          expect(cop().offenses.isEmpty).to(be(true)))))
  itBehavesLike("map_or_collect", "map")
  itBehavesLike("map_or_collect", "collect")
