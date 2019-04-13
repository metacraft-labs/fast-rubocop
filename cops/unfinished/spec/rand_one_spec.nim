
import
  rand_one, test_tools

suite "RandOne":
  var cop = RandOne()
  sharedExamples("offenses", proc (source: string): void =
    describe(source, proc (): void =
      test "registers an offense":
        inspectSource(source)
        expect(cop().messages).to(eq(@["""(str "`")Perhaps you meant `rand(2)` or `rand`?"""]))
        expect(cop().highlights).to(eq(@[source]))))
  sharedExamples("no offense", proc (source: string): void =
    describe(source, proc (): void =
      test "does not register an offense":
        expectNoOffenses(source)))
  itBehavesLike("offenses", "rand 1")
  itBehavesLike("offenses", "rand(-1)")
  itBehavesLike("offenses", "rand(1.0)")
  itBehavesLike("offenses", "rand(-1.0)")
  itBehavesLike("no offense", "rand")
  itBehavesLike("no offense", "rand(2)")
  itBehavesLike("no offense", "rand(-1..1)")
  itBehavesLike("offenses", "Kernel.rand(1)")
  itBehavesLike("offenses", "Kernel.rand(-1)")
  itBehavesLike("offenses", "Kernel.rand 1.0")
  itBehavesLike("offenses", "Kernel.rand(-1.0)")
  itBehavesLike("no offense", "Kernel.rand")
  itBehavesLike("no offense", "Kernel.rand 2")
  itBehavesLike("no offense", "Kernel.rand(-1..1)")
