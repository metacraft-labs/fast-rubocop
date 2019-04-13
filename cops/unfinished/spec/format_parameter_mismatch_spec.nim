
import
  format_parameter_mismatch, test_tools

suite "FormatParameterMismatch":
  var cop = FormatParameterMismatch()
  sharedExamples("variables", proc (variable: string): void =
    test "does not register an offense for % called on a variable":
      expectNoOffenses("""        (lvar :variable) = '%s'
        (lvar :variable) % [foo]
""".stripIndent)
    test "does not register an offense for format called on a variable":
      expectNoOffenses("""        (lvar :variable) = '%s'
        format((lvar :variable), foo)
""".stripIndent)
    test "does not register an offense for format called on a variable":
      expectNoOffenses("""        (lvar :variable) = '%s'
        sprintf((lvar :variable), foo)
""".stripIndent))
  itBehavesLike("variables", "CONST")
  itBehavesLike("variables", "var")
  itBehavesLike("variables", "@var")
  itBehavesLike("variables", "@@var")
  itBehavesLike("variables", "$var")
  test """registers an offense when calling Kernel.format and the fields do not match""":
    expectOffense("""      Kernel.format("%s %s", 1)
             ^^^^^^ Number of arguments (1) to `format` doesn't match the number of fields (2).
""".stripIndent)
  test """registers an offense when calling Kernel.sprintf and the fields do not match""":
    expectOffense("""      Kernel.sprintf("%s %s", 1)
             ^^^^^^^ Number of arguments (1) to `sprintf` doesn't match the number of fields (2).
""".stripIndent)
  test "registers an offense when there are less arguments than expected":
    expectOffense("""      format("%s %s", 1)
      ^^^^^^ Number of arguments (1) to `format` doesn't match the number of fields (2).
""".stripIndent)
  test "registers an offense when there are more arguments than expected":
    expectOffense("""      format("%s %s", 1, 2, 3)
      ^^^^^^ Number of arguments (3) to `format` doesn't match the number of fields (2).
""".stripIndent)
  test "does not register an offense when arguments and fields match":
    expectNoOffenses("format(\"%s %d %i\", 1, 2, 3)")
  test "correctly ignores double percent":
    expectNoOffenses("format(\'%s %s %% %s %%%% %%%%%% %%5B\', 1, 2, 3)")
  test "constants do not register offenses":
    expectNoOffenses("format(A_CONST, 1, 2, 3)")
  test "registers offense with sprintf":
    expectOffense("""      sprintf("%s %s", 1, 2, 3)
      ^^^^^^^ Number of arguments (3) to `sprintf` doesn't match the number of fields (2).
""".stripIndent)
  test "correctly parses different sprintf formats":
    expectNoOffenses("sprintf(\"%020x%+g:% g %%%#20.8x %#.0e\", 1, 2, 3, 4, 5)")
  test "registers an offense for String#%":
    expectOffense("""      "%s %s" % [1, 2, 3]
              ^ Number of arguments (3) to `String#%` doesn't match the number of fields (2).
""".stripIndent)
  test "does not register offense for `String#%` when arguments, fields match":
    expectNoOffenses("\"%s %s\" % [1, 2]")
  test "does not register an offense when single argument is a hash":
    expectNoOffenses("puts \"%s\" % {\"a\" => 1}")
  test "does not register an offense when single argument is not an array":
    expectNoOffenses("puts \"%s\" % CONST")
  context("when splat argument is present", proc (): void =
    test "does not register an offense when args count is less than expected":
      expectNoOffenses("sprintf(\"%s, %s, %s\", 1, *arr)")
    context("when args count is more than expected", proc (): void =
      test "registers an offense for `#%`":
        expectOffense("""          puts "%s, %s, %s" % [1, 2, 3, 4, *arr]
                            ^ Number of arguments (5) to `String#%` doesn't match the number of fields (3).
""".stripIndent)
      test "registers an offense for `#format`":
        expectNoOffenses("          puts format(\"%s, %s, %s\", 1, 2, 3, 4, *arr)\n".stripIndent)
      test "registers an offense for `#sprintf`":
        expectNoOffenses("          puts sprintf(\"%s, %s, %s\", 1, 2, 3, 4, *arr)\n".stripIndent)))
  context("when multiple arguments are called for", proc (): void =
    context("and a single variable argument is passed", proc (): void =
      test "does not register an offense":
        expectNoOffenses("puts \"%s %s\" % var"))
    context("and a single send node is passed", proc (): void =
      test "does not register an offense":
        expectNoOffenses("puts \"%s %s\" % (\"ab\".chars)")))
  context("when using (digit)$ flag", proc (): void =
    test "does not register an offense":
      expectNoOffenses("format(\'%1$s %2$s\', \'foo\', \'bar\')")
    test """does not register an offense when match between the maximum value specified by (digit)$ flag and the number of arguments""":
      expectNoOffenses("format(\'%1$s %1$s\', \'foo\')")
    test """registers an offense when mismatch between the maximum value specified by (digit)$ flag and the number of arguments""":
      expectOffense("""        format('%1$s %2$s', 'foo', 'bar', 'baz')
        ^^^^^^ Number of arguments (3) to `format` doesn't match the number of fields (2).
""".stripIndent))
  context("when format is not a string literal", proc (): void =
    test "does not register an offense":
      expectNoOffenses("puts str % [1, 2]"))
  context("when passed an empty array", proc (): void =
    test "does not register an offense":
      expectNoOffenses("\'%\' % []"))
  test "ignores percent right next to format string":
    expectNoOffenses("format(\"%0.1f%% percent\", 22.5)")
  test "accepts an extra argument for dynamic width":
    expectNoOffenses("format(\"%*d\", max_width, id)")
  test "registers an offense if extra argument for dynamic width not given":
    expectOffense("""      format("%*d", id)
      ^^^^^^ Number of arguments (1) to `format` doesn't match the number of fields (2).
""".stripIndent)
  test "accepts an extra arg for dynamic width with other preceding flags":
    expectNoOffenses("format(\"%0*x\", max_width, id)")
  test "accepts an extra arg for dynamic width with other following flags":
    expectNoOffenses("format(\"%*0x\", max_width, id)")
  test "does not register an offense argument is the result of a message send":
    expectNoOffenses("format(\"%s\", \"a b c\".gsub(\" \", \"_\"))")
  test "does not register an offense when using named parameters":
    expectNoOffenses("\"foo %{bar} baz\" % { bar: 42 }")
  test "identifies correctly digits for spacing in format":
    expectNoOffenses("\"duration: %10.fms\" % 42")
  test "finds faults even when the string looks like a HEREDOC":
    expectOffense("""      format("<< %s bleh", 1, 2)
      ^^^^^^ Number of arguments (2) to `format` doesn't match the number of fields (1).
""".stripIndent)
  test "does not register an offense for sprintf with splat argument":
    expectNoOffenses("sprintf(\"%d%d\", *test)")
  test "does not register an offense for format with splat argument":
    expectNoOffenses("format(\"%d%d\", *test)")
  context("on format with %{} interpolations", proc (): void =
    context("and 1 argument", proc (): void =
      test "does not register an offense":
        expectNoOffenses("""          params = { y: '2015', m: '01', d: '01' }
          puts format('%{y}-%{m}-%{d}', params)
""".stripIndent))
    context("and multiple arguments", proc (): void =
      test "registers an offense":
        expectOffense("""          params = { y: '2015', m: '01', d: '01' }
          puts format('%{y}-%{m}-%{d}', 2015, 1, 1)
               ^^^^^^ Number of arguments (3) to `format` doesn't match the number of fields (1).
""".stripIndent)))
  context("on format with %<> interpolations", proc (): void =
    context("and 1 argument", proc (): void =
      test "does not register an offense":
        expectNoOffenses("""          params = { y: '2015', m: '01', d: '01' }
          puts format('%<y>d-%<m>d-%<d>d', params)
""".stripIndent))
    context("and multiple arguments", proc (): void =
      test "registers an offense":
        expectOffense("""          params = { y: '2015', m: '01', d: '01' }
          puts format('%<y>d-%<m>d-%<d>d', 2015, 1, 1)
               ^^^^^^ Number of arguments (3) to `format` doesn't match the number of fields (1).
""".stripIndent)))
  context("with wildcard", proc (): void =
    test "does not register an offense for width":
      expectNoOffenses("format(\"%*d\", 10, 3)")
    test "does not register an offense for precision":
      expectNoOffenses("format(\"%.*f\", 2, 20.19)")
    test "does not register an offense for width and precision":
      expectNoOffenses("format(\"%*.*f\", 10, 3, 20.19)")
    test "does not register an offense for multiple wildcards":
      expectNoOffenses("format(\"%*.*f %*.*f\", 10, 2, 20.19, 5, 1, 11.22)"))
  test "finds the correct number of fields":
    expect("".scan(FIELDREGEX).size).to(eq(0))
    expect("%s".scan(FIELDREGEX).size).to(eq(1))
    expect("%s %s".scan(FIELDREGEX).size).to(eq(2))
    expect("%s %s %%".scan(FIELDREGEX).size).to(eq(3))
    expect("%s %s %%".scan(FIELDREGEX).size).to(eq(3))
    expect("% d".scan(FIELDREGEX).size).to(eq(1))
    expect("%+d".scan(FIELDREGEX).size).to(eq(1))
    expect("%d".scan(FIELDREGEX).size).to(eq(1))
    expect("%+o".scan(FIELDREGEX).size).to(eq(1))
    expect("%#o".scan(FIELDREGEX).size).to(eq(1))
    expect("%.0e".scan(FIELDREGEX).size).to(eq(1))
    expect("%#.0e".scan(FIELDREGEX).size).to(eq(1))
    expect("% 020d".scan(FIELDREGEX).size).to(eq(1))
    expect("%20d".scan(FIELDREGEX).size).to(eq(1))
    expect("%+20d".scan(FIELDREGEX).size).to(eq(1))
    expect("%020d".scan(FIELDREGEX).size).to(eq(1))
    expect("%+020d".scan(FIELDREGEX).size).to(eq(1))
    expect("% 020d".scan(FIELDREGEX).size).to(eq(1))
    expect("%-20d".scan(FIELDREGEX).size).to(eq(1))
    expect("%-+20d".scan(FIELDREGEX).size).to(eq(1))
    expect("%- 20d".scan(FIELDREGEX).size).to(eq(1))
    expect("%020x".scan(FIELDREGEX).size).to(eq(1))
    expect("%#20.8x".scan(FIELDREGEX).size).to(eq(1))
    expect("%+g:% g:%-g".scan(FIELDREGEX).size).to(eq(3))
    expect("%+-d".scan(FIELDREGEX).size).to(eq(1))
