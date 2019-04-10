
import
  multiline_if_modifier, test_tools

suite "MultilineIfModifier":
  var cop = MultilineIfModifier()
  sharedExamples("offense", proc (modifier: string): void =
    test "registers an offense":
      inspectSource(source())
      expect(cop().messages).to(eq(@["""(str "Favor a normal ") clause in a multiline statement."""])))
  sharedExamples("no offense", proc (): void =
    test "does not register an offense":
      expectNoOffenses(source()))
  sharedExamples("autocorrect", proc (correctCode: string): void =
    test "auto-corrects":
      var corrected = autocorrectSource(source())
      expect(corrected).to(eq(correctCode)))
  context("if guard clause", proc (): void =
    let("source", proc (): void =
      @["{", "  result: run", "} if cond"].join("\n"))
    includeExamples("offense", "if")
    includeExamples("autocorrect", "if cond\n  {\n    result: run\n  }\nend")
    context("one liner", proc (): void =
      let("source", proc (): void =
        "run if cond")
      includeExamples("no offense"))
    context("multiline condition", proc (): void =
      let("source", proc (): void =
        "run if cond &&\n       cond2")
      includeExamples("no offense"))
    context("indented offense", proc (): void =
      let("source", proc (): void =
        @["  {", "    result: run", "  } if cond"].join("\n"))
      includeExamples("autocorrect", """  if cond
    {
      result: run
    }
  end""")))
  context("unless guard clause", proc (): void =
    let("source", proc (): void =
      @["{", "  result: run", "} unless cond"].join("\n"))
    includeExamples("offense", "unless")
    includeExamples("autocorrect", """unless cond
  {
    result: run
  }
end""")
    context("one liner", proc (): void =
      let("source", proc (): void =
        "run unless cond")
      includeExamples("no offense"))
    context("multiline condition", proc (): void =
      let("source", proc (): void =
        "run unless cond &&\n           cond2")
      includeExamples("no offense"))
    context("indented offense", proc (): void =
      let("source", proc (): void =
        @["  {", "    result: run", "  } unless cond"].join("\n"))
      includeExamples("autocorrect", """  unless cond
    {
      result: run
    }
  end""")))
