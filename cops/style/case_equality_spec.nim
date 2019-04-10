
import
  types

import
  case_equality, test_tools

suite "CaseEquality":
  var cop = CaseEquality()
  test "registers an offense for ===":
    expectOffense("""      Array === var
            ^^^ Avoid the use of the case equality operator `===`.
""".stripIndent)
