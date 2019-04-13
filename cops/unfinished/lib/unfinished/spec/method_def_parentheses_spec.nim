
import
  method_def_parentheses, test_tools

RSpec.describe(MethodDefParentheses, "config", proc (): void =
  var cop = ()
  context("require_parentheses", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "require_parentheses"}.newTable())
    test "reports an offense for def with parameters but no parens":
      expectOffense("""        def func a, b
                 ^^^^ Use def with parentheses when there are parameters.
        end
""".stripIndent)
    test "reports an offense for correct + opposite":
      expectOffense("""        def func(a, b)
        end
        def func a, b
                 ^^^^ Use def with parentheses when there are parameters.
        end
""".stripIndent)
    test "reports an offense for class def with parameters but no parens":
      expectOffense("""        def Test.func a, b
                      ^^^^ Use def with parentheses when there are parameters.
        end
""".stripIndent)
    test "accepts def with no args and no parens":
      expectNoOffenses("""        def func
        end
""".stripIndent)
    test "auto-adds required parens for a def":
      var newSource = autocorrectSource("def test param; end")
      expect(newSource).to(eq("def test(param); end"))
    test "auto-adds required parens for a defs":
      var newSource = autocorrectSource("def self.test param; end")
      expect(newSource).to(eq("def self.test(param); end"))
    test "auto-adds required parens to argument lists on multiple lines":
      var newSource = autocorrectSource("""        def test one,
        two
        end
""".stripIndent)
      expect(newSource).to(eq("""        def test(one,
        two)
        end
""".stripIndent)))
  sharedExamples("no parentheses", proc (): void =
    test "reports an offense for def with parameters with parens":
      expectOffense("""        def func(a, b)
                ^^^^^^ Use def without parentheses.
        end
""".stripIndent)
    test "accepts a def with parameters but no parens":
      expectNoOffenses("""        def func a, b
        end
""".stripIndent)
    test "reports an offense for opposite + correct":
      expectOffense("""        def func(a, b)
                ^^^^^^ Use def without parentheses.
        end
        def func a, b
        end
""".stripIndent)
    test "reports an offense for class def with parameters with parens":
      expectOffense("""        def Test.func(a, b)
                     ^^^^^^ Use def without parentheses.
        end
""".stripIndent)
    test "accepts a class def with parameters with parens":
      expectNoOffenses("""        def Test.func a, b
        end
""".stripIndent)
    test "reports an offense for def with no args and parens":
      expectOffense("""        def func()
                ^^ Use def without parentheses.
        end
""".stripIndent)
    test "accepts def with no args and no parens":
      expectNoOffenses("""        def func
        end
""".stripIndent)
    test "auto-removes the parens":
      var newSource = autocorrectSource("def test(param); end")
      expect(newSource).to(eq("def test param; end"))
    test "auto-removes the parens for defs":
      var newSource = autocorrectSource("def self.test(param); end")
      expect(newSource).to(eq("def self.test param; end")))
  context("require_no_parentheses", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "require_no_parentheses"}.newTable())
    itBehavesLike("no parentheses"))
  context("require_no_parentheses_except_multiline", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "require_no_parentheses_except_multiline"}.newTable())
    context("when args are all on a single line", proc (): void =
      itBehavesLike("no parentheses"))
    context("when args span multiple lines", proc (): void =
      test "reports an offense for correct + opposite":
        expectOffense("""          def func(a,
                   b)
          end
          def func a,
                   ^^ Use def with parentheses when there are parameters.
                   b
          end
""".stripIndent)
      test "auto-adds required parens to argument lists on multiple lines":
        var newSource = autocorrectSource("""          def test one,
          two
          end
""".stripIndent)
        expect(newSource).to(eq("""          def test(one,
          two)
          end
""".stripIndent)))))
