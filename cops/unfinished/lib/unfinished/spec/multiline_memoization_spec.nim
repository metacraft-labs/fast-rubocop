
import
  multiline_memoization, test_tools

RSpec.describe(MultilineMemoization, "config", proc (): void =
  var cop = ()
  let("message", proc (): void =
    "Wrap multiline memoization blocks in `begin` and `end`.")
  before(proc (): void =
    inspectSource(source()))
  sharedExamples("code with offense", proc (code: string; expected: string): void =
    let("source", proc (): void =
      code)
    test "registers an offense":
      expect(cop().offenses.size).to(eq(1))
      expect(cop().messages).to(eq(@[message()]))
    test "auto-corrects":
      expect(autocorrectSource(code)).to(eq(expected)))
  sharedExamples("code without offense", proc (code: string): void =
    let("source", proc (): void =
      code)
    test "does not register an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  sharedExamples("with all enforced styles", proc (): void =
    context("with a single line memoization", proc (): void =
      itBehavesLike("code without offense", "foo ||= bar")
      itBehavesLike("code without offense", """        foo ||=
          bar
""".stripIndent))
    context("with a multiline memoization", proc (): void =
      context("without a `begin` and `end` block", proc (): void =
        context("when there is another block on the first line", proc (): void =
          itBehavesLike("code without offense", """            foo ||= bar.each do |b|
              b.baz
              bb.ax
            end
""".stripIndent))
        context("when there is another block on the following line", proc (): void =
          itBehavesLike("code without offense", """            foo ||=
              bar.each do |b|
                b.baz
                b.bax
              end
""".stripIndent))
        context("when there is a conditional on the first line", proc (): void =
          itBehavesLike("code without offense", """            foo ||= if bar
                      baz
                    else
                      bax
                    end
""".stripIndent))
        context("when there is a conditional on the following line", proc (): void =
          itBehavesLike("code without offense", """            foo ||=
              if bar
                baz
              else
                bax
              end
""".stripIndent)))))
  context("EnforcedStyle: keyword", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "keyword"}.newTable())
    includeExamples("with all enforced styles")
    context("with a multiline memoization", proc (): void =
      context("without a `begin` and `end` block", proc (): void =
        context("when the expression is wrapped in parentheses", proc (): void =
          itBehavesLike("code with offense", """                            foo ||= (
                              bar
                              baz
                            )
""".stripIndent, """                            foo ||= begin
                              bar
                              baz
                            end
""".stripIndent)
          itBehavesLike("code with offense", """                            foo ||=
                              (
                                bar
                                baz
                              )
""".stripIndent, """                            foo ||=
                              begin
                                bar
                                baz
                              end
""".stripIndent)
          itBehavesLike("code with offense", """                            foo ||= (bar ||
                                     baz)
""".stripIndent, """                             foo ||= begin
                                       bar ||
                                      baz
                                     end
""".stripIndent)))
      context("with a `begin` and `end` block on the first line", proc (): void =
        itBehavesLike("code without offense", """          foo ||= begin
            bar
            baz
          end
""".stripIndent))
      context("with a `begin` and `end` block on the following line", proc (): void =
        itBehavesLike("code without offense", """          foo ||=
            begin
            bar
            baz
          end
""".stripIndent))))
  context("EnforcedStyle: braces", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "braces"}.newTable())
    includeExamples("with all enforced styles")
    context("with a multiline memoization", proc (): void =
      context("without braces", proc (): void =
        context("""when the expression is wrapped in `begin` and `end` keywords""", proc (): void =
          itBehavesLike("code with offense", """                            foo ||= begin
                              bar
                              baz
                            end
""".stripIndent, """                            foo ||= (
                              bar
                              baz
                            )
""".stripIndent)
          itBehavesLike("code with offense", """                            foo ||=
                              begin
                                bar
                                baz
                              end
""".stripIndent, """                            foo ||=
                              (
                                bar
                                baz
                              )
""".stripIndent)))
      context("with parentheses on the first line", proc (): void =
        itBehavesLike("code without offense", """          foo ||= (
            bar
            baz
          )
""".stripIndent))
      context("with parentheses block on the following line", proc (): void =
        itBehavesLike("code without offense", """          foo ||=
            (
            bar
            baz
          )
""".stripIndent)))))
