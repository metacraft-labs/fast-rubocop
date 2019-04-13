
import
  redundant_freeze, test_tools

suite "RedundantFreeze":
  var cop = RedundantFreeze()
  let("prefix", proc (): void =
  )
  sharedExamples("immutable objects", proc (o: string): void =
    test """registers an offense for frozen (lvar :o)""":
      var source = (prefix(), """CONST = (lvar :o).freeze""").compact().join("\n")
      inspectSource(source)
      expect(cop().offenses.size).to(eq(1))
    test "auto-corrects by removing .freeze":
      var
        source = (prefix(), """CONST = (lvar :o).freeze""").compact().join("\n")
        newSource = autocorrectSource(source)
      expect(newSource).to(eq(source.chomp(".freeze"))))
  itBehavesLike("immutable objects", "1")
  itBehavesLike("immutable objects", "1.5")
  itBehavesLike("immutable objects", ":sym")
  itBehavesLike("immutable objects", ":\"\"")
  sharedExamples("mutable objects", proc (o: string): void =
    test """allows (lvar :o) with freeze""":
      var source = (prefix(), """CONST = (lvar :o).freeze""").compact().join("\n")
      expectNoOffenses(source))
  itBehavesLike("mutable objects", "[1, 2, 3]")
  itBehavesLike("mutable objects", "{ a: 1, b: 2 }")
  itBehavesLike("mutable objects", "\'str\'")
  itBehavesLike("mutable objects", "\"top#{1 + 2}\"")
  itBehavesLike("mutable objects", "/./")
  itBehavesLike("mutable objects", "(1..5)")
  itBehavesLike("mutable objects", "(1...5)")
  test "allows .freeze on  method call":
    expectNoOffenses("TOP_TEST = Something.new.freeze")
  context("when the receiver is a frozen string literal", proc (): void =
    if KNOWNRUBIES.isInclude(0.0):
      context("when the target ruby version >= 3.0", proc (): void =
        let("ruby_version", proc (): void =
          0.0)
        context("when the frozen string literal comment is missing", proc (): void =
          itBehavesLike("immutable objects", "\"#{a}\""))
        context("when the frozen string literal comment is true", proc (): void =
          let("prefix", proc (): void =
            "# frozen_string_literal: true")
          itBehavesLike("immutable objects", "\"#{a}\""))
        context("when the frozen string literal comment is false", proc (): void =
          let("prefix", proc (): void =
            "# frozen_string_literal: false")
          itBehavesLike("immutable objects", "\"#{a}\"")))
    context("when the target ruby version >= 2.3", proc (): void =
      let("ruby_version", proc (): void =
        0.0)
      context("when the frozen string literal comment is missing", proc (): void =
        itBehavesLike("mutable objects", "\"#{a}\""))
      context("when the frozen string literal comment is true", proc (): void =
        let("prefix", proc (): void =
          "# frozen_string_literal: true")
        itBehavesLike("immutable objects", "\"#{a}\""))
      context("when the frozen string literal comment is false", proc (): void =
        let("prefix", proc (): void =
          "# frozen_string_literal: false")
        itBehavesLike("mutable objects", "\"#{a}\""))))
