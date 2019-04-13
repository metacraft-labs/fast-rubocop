
import
  next_without_accumulator, test_tools

suite "NextWithoutAccumulator":
  var cop = NextWithoutAccumulator()
  sharedExamples("reduce/inject", proc (reduceAlias: Symbol): void =
    context("""given a (lvar :reduce_alias) block""", proc (): void =
      test "registers an offense for a bare next":
        inspectSource(codeWithoutAccumulator(reduceAlias))
        expect(cop().offenses.size).to(eq(1))
        expect(cop().highlights).to(eq(@["next"]))
      test "accepts next with a value":
        expectNoOffenses(codeWithAccumulator(reduceAlias))
      test "accepts next within a nested block":
        expectNoOffenses(codeWithNestedBlock(reduceAlias))))
  itBehavesLike("reduce/inject", "reduce")
  itBehavesLike("reduce/inject", "inject")
  context("given an unrelated block", proc (): void =
    test "accepts a bare next":
      expectNoOffenses("""              (1..4).foo(0) do |acc, i|
                next if i.odd?
                acc + i
              end
""".stripIndent)
    test "accepts next with a value":
      expectNoOffenses("""              (1..4).foo(0) do |acc, i|
                next acc if i.odd?
                acc + i
              end
""".stripIndent))
