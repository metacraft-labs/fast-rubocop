
import
  string_literals_in_interpolation, test_tools

RSpec.describe(StringLiteralsInInterpolation, "config", proc (): void =
  var cop = ()
  context("configured with single quotes preferred", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "single_quotes"}.newTable())
    test "registers an offense for double quotes within embedded expression":
      expectOffense("""        "#{"A"}"
           ^^^ Prefer single-quoted strings inside interpolations.
""".stripIndent)
    test """registers an offense for double quotes within embedded expression in a heredoc string""":
      expectOffense("""        <<RUBY
        #{"A"}
          ^^^ Prefer single-quoted strings inside interpolations.
        RUBY
""".stripIndent)
    test "accepts double quotes on a static string":
      expectNoOffenses("\"A\"")
    test "accepts double quotes on a broken static string":
      expectNoOffenses("        \"A\"           \"B\"\n".stripIndent)
    test "accepts double quotes on static strings within a method":
      expectNoOffenses("""        def m
          puts "A"
          puts "B"
        end
""".stripIndent)
    test "can handle a built-in constant parsed as string":
      expectNoOffenses("""        if __FILE__ == $PROGRAM_NAME
        end
""".stripIndent)
    test "can handle character literals":
      expectNoOffenses("a = ?/")
    test "auto-corrects \" with \'":
      var newSource = autocorrectSource("s = \"#{\"abc\"}\"")
      expect(newSource).to(eq("s = \"#{\'abc\'}\"")))
  context("configured with double quotes preferred", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "double_quotes"}.newTable())
    test "registers an offense for single quotes within embedded expression":
      expectOffense("""        "#{'A'}"
           ^^^ Prefer double-quoted strings inside interpolations.
""".stripIndent)
    test """registers an offense for single quotes within embedded expression in a heredoc string""":
      expectOffense("""        <<RUBY
        #{'A'}
          ^^^ Prefer double-quoted strings inside interpolations.
        RUBY
""".stripIndent))
  context("when configured with a bad value", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "other"}.newTable())
    test "fails":
      expect(proc (): void =
        inspectSource("a = \"#{\"b\"}\"")).to(raiseError(RuntimeError))))
