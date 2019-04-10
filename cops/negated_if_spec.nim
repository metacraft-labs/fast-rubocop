
import
  negated_if, test_tools

suite "NegatedIf":
  var cop = NegatedIf()
  describe("with “both” style", proc (): void =
    test "registers an offense for if with exclamation point condition":
      expectOffense("""        if !a_condition
        ^^^^^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
          some_method
        end
        some_method if !a_condition
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
""".stripIndent)
    test "registers an offense for unless with exclamation point condition":
      expectOffense("""        unless !a_condition
        ^^^^^^^^^^^^^^^^^^^ Favor `if` over `unless` for negative conditions.
          some_method
        end
        some_method unless !a_condition
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `if` over `unless` for negative conditions.
""".stripIndent)
    test "registers an offense for if with \"not\" condition":
      expectOffense("""        if not a_condition
        ^^^^^^^^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
          some_method
        end
        some_method if not a_condition
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
""".stripIndent)
    test "accepts an if/else with negative condition":
      expectNoOffenses("""        if !a_condition
          some_method
        else
          something_else
        end
        if not a_condition
          some_method
        elsif other_condition
          something_else
        end
""".stripIndent)
    test "accepts an if where only part of the condition is negated":
      expectNoOffenses("""        if !condition && another_condition
          some_method
        end
        if not condition or another_condition
          some_method
        end
        some_method if not condition or another_condition
""".stripIndent)
    test "accepts an if where the condition is doubly negated":
      expectNoOffenses("""        if !!condition
          some_method
        end
        some_method if !!condition
""".stripIndent)
    test "is not confused by negated elsif":
      expectNoOffenses("""        if test.is_a?(String)
          3
        elsif test.is_a?(Array)
          2
        elsif !test.nil?
          1
        end
""".stripIndent)
    test "autocorrects for postfix":
      var corrected = autocorrectSource("bar if !foo")
      expect(corrected).to(eq("bar unless foo"))
    test "autocorrects by replacing if not with unless":
      var corrected = autocorrectSource("something if !x.even?")
      expect(corrected).to(eq("something unless x.even?"))
    test "autocorrects by replacing parenthesized if not with unless":
      var corrected = autocorrectSource("something if (!x.even?)")
      expect(corrected).to(eq("something unless (x.even?)"))
    test "autocorrects by replacing unless not with if":
      var corrected = autocorrectSource("something unless !x.even?")
      expect(corrected).to(eq("something if x.even?"))
    test "autocorrects for prefix":
      var corrected = autocorrectSource("""        if !foo
        end
""".stripIndent)
      expect(corrected).to(eq("""        unless foo
        end
""".stripIndent)))
  describe("with “prefix” style", proc (): void =
    var cop = NegatedIf()
    test "registers an offense for prefix":
      expectOffense("""        if !foo
        ^^^^^^^ Favor `unless` over `if` for negative conditions.
        end
""".stripIndent)
    test "does not register an offense for postfix":
      expectNoOffenses("foo if !bar")
    test "autocorrects for prefix":
      var corrected = autocorrectSource("""        if !foo
        end
""".stripIndent)
      expect(corrected).to(eq("""        unless foo
        end
""".stripIndent)))
  describe("with “postfix” style", proc (): void =
    var cop = NegatedIf()
    test "registers an offense for postfix":
      expectOffense("""        foo if !bar
        ^^^^^^^^^^^ Favor `unless` over `if` for negative conditions.
""".stripIndent)
    test "does not register an offense for prefix":
      expectNoOffenses("""        if !foo
        end
""".stripIndent)
    test "autocorrects for postfix":
      var corrected = autocorrectSource("bar if !foo")
      expect(corrected).to(eq("bar unless foo")))
  test "does not blow up for ternary ops":
    expectNoOffenses("a ? b : c")
  test "does not blow up on a negated ternary operator":
    expectNoOffenses("!foo.empty? ? :bar : :baz")
  test "does not blow up for empty if condition":
    expectNoOffenses("""      if ()
      end
""".stripIndent)
  test "does not blow up for empty unless condition":
    expectNoOffenses("""      unless ()
      end
""".stripIndent)
