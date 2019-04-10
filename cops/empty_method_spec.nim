
import
  empty_method, test_tools

RSpec.describe(EmptyMethod, "config", proc (): void =
  var cop = ()
  before(proc (): void =
    inspectSource(source()))
  sharedExamples("code with offense", proc (code: string; expected: string): void =
    context("""when checking (lvar :code)""", proc (): void =
      let("source", proc (): void =
        code)
      test "registers an offense":
        expect(cop().offenses.size).to(eq(1))
        expect(cop().messages).to(eq(@[message()]))
      if expected:
        test "auto-corrects":
          expect(autocorrectSource(code)).to(eq(expected))
      else:
        test "does not auto-correct":
          expect(autocorrectSource(code)).to(eq(code))
    ))
  sharedExamples("code without offense", proc (code: string): void =
    let("source", proc (): void =
      code)
    test "does not register an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  context("when configured with compact style", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "compact"}.newTable())
    let("message", proc (): void =
      "Put empty method definitions on a single line.")
    context("with an empty instance method definition", proc (): void =
      itBehavesLike("code with offense", @["def foo", "end"].join("\n"),
                    "def foo; end")
      itBehavesLike("code with offense",
                    @["def foo(bar, baz)", "end"].join("\n"),
                    "def foo(bar, baz); end")
      itBehavesLike("code with offense",
                    @["def foo bar, baz", "end"].join("\n"),
                    "def foo bar, baz; end")
      itBehavesLike("code with offense", @["def foo", "", "end"].join("\n"),
                    "def foo; end")
      itBehavesLike("code without offense", "def foo; end"))
    context("with a non-empty instance method definition", proc (): void =
      itBehavesLike("code without offense", """                        def foo
                          bar
                        end
""".stripIndent)
      itBehavesLike("code without offense", "def foo; bar; end")
      itBehavesLike("code without offense", """                        def foo
                          # bar
                        end
""".stripIndent))
    context("with an empty class method definition", proc (): void =
      itBehavesLike("code with offense", @["def self.foo", "end"].join("\n"),
                    "def self.foo; end")
      itBehavesLike("code with offense",
                    @["def self.foo(bar, baz)", "end"].join("\n"),
                    "def self.foo(bar, baz); end")
      itBehavesLike("code with offense",
                    @["def self.foo", "", "end"].join("\n"), "def self.foo; end")
      itBehavesLike("code without offense", "def self.foo; end"))
    context("with a non-empty class method definition", proc (): void =
      itBehavesLike("code without offense", """                        def self.foo
                          bar
                        end
""".stripIndent)
      itBehavesLike("code without offense", "def self.foo; bar; end")
      itBehavesLike("code without offense", """                        def self.foo
                          # bar
                        end
""".stripIndent)))
  context("when configured with expanded style", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "expanded"}.newTable())
    let("message", proc (): void =
      "Put the `end` of empty method definitions on the next line.")
    context("with an empty instance method definition", proc (): void =
      itBehavesLike("code without offense", @["def foo", "end"].join("\n"))
      itBehavesLike("code without offense", @["def foo", "", "end"].join("\n"))
      itBehavesLike("code with offense", "def foo; end",
                    @["def foo", "end"].join("\n")))
    context("with a non-empty instance method definition", proc (): void =
      itBehavesLike("code without offense", """                        def foo
                          bar
                        end
""".stripIndent)
      itBehavesLike("code without offense", "def foo; bar; end")
      itBehavesLike("code without offense", """                        def foo
                          # bar
                        end
""".stripIndent))
    context("with an empty class method definition", proc (): void =
      itBehavesLike("code without offense", @["def self.foo", "end"].join("\n"))
      itBehavesLike("code without offense",
                    @["def self.foo", "", "end"].join("\n"))
      itBehavesLike("code with offense", "def self.foo; end",
                    @["def self.foo", "end"].join("\n")))
    context("with a non-empty class method definition", proc (): void =
      itBehavesLike("code without offense", """                        def self.foo
                          bar
                        end
""".stripIndent)
      itBehavesLike("code without offense", "def self.foo; bar; end")
      itBehavesLike("code without offense", """                        def self.foo
                          # bar
                        end
""".stripIndent))
    context("when method is nested in class scope", proc (): void =
      itBehavesLike("code with offense",
                    @["class Foo", "  def bar; end", "end"].join("\n"),
                    @["class Foo", "  def bar", "  end", "end"].join("\n")))))
