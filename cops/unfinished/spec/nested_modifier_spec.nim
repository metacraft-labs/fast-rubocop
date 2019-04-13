
import
  sequtils

import
  nested_modifier, test_tools

suite "NestedModifier":
  var cop = NestedModifier()
  sharedExamples("avoidable", proc (keyword: string): void =
    test """registers an offense for modifier (lvar :keyword)""":
      inspectSource("""something (lvar :keyword) a if b""")
      expect(cop().messages).to(eq(@["Avoid using nested modifiers."]))
      expect(cop().highlights).to(eq(@[keyword])))
  sharedExamples("not correctable", proc (keyword: string): void =
    test """does not auto-correct when (lvar :keyword) is the outer modifier""":
      var
        source = """something if a (lvar :keyword) b"""
        corrected = autocorrectSource(source)
      expect(corrected).to(eq(source))
      expect(cop().offenses.mapIt:
        it.isOrrected).to(eq(@[false]))
    test """does not auto-correct when (lvar :keyword) is the inner modifier""":
      var
        source = """something (lvar :keyword) a if b"""
        corrected = autocorrectSource(source)
      expect(corrected).to(eq(source))
      expect(cop().offenses.mapIt:
        it.isOrrected).to(eq(@[false])))
  context("if", proc (): void =
    itBehavesLike("avoidable", "if"))
  context("unless", proc (): void =
    itBehavesLike("avoidable", "unless"))
  test "auto-corrects if + if":
    var corrected = autocorrectSource("something if a if b")
    expect(corrected).to(eq("something if b && a"))
  test "auto-corrects unless + unless":
    var corrected = autocorrectSource("something unless a unless b")
    expect(corrected).to(eq("something unless b || a"))
  test "auto-corrects if + unless":
    var corrected = autocorrectSource("something if a unless b")
    expect(corrected).to(eq("something unless b || !a"))
  test "auto-corrects unless with a comparison operator + if":
    var corrected = autocorrectSource("something unless b > 1 if true")
    expect(corrected).to(eq("something if true && !(b > 1)"))
  test "auto-corrects unless + if":
    var corrected = autocorrectSource("something unless a if b")
    expect(corrected).to(eq("something if b && !a"))
  test "adds parentheses when needed in auto-correction":
    var corrected = autocorrectSource("something if a || b if c || d")
    expect(corrected).to(eq("something if (c || d) && (a || b)"))
  test "does not add redundant parentheses in auto-correction":
    var corrected = autocorrectSource("something if a unless c || d")
    expect(corrected).to(eq("something unless c || d || !a"))
  context("while", proc (): void =
    itBehavesLike("avoidable", "while")
    itBehavesLike("not correctable", "while"))
  context("until", proc (): void =
    itBehavesLike("avoidable", "until")
    itBehavesLike("not correctable", "until"))
  test "registers one offense for more than two modifiers":
    expectOffense("""      something until a while b unless c if d
                                ^^^^^^ Avoid using nested modifiers.
""".stripIndent)
