
import
  statementModifierHelper

import
  if_unless_modifier_of_if_unless, test_tools

suite "IfUnlessModifierOfIfUnless":
  var cop = IfUnlessModifierOfIfUnless()
  test "provides a good error message":
    expectOffense("""      condition ? then_part : else_part unless external_condition
                                        ^^^^^^ Avoid modifier `unless` after another conditional.
""".stripIndent)
  context("ternary with modifier", proc (): void =
    test "registers an offense":
      expectOffense("""        condition ? then_part : else_part unless external_condition
                                          ^^^^^^ Avoid modifier `unless` after another conditional.
""".stripIndent))
  context("conditional with modifier", proc (): void =
    test "registers an offense":
      expectOffense("""        unless condition
          then_part
        end if external_condition
            ^^ Avoid modifier `if` after another conditional.
""".stripIndent))
  context("conditional with modifier in body", proc (): void =
    test "accepts":
      expectNoOffenses("""        if condition
          then_part if maybe?
        end
""".stripIndent))
  context("nested conditionals", proc (): void =
    test "accepts":
      expectNoOffenses("""        if external_condition
          if condition
            then_part
          end
        end
""".stripIndent))
