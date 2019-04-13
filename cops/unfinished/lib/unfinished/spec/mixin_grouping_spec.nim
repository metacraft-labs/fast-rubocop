
import
  mixin_grouping, test_tools

RSpec.describe(MixinGrouping, "config", proc (): void =
  var cop = ()
  before(proc (): void =
    inspectSource(source()))
  sharedExamples("code with offense", proc (code: string; expected: string): void =
    context("""when checking (lvar :code)""", proc (): void =
      let("source", proc (): void =
        code)
      test "registers an offense":
        expect(cop().offenses().size).to(eq(offenses()))
        expect(cop().messages).to(eq(@[message()] * offenses()))
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
  context("when configured with separated style", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "separated"}.newTable())
    let("offenses", proc (): void =
      1)
    context("when using `include`", proc (): void =
      let("message", proc (): void =
        "Put `include` mixins in separate statements.")
      context("with several mixins in one call", proc (): void =
        itBehavesLike("code with offense",
                      @["class Foo", "  include Bar, Qux", "end"].join("\n"), @[
            "class Foo", "  include Qux", "  include Bar", "end"].join("\n")))
      context("with single mixins in separate calls", proc (): void =
        itBehavesLike("code without offense", """          class Foo
            include Bar
            include Qux
          end
""".stripIndent))
      context("when include call is an argument to another method", proc (): void =
        itBehavesLike("code without offense",
                      "expect(foo).to include { { bar: baz } }"))
      context("with several mixins in separate calls", proc (): void =
        itBehavesLike("code with offense", @["class Foo", "  include Bar, Baz",
            "  include Qux", "end"].join("\n"), @["class Foo", "  include Baz",
            "  include Bar", "  include Qux", "end"].join("\n"))))
    context("when using `extend`", proc (): void =
      let("message", proc (): void =
        "Put `extend` mixins in separate statements.")
      context("with several mixins in one call", proc (): void =
        itBehavesLike("code with offense",
                      @["class Foo", "  extend Bar, Qux", "end"].join("\n"), @[
            "class Foo", "  extend Qux", "  extend Bar", "end"].join("\n")))
      context("with single mixins in separate calls", proc (): void =
        itBehavesLike("code without offense", """          class Foo
            extend Bar
            extend Qux
          end
""".stripIndent)))
    context("when using `prepend`", proc (): void =
      let("message", proc (): void =
        "Put `prepend` mixins in separate statements.")
      context("with several mixins in one call", proc (): void =
        itBehavesLike("code with offense",
                      @["class Foo", "  prepend Bar, Qux", "end"].join("\n"), @[
            "class Foo", "  prepend Qux", "  prepend Bar", "end"].join("\n")))
      context("with single mixins in separate calls", proc (): void =
        itBehavesLike("code without offense", """          class Foo
            prepend Bar
            prepend Qux
          end
""".stripIndent)))
    context("when using a mix of diffent methods", proc (): void =
      context("with some calls having several mixins", proc (): void =
        let("message", proc (): void =
          "Put `include` mixins in separate statements.")
        itBehavesLike("code with offense", @["class Foo", "  include Bar, Baz",
            "  extend Qux", "end"].join("\n"), @["class Foo", "  include Baz",
            "  include Bar", "  extend Qux", "end"].join("\n")))
      context("with all calls having one mixin", proc (): void =
        itBehavesLike("code without offense", """          class Foo
            include Bar
            prepend Baz
            extend Baz
          end
""".stripIndent))))
  context("when configured with grouped style", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "grouped"}.newTable())
    context("when using include", proc (): void =
      context("with single mixins in separate calls", proc (): void =
        let("offenses", proc (): void =
          3)
        let("message", proc (): void =
          "Put `include` mixins in a single statement.")
        itBehavesLike("code with offense", @["class Foo", "  include Bar",
            "  include Baz", "  include Qux", "end"].join("\n"), @["class Foo",
            "  include Qux, Baz, Bar", "end"].join("\n")))
      context("with several mixins in one call", proc (): void =
        itBehavesLike("code without offense", """          class Foo
            include Bar, Qux
          end
""".stripIndent))
      context("when include has an explicit receiver", proc (): void =
        itBehavesLike("code without offense", """          config.include Foo
          config.include Bar
""".stripIndent))
      context("with several mixins in separate calls", proc (): void =
        let("offenses", proc (): void =
          3)
        let("message", proc (): void =
          "Put `include` mixins in a single statement.")
        itBehavesLike("code with offense", @["class Foo", "  include Bar, Baz",
            "  include FooBar, FooBaz", "  include Qux, FooBarBaz", "end"].join(
            "\n"), @["class Foo",
                    "  include Qux, FooBarBaz, FooBar, FooBaz, Bar, Baz", "end"].join(
            "\n"))))
    context("when using `extend`", proc (): void =
      context("with single mixins in separate calls", proc (): void =
        let("offenses", proc (): void =
          2)
        let("message", proc (): void =
          "Put `extend` mixins in a single statement.")
        itBehavesLike("code with offense", @["class Foo", "  extend Bar",
            "  extend Baz", "end"].join("\n"),
                      @["class Foo", "  extend Baz, Bar", "end"].join("\n")))
      context("with several mixins in one call", proc (): void =
        itBehavesLike("code without offense", """          class Foo
            extend Bar, Qux
          end
""".stripIndent)))
    context("when using `prepend`", proc (): void =
      context("with single mixins in separate calls", proc (): void =
        let("offenses", proc (): void =
          2)
        let("message", proc (): void =
          "Put `prepend` mixins in a single statement.")
        itBehavesLike("code with offense", @["class Foo", "  prepend Bar",
            "  prepend Baz", "end"].join("\n"),
                      @["class Foo", "  prepend Baz, Bar", "end"].join("\n")))
      context("with single mixins in separate calls, intersperced", proc (): void =
        let("offenses", proc (): void =
          3)
        let("message", proc (): void =
          "Put `prepend` mixins in a single statement.")
        itBehavesLike("code with offense", @["class Foo", "  prepend Bar",
            "  prepend Baz", "  do_something_else", "  prepend Qux", "end"].join(
            "\n"), @["class Foo", "  prepend Qux, Baz, Bar", "  do_something_else",
                    "  ", "end"].join("\n")))
      context("with mixins with receivers", proc (): void =
        let("offenses", proc (): void =
          2)
        let("message", proc (): void =
          "Put `prepend` mixins in a single statement.")
        itBehavesLike("code with offense", @["class Foo", "  prepend Bar",
            "  Other.prepend Baz", "  do_something_else", "  prepend Qux", "end"].join(
            "\n"), @["class Foo", "  prepend Qux, Bar", "  Other.prepend Baz",
                    "  do_something_else", "  ", "end"].join("\n")))
      context("with several mixins in one call", proc (): void =
        itBehavesLike("code without offense", """          class Foo
            prepend Bar, Qux
          end
""".stripIndent)))
    context("when using a mix of diffent methods", proc (): void =
      context("with some duplicated mixin methods", proc (): void =
        let("offenses", proc (): void =
          2)
        let("message", proc (): void =
          "Put `include` mixins in a single statement.")
        itBehavesLike("code with offense", @["class Foo", "  include Bar",
            "  include Baz", "  extend Baz", "end"].join("\n"), @["class Foo",
            "  include Baz, Bar", "  extend Baz", "end"].join("\n")))
      context("with all different mixin methods", proc (): void =
        itBehavesLike("code without offense", """          class Foo
            include Bar
            prepend Baz
            extend Baz
          end
""".stripIndent)))))
