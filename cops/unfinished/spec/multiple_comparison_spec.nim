
import
  multiple_comparison, test_tools

suite "MultipleComparison":
  var cop = MultipleComparison()
  let("config", proc (): void =
    Config.new)
  test "does not register an offense for comparing an lvar":
    expectNoOffenses("""      a = "a"
      if a == "a"
        print a
      end
""".stripIndent)
  test "registers an offense when `a` is compared twice":
    expectOffense("""      a = "a"
      if a == "a" || a == "b"
         ^^^^^^^^^^^^^^^^^^^^ Avoid comparing a variable with multiple items in a conditional, use `Array#include?` instead.
        print a
      end
""".stripIndent)
  test "registers an offense when `a` is compared three times":
    expectOffense("""      a = "a"
      if a == "a" || a == "b" || a == "c"
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid comparing a variable with multiple items in a conditional, use `Array#include?` instead.
        print a
      end
""".stripIndent)
  test """registers an offense when `a` is compared three times on the right hand side""":
    expectOffense("""      a = "a"
      if "a" == a || "b" == a || "c" == a
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid comparing a variable with multiple items in a conditional, use `Array#include?` instead.
        print a
      end
""".stripIndent)
  test """registers an offense when `a` is compared three times, once on the righthand side""":
    expectOffense("""      a = "a"
      if a == "a" || "b" == a || a == "c"
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid comparing a variable with multiple items in a conditional, use `Array#include?` instead.
        print a
      end
""".stripIndent)
  test """registers an offense when multiple comparison is not part of a conditional""":
    expectOffense("""      def foo(x)
        x == 1 || x == 2 || x == 3
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid comparing a variable with multiple items in a conditional, use `Array#include?` instead.
      end
""".stripIndent)
  test "does not register an offense for comparing multiple literal strings":
    expectNoOffenses("""      if "a" == "a" || "a" == "c"
        print "a"
      end
""".stripIndent)
  test "does not register an offense for comparing multiple int literals":
    expectNoOffenses("""      if 1 == 1 || 1 == 2
        print 1
      end
""".stripIndent)
  test "does not register an offense for comparing lvars":
    expectNoOffenses("""      a = "a"
      b = "b"
      if a == "a" || b == "b"
        print a
      end
""".stripIndent)
  test """does not register an offense for comparing lvars when a string is on the lefthand side""":
    expectNoOffenses("""      a = "a"
      b = "b"
      if a == "a" || "b" == b
        print a
      end
""".stripIndent)
  test "does not register an offense for a == b || b == a":
    expectNoOffenses("""      a = "a"
      b = "b"
      if a == b || b == a
        print a
      end
""".stripIndent)
  test "does not register an offense for a duplicated condition":
    expectNoOffenses("""      a = "a"
      b = "b"
      if a == b || a == b
        print a
      end
""".stripIndent)
  test "does not register an offense for Array#include?":
    expectNoOffenses("""      a = "a"
      if ["a", "b", "c"].include? a
        print a
      end
""".stripIndent)
