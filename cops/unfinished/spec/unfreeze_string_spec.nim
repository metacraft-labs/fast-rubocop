
import
  unfreeze_string, test_tools

RSpec.describe(UnfreezeString, "config", proc (): void =
  var cop = ()
  context("TargetRubyVersion >= 2.3", "ruby23", proc (): void =
    test "registers an offense for an empty string with `.dup`":
      expectOffense("""        "".dup
        ^^^^^^ Use unary plus to get an unfrozen string literal.
""".stripIndent)
    test "registers an offense for a string with `.dup`":
      expectOffense("""        "foo".dup
        ^^^^^^^^^ Use unary plus to get an unfrozen string literal.
""".stripIndent)
    test "registers an offense for a heredoc with `.dup`":
      expectOffense("""        <<TEXT.dup
        ^^^^^^^^^^ Use unary plus to get an unfrozen string literal.
          foo
          bar
        TEXT
""".stripIndent)
    test """registers an offense for a string that contains a stringinterpolation with `.dup`""":
      expectOffense("""        "foo#{bar}baz".dup
        ^^^^^^^^^^^^^^^^^^ Use unary plus to get an unfrozen string literal.
""".stripIndent)
    test "registers an offense for `String.new`":
      expectOffense("""        String.new
        ^^^^^^^^^^ Use unary plus to get an unfrozen string literal.
""".stripIndent)
    test "registers an offense for `String.new` with an empty string":
      expectOffense("""        String.new('')
        ^^^^^^^^^^^^^^ Use unary plus to get an unfrozen string literal.
""".stripIndent)
    test "registers an offense for `String.new` with a string":
      expectOffense("""        String.new('foo')
        ^^^^^^^^^^^^^^^^^ Use unary plus to get an unfrozen string literal.
""".stripIndent)
    test "accepts an empty string with unary plus operator":
      expectNoOffenses("        +\"\"\n".stripIndent)
    test "accepts a string with unary plus operator":
      expectNoOffenses("        +\"foobar\"\n".stripIndent)
    test "accepts `String.new` with capacity option":
      expectNoOffenses("        String.new(capacity: 100)\n".stripIndent)))
