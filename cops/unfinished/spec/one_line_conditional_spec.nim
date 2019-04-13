
import
  tables

import
  one_line_conditional, test_tools

suite "OneLineConditional":
  var cop = OneLineConditional()
  sharedExamples("offense", proc (condition: string): void =
    test "registers an offense":
      inspectSource(source())
      expect(cop().messages).to(eq(@["""Favor the ternary operator (`?:`)(str " over `")"""])))
  sharedExamples("no offense", proc (): void =
    test "does not register an offense":
      expectNoOffenses(source()))
  sharedExamples("autocorrect", proc (correctCode: string): void =
    test "auto-corrects":
      var corrected = autocorrectSource(source())
      expect(corrected).to(eq(correctCode)))
  context("one line if/then/else/end", proc (): void =
    let("source", proc (): void =
      "if cond then run else dont end")
    includeExamples("offense", "if")
    includeExamples("autocorrect", "cond ? run : dont")
    context("empty else", proc (): void =
      let("source", proc (): void =
        "if cond then run else end")
      includeExamples("no offense")))
  context("one line if/then/else/end when `then` branch has no body", proc (): void =
    let("source", proc (): void =
      "if cond then else dont end")
    includeExamples("offense", "if")
    includeExamples("autocorrect", "cond ? nil : dont"))
  context("one line if/then/end", proc (): void =
    let("source", proc (): void =
      "if cond then run end")
    includeExamples("no offense"))
  context("one line unless/then/else/end", proc (): void =
    let("source", proc (): void =
      "unless cond then run else dont end")
    includeExamples("offense", "unless")
    includeExamples("autocorrect", "cond ? dont : run")
    context("empty else", proc (): void =
      let("source", proc (): void =
        "unless cond then run else end")
      includeExamples("no offense")))
  context("one line unless/then/end", proc (): void =
    let("source", proc (): void =
      "unless cond then run end")
    includeExamples("no offense"))
  for operator in @["|", "^", "&", "<=>", "==", "===", "=~", ">", ">=", "<", "<=", "<<", ">>",
                 "+", "-", "*", "/", "%", "**", "~", "!", "!=", "!~", "&&", "||"]:
    test "parenthesizes the expression if it is preceded by an operator":
      var corrected = autocorrectSource("""a (lvar :operator) if cond then run else dont end""")
      expect(corrected).to(eq("""a (lvar :operator) (cond ? run : dont)"""))
  sharedExamples("changed precedence", proc (expr: string): void =
    test """adds parentheses around `(lvar :expr)`""":
      var corrected = autocorrectSource("""if (lvar :expr) then (lvar :expr) else (lvar :expr) end""")
      expect(corrected).to(eq("""((lvar :expr)) ? ((lvar :expr)) : ((lvar :expr))""")))
  itBehavesLike("changed precedence", "puts 1")
  itBehavesLike("changed precedence", "defined? :A")
  itBehavesLike("changed precedence", "yield a")
  itBehavesLike("changed precedence", "super b")
  itBehavesLike("changed precedence", "not a")
  itBehavesLike("changed precedence", "a and b")
  itBehavesLike("changed precedence", "a or b")
  itBehavesLike("changed precedence", "a = b")
  itBehavesLike("changed precedence", "a ? b : c")
  test """does not parenthesize expressions when they do not contain method calls with unparenthesized arguments""":
    var corrected = autocorrectSource("if a(0) then puts(1) else yield(2) end")
    expect(corrected).to(eq("a(0) ? puts(1) : yield(2)"))
  test """does not parenthesize expressions when they contain unparenthesized operator method calls""":
    var corrected = autocorrectSource("if 0 + 0 then 1 + 1 else 2 + 2 end")
    expect(corrected).to(eq("0 + 0 ? 1 + 1 : 2 + 2"))
  test "does not break when one of the branches contains a retry keyword":
    expectOffense("""      if true then retry else 7 end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor the ternary operator (`?:`) over `if/then/else/end` constructs.
""".stripIndent)
    expectCorrection("      true ? retry : 7\n".stripIndent)
  test "does not break when one of the branches contains a break keyword":
    expectOffense("""      if true then break else 7 end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor the ternary operator (`?:`) over `if/then/else/end` constructs.
""".stripIndent)
    expectCorrection("      true ? break : 7\n".stripIndent)
