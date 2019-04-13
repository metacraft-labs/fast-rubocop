
import
  require_parentheses, test_tools

suite "RequireParentheses":
  var cop = RequireParentheses()
  test """registers an offense for missing parentheses around expression with && operator""":
    expectOffense("""      if day.is? 'monday' && month == :jan
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use parentheses in the method call to avoid confusion about precedence.
        foo
      end
""".stripIndent)
  test """registers an offense for missing parentheses around expression with || operator""":
    expectOffense("""      day_is? 'tuesday' || true
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use parentheses in the method call to avoid confusion about precedence.
""".stripIndent)
  test """registers an offense for missing parentheses around expression in ternary""":
    expectOffense("""      wd.include? 'tuesday' && true == true ? a : b
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use parentheses in the method call to avoid confusion about precedence.
""".stripIndent)
  context("when using safe navigation operator", "ruby23", proc (): void =
    test """registers an offense for missing parentheses around expression with && operator""":
      expectOffense("""        if day&.is? 'monday' && month == :jan
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use parentheses in the method call to avoid confusion about precedence.
          foo
        end
""".stripIndent))
  test "accepts missing parentheses around expression with + operator":
    expectNoOffenses("""      if day_is? 'tuesday' + rest
      end
""".stripIndent)
  test "accepts method calls without parentheses followed by keyword and/or":
    expectNoOffenses("""      if day.is? 'tuesday' and month == :jan
      end
      if day.is? 'tuesday' or month == :jan
      end
""".stripIndent)
  test "accepts method calls that are all operations":
    expectNoOffenses("""      if current_level == max + 1
      end
""".stripIndent)
  test "accepts condition that is not a call":
    expectNoOffenses("""      if @debug
      end
""".stripIndent)
  test "accepts parentheses around expression with boolean operator":
    expectNoOffenses("""      if day.is?('tuesday' && true == true)
      end
""".stripIndent)
  test "accepts method call with parentheses in ternary":
    expectNoOffenses("wd.include?(\'tuesday\' && true == true) ? a : b")
  test "accepts missing parentheses when method is not a predicate":
    expectNoOffenses("weekdays.foo \'tuesday\' && true == true")
  test "accepts calls to methods that are setters":
    expectNoOffenses("s.version = @version || \">= 1.8.5\"")
  test "accepts calls to methods that are operators":
    expectNoOffenses("a[b || c]")
