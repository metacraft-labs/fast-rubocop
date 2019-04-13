
import
  def_with_parentheses, test_tools

suite "DefWithParentheses":
  var cop = DefWithParentheses()
  test "reports an offense for def with empty parens":
    expectOffense("""      def func()
              ^ Omit the parentheses in defs when the method doesn't accept any arguments.
      end
""".stripIndent)
  test "reports an offense for class def with empty parens":
    expectOffense("""      def Test.func()
                   ^ Omit the parentheses in defs when the method doesn't accept any arguments.
      end
""".stripIndent)
  test "accepts def with arg and parens":
    expectNoOffenses("""      def func(a)
      end
""".stripIndent)
  test "accepts empty parentheses in one liners":
    expectNoOffenses("def to_s() join \'/\' end")
  test "auto-removes unneeded parens":
    var newSource = autocorrectSource("""      def test();
      something
      end
""".stripIndent)
    expect(newSource).to(eq("""      def test;
      something
      end
""".stripIndent))
