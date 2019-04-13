
import
  colon_method_call, test_tools

suite "ColonMethodCall":
  var cop = ColonMethodCall()
  test "registers an offense for instance method call":
    expectOffense("""      test::method_name
          ^^ Do not use `::` for method calls.
""".stripIndent)
  test "registers an offense for instance method call with arg":
    expectOffense("""      test::method_name(arg)
          ^^ Do not use `::` for method calls.
""".stripIndent)
  test "registers an offense for class method call":
    expectOffense("""      Class::method_name
           ^^ Do not use `::` for method calls.
""".stripIndent)
  test "registers an offense for class method call with arg":
    expectOffense("""      Class::method_name(arg, arg2)
           ^^ Do not use `::` for method calls.
""".stripIndent)
  test "does not register an offense for constant access":
    expectNoOffenses("Tip::Top::SOME_CONST")
  test "does not register an offense for nested class":
    expectNoOffenses("Tip::Top.some_method")
  test "does not register an offense for op methods":
    expectNoOffenses("Tip::Top.some_method[3]")
  test "does not register an offense when for constructor methods":
    expectNoOffenses("Tip::Top(some_arg)")
  test "does not register an offense for Java static types":
    expectNoOffenses("Java::int")
  test "does not register an offense for Java package namespaces":
    expectNoOffenses("Java::com")
  test "auto-corrects \"::\" with \".\"":
    var newSource = autocorrectSource("test::method")
    expect(newSource).to(eq("test.method"))
