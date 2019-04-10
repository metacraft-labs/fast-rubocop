
import
  method_call_without_args_parentheses, test_tools

RSpec.describe(MethodCallWithoutArgsParentheses, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"IgnoredMethods": @["s"]}.newTable())
  test "registers an offense for parens in method call without args":
    expectOffense("""      top.test()
              ^^ Do not use parentheses for method calls with no arguments.
""".stripIndent)
  test "accepts parentheses for methods starting with an upcase letter":
    expectNoOffenses("Test()")
  test "accepts no parens in method call without args":
    expectNoOffenses("top.test")
  test "accepts parens in method call with args":
    expectNoOffenses("top.test(a)")
  test "accepts special lambda call syntax":
    expectNoOffenses("thing.()")
  test "accepts parens after not":
    expectNoOffenses("not(something)")
  test "ignores method listed in IgnoredMethods":
    expectNoOffenses("s()")
  context("assignment to a variable with the same name", proc (): void =
    test "accepts parens in local variable assignment ":
      expectNoOffenses("test = test()")
    test "accepts parens in shorthand assignment":
      expectNoOffenses("test ||= test()")
    test "accepts parens in parallel assignment":
      expectNoOffenses("one, test = 1, test()")
    test "accepts parens in complex assignment":
      expectNoOffenses("""        test = begin
          case a
          when b
            c = test() if d
          end
        end
""".stripIndent))
  test "registers an offense for `obj.method ||= func()`":
    expectOffense("""      obj.method ||= func()
                         ^^ Do not use parentheses for method calls with no arguments.
""".stripIndent)
  test "registers an offense for `obj.method &&= func()`":
    expectOffense("""      obj.method &&= func()
                         ^^ Do not use parentheses for method calls with no arguments.
""".stripIndent)
  test "registers an offense for `obj.method += func()`":
    expectOffense("""      obj.method += func()
                        ^^ Do not use parentheses for method calls with no arguments.
""".stripIndent)
  test "auto-corrects by removing unneeded braces":
    var newSource = autocorrectSource("test()")
    expect(newSource).to(eq("test"))
  test "auto-corrects calls that could be empty literals":
    var
      original = """      Hash.new()
      Array.new()
      String.new()
""".stripIndent
      newSource = autocorrectSource(original)
    expect(newSource).to(eq("""      Hash.new
      Array.new
      String.new
""".stripIndent))
  context("method call as argument", proc (): void =
    test "accepts without parens":
      expectNoOffenses("_a = c(d.e)")
    test "registers an offense with empty parens":
      expectOffense("""        _a = c(d())
                ^^ Do not use parentheses for method calls with no arguments.
""".stripIndent)
    test "registers an empty parens offense for multiple assignment":
      expectOffense("""        _a, _b, _c = d(e())
                        ^^ Do not use parentheses for method calls with no arguments.
""".stripIndent)))
