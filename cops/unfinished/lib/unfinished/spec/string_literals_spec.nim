
import
  string_literals, test_tools

RSpec.describe(StringLiterals, "config", proc (): void =
  var cop = ()
  context("configured with single quotes preferred", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "single_quotes"}.newTable())
    test "registers offense for double quotes when single quotes suffice":
      expectOffense("""        s = "abc"
            ^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
        x = "a\b"
            ^^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
        y ="\b"
           ^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
        z = "a\"
            ^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
""".stripIndent)
      expect(cop().configToAllowOffenses).to(eq())
    test "registers offense for correct + opposite":
      expectOffense("""        s = "abc"
            ^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
        x = 'abc'
""".stripIndent)
    test "accepts single quotes":
      expectNoOffenses("a = \'x\'")
    test "accepts single quotes in interpolation":
      expectNoOffenses("\"hello#{hash[\'there\']}\"")
    test "accepts %q and %Q quotes":
      expectNoOffenses("a = %q(x) + %Q[x]")
    test "accepts % quotes":
      expectNoOffenses("a = %(x)")
    test "accepts heredocs":
      expectNoOffenses("""        execute <<-SQL
          SELECT name from users
        SQL
""".stripIndent)
    test "accepts double quotes when new line is used":
      expectNoOffenses("\"\\n\"")
    test "accepts double quotes when interpolating & quotes in multiple lines":
      expectNoOffenses("        \"#{encode_severity}:#{sprintf(\'%3d\', line_number)}: #{m}\"\n".stripIndent)
    test "accepts double quotes when single quotes are used":
      expectNoOffenses("\"\'\"")
    test "accepts double quotes when interpolating an instance variable":
      expectNoOffenses("\"#@test\"")
    test "accepts double quotes when interpolating a global variable":
      expectNoOffenses("\"#$test\"")
    test "accepts double quotes when interpolating a class variable":
      expectNoOffenses("\"#@@test\"")
    test "accepts double quotes when control characters are used":
      expectNoOffenses("\"\\e\"")
    test "accepts double quotes when unicode control sequence is used":
      expectNoOffenses("\"Espa\\u00f1a\"")
    test "accepts double quotes at the start of regexp literals":
      expectNoOffenses("s = /\"((?:[^\\\"]|\\.)*)\"/")
    test "accepts double quotes with some other special symbols":
      expectNoOffenses("""        g = "\xf9"
        copyright = "\u00A9"
""".stripIndent)
    test "accepts \" in a %w":
      expectNoOffenses("%w(\")")
    test "accepts \\\\\\n in a string":
      expectNoOffenses("\"foo \\\\\\n bar\"")
    test "accepts double quotes in interpolation":
      expectNoOffenses("\"#{\"A\"}\"")
    test "detects unneeded double quotes within concatenated string":
      expectOffense("""        "#{x}" \
        "y"
        ^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
""".stripIndent)
    test "can handle a built-in constant parsed as string":
      expectNoOffenses("""        if __FILE__ == $PROGRAM_NAME
        end
""".stripIndent)
    test "can handle character literals":
      expectNoOffenses("a = ?/")
    test "auto-corrects \" with \'":
      var newSource = autocorrectSource("s = \"abc\"")
      expect(newSource).to(eq("s = \'abc\'"))
    test "registers an offense for \"\\\"\"":
      expectOffense("""        "\""
        ^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
""".stripIndent)
    test "registers an offense for words with non-ascii chars":
      expectOffense("""        "España"
        ^^^^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
""".stripIndent)
    test "autocorrects words with non-ascii chars":
      var newSource = autocorrectSource("\"España\"")
      expect(newSource).to(eq("\'España\'"))
    test """does not register an offense for words with non-ascii chars and other control sequences""":
      expectNoOffenses("\"España\\n\"")
    test """does not autocorrect words with non-ascii chars and other control sequences""":
      var newSource = autocorrectSource("\"España\\n\"")
      expect(newSource).to(eq("\"España\\n\"")))
  context("configured with double quotes preferred", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "double_quotes"}.newTable())
    test """registers offense for single quotes when double quotes would be equivalent""":
      expectOffense("""        s = 'abc'
            ^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
""".stripIndent)
      expect(cop().configToAllowOffenses).to(eq())
    test "registers offense for opposite + correct":
      expectOffense("""        s = "abc"
        x = 'abc'
            ^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
""".stripIndent)
      expect(cop().configToAllowOffenses).to(eq())
    test "registers offense for escaped single quote in single quotes":
      expectOffense("""        '\''
        ^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
""".stripIndent)
    test "does not accept multiple escaped single quotes in single quotes":
      expectOffense("""        'This \'string\' has \'multiple\' escaped quotes'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
""".stripIndent)
    test "accepts double quotes":
      expectNoOffenses("a = \"x\"")
    test "accepts single quotes in interpolation":
      expectNoOffenses("\"hello#{hash[\'there\']}\"")
    test "accepts %q and %Q quotes":
      expectNoOffenses("a = %q(x) + %Q[x]")
    test "accepts % quotes":
      expectNoOffenses("a = %(x)")
    test "accepts heredocs":
      expectNoOffenses("""        execute <<-SQL
          SELECT name from users
        SQL
""".stripIndent)
    test "accepts single quotes in string with escaped non-\' character":
      expectNoOffenses("\'\\n\'")
    test "accepts escaped single quote in string with escaped non-\' character":
      expectNoOffenses("\'\\\'\\n\'")
    test "accepts single quotes when they are needed":
      expectNoOffenses("""        a = '\n'
        b = '"'
        c = '#{x}'
""".stripIndent)
    test "flags single quotes with plain # (not #@var or #{interpolation}":
      expectOffense("""        a = 'blah #'
            ^^^^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
""".stripIndent)
    test "accepts single quotes at the start of regexp literals":
      expectNoOffenses("s = /\'((?:[^\\\']|\\.)*)\'/")
    test "accepts \' in a %w":
      expectNoOffenses("%w(\')")
    test "can handle a built-in constant parsed as string":
      expectNoOffenses("""        if __FILE__ == $PROGRAM_NAME
        end
""".stripIndent)
    test "auto-corrects \' with \"":
      var newSource = autocorrectSource("s = \'abc\'")
      expect(newSource).to(eq("s = \"abc\"")))
  context("when configured with a bad value", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "other"}.newTable())
    test "fails":
      expect(proc (): void =
        inspectSource("a = \"b\"")).to(raiseError(RuntimeError)))
  context("when ConsistentQuotesInMultiline is true", proc (): void =
    context("and EnforcedStyle is single_quotes", proc (): void =
      let("cop_config", proc (): void =
        {"ConsistentQuotesInMultiline": true, "EnforcedStyle": "single_quotes"}.newTable())
      test "registers an offense for strings with line breaks in them":
        expectOffense("""          "--
          ^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
          SELECT *
            LEFT JOIN X on Y
            FROM Models"
""".stripIndent)
      test "accepts continued strings using all single quotes":
        expectNoOffenses("          \'abc\'           \'def\'\n".stripIndent)
      test "registers an offense for mixed quote styles in a continued string":
        expectOffense("""          'abc' \
          ^^^^^^^ Inconsistent quote style.
          "def"
""".stripIndent)
      test "registers an offense for unneeded double quotes in continuation":
        expectOffense("""          "abc" \
          ^^^^^^^ Prefer single-quoted strings when you don't need string interpolation or special symbols.
          "def"
""".stripIndent)
      test "doesn\'t register offense for double quotes with interpolation":
        expectNoOffenses("""          "abc" \
          "def#{1}"
""".stripIndent)
      test "doesn\'t register offense for double quotes with embedded single":
        expectNoOffenses("          \"abc\'\"           \"def\"\n".stripIndent)
      test "accepts for double quotes with an escaped special character":
        expectNoOffenses("""          "abc\t" \
          "def"
""".stripIndent)
      test "accepts for double quotes with an escaped normal character":
        expectNoOffenses("""          "abc\!" \
          "def"
""".stripIndent)
      test "doesn\'t choke on heredocs with inconsistent indentation":
        expectNoOffenses("""          <<-QUERY_STRING
            DEFINE
              BLAH
          QUERY_STRING
""".stripIndent))
    context("and EnforcedStyle is double_quotes", proc (): void =
      let("cop_config", proc (): void =
        {"ConsistentQuotesInMultiline": true, "EnforcedStyle": "double_quotes"}.newTable())
      test "accepts continued strings using all double quotes":
        expectNoOffenses("          \"abc\"           \"def\"\n".stripIndent)
      test "registers an offense for mixed quote styles in a continued string":
        expectOffense("""          'abc' \
          ^^^^^^^ Inconsistent quote style.
          "def"
""".stripIndent)
      test "registers an offense for unneeded single quotes in continuation":
        expectOffense("""          'abs' \
          ^^^^^^^ Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
          'def'
""".stripIndent)
      test "doesn\'t register offense for single quotes with embedded double":
        expectNoOffenses("          \'abc\"\'           \'def\'\n".stripIndent))))
