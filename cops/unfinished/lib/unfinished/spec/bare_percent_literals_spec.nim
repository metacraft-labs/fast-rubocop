
import
  bare_percent_literals, test_tools

RSpec.describe(BarePercentLiterals, "config", proc (): void =
  var cop = ()
  sharedExamples("accepts other delimiters", proc (): void =
    test "accepts __FILE__":
      expectNoOffenses("__FILE__")
    test "accepts regular expressions":
      expectNoOffenses("/%Q?/")
    test "accepts \"\"":
      expectNoOffenses("\"\"")
    test "accepts \"\" string with interpolation":
      expectNoOffenses("\"#{file}hi\"")
    test "accepts \'\'":
      expectNoOffenses("\'hi\'")
    test "accepts %q":
      expectNoOffenses("%q(hi)")
    test "accepts heredoc":
      expectNoOffenses("""        func <<HEREDOC
        hi
        HEREDOC
""".stripIndent))
  context("when EnforcedStyle is percent_q", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "percent_q"}.newTable())
    context("and strings are static", proc (): void =
      test "registers an offense for %()":
        expectOffense("""          %(hi)
          ^^ Use `%Q` instead of `%`.
""".stripIndent)
      test "auto-corrects":
        var newSource = autocorrectSource("%(hi)")
        expect(newSource).to(eq("%Q(hi)"))
      test "accepts %Q()":
        expectNoOffenses("%Q(hi)")
      includeExamples("accepts other delimiters"))
    context("and strings are dynamic", proc (): void =
      test "registers an offense for %()":
        expectOffense("""          %(#{x})
          ^^ Use `%Q` instead of `%`.
""".stripIndent)
      test "auto-corrects":
        var newSource = autocorrectSource("%(#{x})")
        expect(newSource).to(eq("%Q(#{x})"))
      test "accepts %Q()":
        expectNoOffenses("%Q(#{x})")
      includeExamples("accepts other delimiters")))
  context("when EnforcedStyle is bare_percent", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "bare_percent"}.newTable())
    context("and strings are static", proc (): void =
      test "registers an offense for %Q()":
        expectOffense("""          %Q(hi)
          ^^^ Use `%` instead of `%Q`.
""".stripIndent)
      test "auto-corrects":
        var newSource = autocorrectSource("%Q(hi)")
        expect(newSource).to(eq("%(hi)"))
      test "accepts %()":
        expectNoOffenses("%(hi)")
      includeExamples("accepts other delimiters"))
    context("and strings are dynamic", proc (): void =
      test "registers an offense for %Q()":
        expectOffense("""          %Q(#{x})
          ^^^ Use `%` instead of `%Q`.
""".stripIndent)
      test "auto-corrects":
        var newSource = autocorrectSource("%Q(#{x})")
        expect(newSource).to(eq("%(#{x})"))
      test "accepts %()":
        expectNoOffenses("%(#{x})")
      includeExamples("accepts other delimiters"))))
