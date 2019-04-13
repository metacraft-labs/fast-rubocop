
import
  redundant_conditional, test_tools

suite "RedundantConditional":
  var cop = RedundantConditional()
  let("config", proc (): void =
    Config.new)
  before(proc (): void =
    inspectSource(source()))
  sharedExamples("code with offense", proc (code: string; expected: string;
      messageExpression: string): void =
    context("""when checking (send
  (lvar :code) :inspect)""", proc (): void =
      let("source", proc (): void =
        code)
      test "registers an offense":
        var expectedMessage = """This conditional expression (str "can just be replaced by `")"""
        expect(cop().offenses.size).to(eq(1))
        expect(cop().messages).to(eq(@[expectedMessage]))
      test "auto-corrects":
        expect(autocorrectSource(code)).to(eq(expected))
      test "claims to auto-correct":
        autocorrectSource(code)
        expect(cop().offenses.last().status).to(eq("corrected"))))
  sharedExamples("code without offense", proc (code: string): void =
    let("source", proc (): void =
      code)
    context("""when checking (send
  (lvar :code) :inspect)""", proc (): void =
      test "does not register an offense":
        expect(cop().offenses.isEmpty).to(be(true))))
  itBehavesLike("code with offense", "x == y ? true : false", "x == y")
  itBehavesLike("code with offense", "x == y ? false : true", "!(x == y)")
  itBehavesLike("code without offense", "x == y ? 1 : 10")
  itBehavesLike("code with offense", """                    if x == y
                      true
                    else
                      false
                    end
""".stripIndent,
                "x == y\n", "x == y")
  itBehavesLike("code with offense", """                    if x == y
                      false
                    else
                      true
                    end
""".stripIndent,
                "!(x == y)\n", "!(x == y)")
  itBehavesLike("code with offense", """                    if cond
                      false
                    elsif x == y
                      true
                    else
                      false
                    end
""".stripIndent, """                    if cond
                      false
                    else
                      x == y
                    end
""".stripIndent,
                "\nelse\n  x == y")
  itBehavesLike("code with offense", """                    if cond
                      false
                    elsif x == y
                      false
                    else
                      true
                    end
""".stripIndent, """                    if cond
                      false
                    else
                      !(x == y)
                    end
""".stripIndent,
                "\nelse\n  !(x == y)")
  itBehavesLike("code without offense", """                    if x == y
                      1
                    else
                      2
                    end
""".stripIndent)
  itBehavesLike("code without offense", """                    if cond
                      1
                    elseif x == y
                      2
                    else
                      3
                    end
""".stripIndent)
