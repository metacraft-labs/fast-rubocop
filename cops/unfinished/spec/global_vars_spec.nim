
import
  tables

import
  global_vars, test_tools

RSpec.describe(GlobalVars, "config", proc (): void =
  var
    copConfig = {"AllowedVariables": @["$allowed"]}.newTable()
    cop = ()
  let("cop_config", proc (): void =
    copConfig)
  test "registers an offense for $custom":
    expectOffense("""      puts $custom
           ^^^^^^^ Do not introduce global variables.
""".stripIndent)
  test "allows user whitelisted variables":
    expectNoOffenses("puts $allowed")
  for var in BUILTINVARS:
    test """does not register an offense for built-in variable (lvar :var)""":
      expectNoOffenses("""        puts (lvar :var)
""".stripIndent)
  test "does not register an offense for backrefs like $1":
    expectNoOffenses("puts $1"))
