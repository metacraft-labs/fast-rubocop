
import
  tables

import
  parentheses_around_condition, test_tools

RSpec.describe(ParenthesesAroundCondition, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"AllowSafeAssignment": true}.newTable())
  test "registers an offense for parentheses around condition":
    expectOffense("""      if (x > 10)
         ^^^^^^^^ Don't use parentheses around the condition of an `if`.
      elsif (x < 3)
            ^^^^^^^ Don't use parentheses around the condition of an `elsif`.
      end
      unless (x > 10)
             ^^^^^^^^ Don't use parentheses around the condition of an `unless`.
      end
      while (x > 10)
            ^^^^^^^^ Don't use parentheses around the condition of a `while`.
      end
      until (x > 10)
            ^^^^^^^^ Don't use parentheses around the condition of an `until`.
      end
      x += 1 if (x < 10)
                ^^^^^^^^ Don't use parentheses around the condition of an `if`.
      x += 1 unless (x < 10)
                    ^^^^^^^^ Don't use parentheses around the condition of an `unless`.
      x += 1 until (x < 10)
                   ^^^^^^^^ Don't use parentheses around the condition of an `until`.
      x += 1 while (x < 10)
                   ^^^^^^^^ Don't use parentheses around the condition of a `while`.
""".stripIndent)
  test "accepts parentheses if there is no space between the keyword and (.":
    expectNoOffenses("""      if(x > 5) then something end
      do_something until(x > 5)
""".stripIndent)
  test "auto-corrects parentheses around condition":
    var corrected = autocorrectSource("""      if (x > 10)
      elsif (x < 3)
      end
      unless (x > 10)
      end
      while (x > 10)
      end
      until (x > 10)
      end
      x += 1 if (x < 10)
      x += 1 unless (x < 10)
      x += 1 while (x < 10)
      x += 1 until (x < 10)
""".stripIndent)
    expect(corrected).to(eq("""      if x > 10
      elsif x < 3
      end
      unless x > 10
      end
      while x > 10
      end
      until x > 10
      end
      x += 1 if x < 10
      x += 1 unless x < 10
      x += 1 while x < 10
      x += 1 until x < 10
""".stripIndent))
  test "accepts condition without parentheses":
    expectNoOffenses("""      if x > 10
      end
      unless x > 10
      end
      while x > 10
      end
      until x > 10
      end
      x += 1 if x < 10
      x += 1 unless x < 10
      x += 1 while x < 10
      x += 1 until x < 10
""".stripIndent)
  test "accepts parentheses around condition in a ternary":
    expectNoOffenses("(a == 0) ? b : a")
  test "is not confused by leading parentheses in subexpression":
    expectNoOffenses("(a > b) && other ? one : two")
  test "is not confused by unbalanced parentheses":
    expectNoOffenses("""      if (a + b).c()
      end
""".stripIndent)
  for op in @["rescue", "if", "unless", "while", "until"]:
    test """allows parens if the condition node is a modifier (lvar :op) op""":
      expectNoOffenses("""        if (something (lvar :op) top)
        end
""".stripIndent)
  test "does not blow up when the condition is a ternary op":
    expectOffense("""      x if (a ? b : c)
           ^^^^^^^^^^^ Don't use parentheses around the condition of an `if`.
""".stripIndent)
  test "does not blow up for empty if condition":
    expectNoOffenses("""      if ()
      end
""".stripIndent)
  test "does not blow up for empty unless condition":
    expectNoOffenses("""      unless ()
      end
""".stripIndent)
  context("safe assignment is allowed", proc (): void =
    test "accepts variable assignment in condition surrounded with parentheses":
      expectNoOffenses("""        if (test = 10)
        end
""".stripIndent)
    test "accepts element assignment in condition surrounded with parentheses":
      expectNoOffenses("""        if (test[0] = 10)
        end
""".stripIndent)
    test "accepts setter in condition surrounded with parentheses":
      expectNoOffenses("""        if (self.test = 10)
        end
""".stripIndent))
  context("safe assignment is not allowed", proc (): void =
    let("cop_config", proc (): void =
      {"AllowSafeAssignment": false}.newTable())
    test """does not accept variable assignment in condition surrounded with parentheses""":
      expectOffense("""        if (test = 10)
           ^^^^^^^^^^^ Don't use parentheses around the condition of an `if`.
        end
""".stripIndent)
    test """does not accept element assignment in condition surrounded with parentheses""":
      expectOffense("""        if (test[0] = 10)
           ^^^^^^^^^^^^^^ Don't use parentheses around the condition of an `if`.
        end
""".stripIndent))
  context("parentheses in multiline conditions are allowed", proc (): void =
    let("cop_config", proc (): void =
      {"AllowInMultilineConditions": true}.newTable())
    test "accepts parentheses around multiline condition":
      expectNoOffenses("""        if (
          x > 3 &&
          x < 10
        )
          return true
        end
""".stripIndent)
    test "registers an offense for parentheses in single line condition":
      expectOffense("""        if (x > 3 && x < 10)
           ^^^^^^^^^^^^^^^^^ Don't use parentheses around the condition of an `if`.
          return true
        end
""".stripIndent))
  context("parentheses in multiline conditions are not allowed", proc (): void =
    let("cop_config", proc (): void =
      {"AllowInMultilineConditions": false}.newTable())
    test "registers an offense for parentheses around multiline condition":
      expectOffense("""        if (
           ^ Don't use parentheses around the condition of an `if`.
          x > 3 &&
          x < 10
        )
          return true
        end
""".stripIndent)))
