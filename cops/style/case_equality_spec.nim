
import
  types

import
  case_equality, test_tools

RSpec.describe(CaseEquality, proc () =
  subject("cop", proc (): CaseEquality =
    describedClass.new)
  it("registers an offense for ===", proc () =
    expectOffense("""      Array === var
            ^^^ Avoid the use of the case equality operator `===`.
""".stripIndent)))
