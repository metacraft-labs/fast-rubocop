
import
  if_inside_else, test_tools

suite "IfInsideElse":
  var cop = IfInsideElse()
  test "catches an if node nested inside an else":
    expectOffense("""      if a
        blah
      else
        if b
        ^^ Convert `if` nested inside `else` to `elsif`.
          foo
        end
      end
""".stripIndent)
  test "catches an if..else nested inside an else":
    expectOffense("""      if a
        blah
      else
        if b
        ^^ Convert `if` nested inside `else` to `elsif`.
          foo
        else
          bar
        end
      end
""".stripIndent)
  test "catches a modifier if nested inside an else":
    expectOffense("""      if a
        blah
      else
        foo if b
            ^^ Convert `if` nested inside `else` to `elsif`.
      end
""".stripIndent)
  test "isn\'t offended if there is a statement following the if node":
    expectNoOffenses("""      if a
        blah
      else
        if b
          foo
        end
        bar
      end
""".stripIndent)
  test "isn\'t offended if there is a statement preceding the if node":
    expectNoOffenses("""      if a
        blah
      else
        bar
        if b
          foo
        end
      end
""".stripIndent)
  test "isn\'t offended by if..elsif..else":
    expectNoOffenses("""      if a
        blah
      elsif b
        blah
      else
        blah
      end
""".stripIndent)
  test "ignores unless inside else":
    expectNoOffenses("""      if a
        blah
      else
        unless b
          foo
        end
      end
""".stripIndent)
  test "ignores if inside unless":
    expectNoOffenses("""      unless a
        if b
          foo
        end
      end
""".stripIndent)
  test "ignores nested ternary expressions":
    expectNoOffenses("a ? b : c ? d : e")
  test "ignores ternary inside if..else":
    expectNoOffenses("""      if a
        blah
      else
        a ? b : c
      end
""".stripIndent)
