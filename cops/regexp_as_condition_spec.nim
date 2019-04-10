
import
  regexp_as_condition, test_tools

suite "RegexpAsCondition":
  var cop = RegexpAsCondition()
  let("config", proc (): void =
    Config.new)
  test "registers an offense for a regexp literal in `if` condition":
    expectOffense("""      if /foo/
         ^^^^^ Do not use regexp literal as a condition. The regexp literal matches `$_` implicitly.
      end
""".stripIndent)
  test "does not register an offense for a regexp literal outside conditions":
    expectNoOffenses("      /foo/\n".stripIndent)
  test "does not register an offense for a regexp literal with `=~` operator":
    expectNoOffenses("""      if /foo/ =~ str
      end
""".stripIndent)
