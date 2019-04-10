
import
  duplicate_case_condition, test_tools

suite "DuplicateCaseCondition":
  var cop = DuplicateCaseCondition()
  test "registers an offense for repeated case conditionals":
    expectOffense("""      case x
      when false
        first_method
      when true
        second_method
      when false
           ^^^^^ Duplicate `when` condition detected.
        third_method
      end
""".stripIndent)
  test "registers an offense for subsequent repeated case conditionals":
    expectOffense("""      case x
      when false
        first_method
      when false
           ^^^^^ Duplicate `when` condition detected.
        second_method
      end
""".stripIndent)
  test "registers multiple offenses for multiple repeated case conditionals":
    expectOffense("""      case x
      when false
        first_method
      when true
        second_method
      when false
           ^^^^^ Duplicate `when` condition detected.
        third_method
      when true
           ^^^^ Duplicate `when` condition detected.
        fourth_method
      end
""".stripIndent)
  test "registers multiple offenses for repeated multi-value condtionals":
    expectOffense("""      case x
      when a, b
        first_method
      when b, a
              ^ Duplicate `when` condition detected.
           ^ Duplicate `when` condition detected.
        second_method
      end
""".stripIndent)
  test "registers an offense for repeated logical operator when expressions":
    expectOffense("""      case x
      when a && b
        first_method
      when a && b
           ^^^^^^ Duplicate `when` condition detected.
        second_method
      end
""".stripIndent)
  test "accepts trivial case expressions":
    expectNoOffenses("""      case x
      when false
        first_method
      end
""".stripIndent)
  test "accepts non-redundant case expressions":
    expectNoOffenses("""      case x
      when false
        first_method
      when true
        second_method
      end
""".stripIndent)
  test "accepts non-redundant case expressions with an else expression":
    expectNoOffenses("""      case x
      when false
        method_name
      when true
        second_method
      else
        third_method
      end
""".stripIndent)
  test "accepts similar but not equivalent && expressions":
    expectNoOffenses("""      case x
      when something && another && other
        first_method
      when something && another
        second_method
      end
""".stripIndent)
