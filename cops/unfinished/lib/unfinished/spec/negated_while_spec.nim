
import
  negated_while, test_tools

suite "NegatedWhile":
  var cop = NegatedWhile()
  test "registers an offense for while with exclamation point condition":
    expectOffense("""      while !a_condition
      ^^^^^^^^^^^^^^^^^^ Favor `until` over `while` for negative conditions.
        some_method
      end
      some_method while !a_condition
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `until` over `while` for negative conditions.
""".stripIndent)
  test "registers an offense for until with exclamation point condition":
    expectOffense("""      until !a_condition
      ^^^^^^^^^^^^^^^^^^ Favor `while` over `until` for negative conditions.
        some_method
      end
      some_method until !a_condition
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `while` over `until` for negative conditions.
""".stripIndent)
  test "registers an offense for while with \"not\" condition":
    expectOffense("""      while (not a_condition)
      ^^^^^^^^^^^^^^^^^^^^^^^ Favor `until` over `while` for negative conditions.
        some_method
      end
      some_method while not a_condition
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `until` over `while` for negative conditions.
""".stripIndent)
  test "accepts a while where only part of the condition is negated":
    expectNoOffenses("""      while !a_condition && another_condition
        some_method
      end
      while not a_condition or another_condition
        some_method
      end
      some_method while not a_condition or other_cond
""".stripIndent)
  test "accepts a while where the condition is doubly negated":
    expectNoOffenses("""      while !!a_condition
        some_method
      end
      some_method while !!a_condition
""".stripIndent)
  test "autocorrects by replacing while not with until":
    var corrected = autocorrectSource("""      something while !x.even?
      something while(!x.even?)
""".stripIndent)
    expect(corrected).to(eq("""      something until x.even?
      something until(x.even?)
""".stripIndent))
  test "autocorrects by replacing until not with while":
    var corrected = autocorrectSource("something until !x.even?")
    expect(corrected).to(eq("something while x.even?"))
  test "does not blow up for empty while condition":
    expectNoOffenses("""      while ()
      end
""".stripIndent)
  test "does not blow up for empty until condition":
    expectNoOffenses("""      until ()
      end
""".stripIndent)
