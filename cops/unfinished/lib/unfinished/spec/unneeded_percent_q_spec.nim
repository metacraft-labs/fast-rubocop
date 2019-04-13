
import
  unneeded_percent_q, test_tools

suite "UnneededPercentQ":
  var cop = UnneededPercentQ()
  context("with %q strings", proc (): void =
    test "registers an offense for only single quotes":
      expectOffense("""        %q('hi')
        ^^^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
""".stripIndent)
    test "registers an offense for only double quotes":
      expectOffense("""        %q("hi")
        ^^^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
""".stripIndent)
    test "registers an offense for no quotes":
      expectOffense("""        %q(hi)
        ^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
""".stripIndent)
    test "accepts a string with single quotes and double quotes":
      expectNoOffenses("%q(\'\"hi\"\')")
    test "registers an offfense for a string containing escaped backslashes":
      expectOffense("""        %q(\\foo\\)
        ^^^^^^^^^^^^^^^ Use `%q` only for strings that contain both single quotes and double quotes.
""".stripIndent)
    test "accepts a string with escaped non-backslash characters":
      expectNoOffenses("%q(\\\'foo\\\')")
    test "accepts a string with escaped backslash and non-backslash characters":
      expectNoOffenses("%q(\\\\ \\\'foo\\\' \\\\)")
    test "accepts regular expressions starting with %q":
      expectNoOffenses("/%q?/")
    context("auto-correct", proc (): void =
      test "registers an offense for only single quotes":
        var newSource = autocorrectSource("%q(\'hi\')")
        expect(newSource).to(eq("\"\'hi\'\""))
      test "registers an offense for only double quotes":
        var newSource = autocorrectSource("%q(\"hi\")")
        expect(newSource).to(eq("\'\"hi\"\'"))
      test "registers an offense for no quotes":
        var newSource = autocorrectSource("%q(hi)")
        expect(newSource).to(eq("\'hi\'"))
      test "auto-corrects for strings that is concated with backslash":
        var newSource = autocorrectSource("          %q(foo bar baz)             \'boogers\'\n".stripIndent)
        expect(newSource).to(eq("          \'foo bar baz\'             \'boogers\'\n".stripIndent))))
  context("with %Q strings", proc (): void =
    test "registers an offense for static string without quotes":
      expectOffense("""        %Q(hi)
        ^^^^^^ Use `%Q` only for strings that contain both single quotes and double quotes, or for dynamic strings that contain double quotes.
""".stripIndent)
    test "registers an offense for static string with only double quotes":
      expectOffense("""        %Q("hi")
        ^^^^^^^^ Use `%Q` only for strings that contain both single quotes and double quotes, or for dynamic strings that contain double quotes.
""".stripIndent)
    test "registers an offense for dynamic string without quotes":
      expectOffense("""        %Q(hi#{4})
        ^^^^^^^^^^ Use `%Q` only for strings that contain both single quotes and double quotes, or for dynamic strings that contain double quotes.
""".stripIndent)
    test "accepts a string with single quotes and double quotes":
      expectNoOffenses("%Q(\'\"hi\"\')")
    test "accepts a string with double quotes and an escaped special character":
      expectNoOffenses("%Q(\"\\thi\")")
    test "accepts a string with double quotes and an escaped normal character":
      expectNoOffenses("%Q(\"\\!thi\")")
    test "accepts a dynamic %Q string with double quotes":
      expectNoOffenses("%Q(\"hi#{4}\")")
    test "accepts regular expressions starting with %Q":
      expectNoOffenses("/%Q?/")
    context("auto-correct", proc (): void =
      test "corrects a static string without quotes":
        var newSource = autocorrectSource("%Q(hi)")
        expect(newSource).to(eq("\"hi\""))
      test "corrects a static string with only double quotes":
        var newSource = autocorrectSource("%Q(\"hi\")")
        expect(newSource).to(eq("\'\"hi\"\'"))
      test "corrects a dynamic string without quotes":
        var newSource = autocorrectSource("%Q(hi#{4})")
        expect(newSource).to(eq("\"hi#{4}\""))
      test "auto-corrects for strings that is concated with backslash":
        var newSource = autocorrectSource("          %Q(foo bar baz)             \'boogers\'\n".stripIndent)
        expect(newSource).to(eq("          \"foo bar baz\"             \'boogers\'\n".stripIndent))))
  test "accepts a heredoc string that contains %q":
    expectNoOffenses("""        s = <<CODE
      %q('hi') # line 1
      %q("hi")
      CODE
""".stripIndent)
  test """accepts %q at the beginning of a double quoted string with interpolation""":
    expectNoOffenses("\"%q(a)#{b}\"")
  test """accepts %Q at the beginning of a double quoted string with interpolation""":
    expectNoOffenses("\"%Q(a)#{b}\"")
  test """accepts %q at the beginning of a section of a double quoted string with interpolation""":
    expectNoOffenses("\"%#{b}%q(a)\"")
  test """accepts %Q at the beginning of a section of a double quoted string with interpolation""":
    expectNoOffenses("\"%#{b}%Q(a)\"")
  test "accepts %q containing string interpolation":
    expectNoOffenses("%q(foo #{\'bar\'} baz)")
