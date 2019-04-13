
import
  first_method_argument_line_break, test_tools

suite "FirstMethodArgumentLineBreak":
  var cop = FirstMethodArgumentLineBreak()
  context("args listed on the first line", proc (): void =
    test "detects the offense":
      expectOffense("""        foo(bar,
            ^^^ Add a line break before the first argument of a multi-line method argument list.
          baz)
""".stripIndent)
    test "autocorrects the offense":
      var newSource = autocorrectSource("""        foo(bar,
          baz)
""".stripIndent)
      expect(newSource).to(eq("""        foo(
        bar,
          baz)
""".stripIndent))
    context("when using safe navigation operator", "ruby23", proc (): void =
      test "detects the offense":
        expectOffense("""          receiver&.foo(bar,
                        ^^^ Add a line break before the first argument of a multi-line method argument list.
            baz)
""".stripIndent)
      test "autocorrects the offense":
        var newSource = autocorrectSource("""          receiver&.foo(bar,
            baz)
""".stripIndent)
        expect(newSource).to(eq("""          receiver&.foo(
          bar,
            baz)
""".stripIndent))))
  context("hash arg spanning multiple lines", proc (): void =
    test "detects the offense":
      expectOffense("""        something(3, bar: 1,
                  ^ Add a line break before the first argument of a multi-line method argument list.
        baz: 2)
""".stripIndent)
    test "autocorrects the offense":
      var newSource = autocorrectSource("""        something(3, bar: 1,
        baz: 2)
""".stripIndent)
      expect(newSource).to(eq("""        something(
        3, bar: 1,
        baz: 2)
""".stripIndent)))
  context("hash arg without a line break before the first pair", proc (): void =
    test "detects the offense":
      expectOffense("""        something(bar: 1,
                  ^^^^^^ Add a line break before the first argument of a multi-line method argument list.
        baz: 2)
""".stripIndent)
    test "autocorrects the offense":
      var newSource = autocorrectSource("""        something(bar: 1,
        baz: 2)
""".stripIndent)
      expect(newSource).to(eq("""        something(
        bar: 1,
        baz: 2)
""".stripIndent)))
  test "ignores arguments listed on a single line":
    expectNoOffenses("foo(bar, baz, bing)")
  test "ignores arguments without parens":
    expectNoOffenses("""      foo bar,
        baz
""".stripIndent)
  test "ignores methods without arguments":
    expectNoOffenses("foo")
