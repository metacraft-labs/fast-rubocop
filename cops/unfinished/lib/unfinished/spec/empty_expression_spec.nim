
import
  empty_expression, test_tools

suite "EmptyExpression":
  var cop = EmptyExpression()
  context("when used as a standalone expression", proc (): void =
    test "registers an offense":
      expectOffense("""        ()
        ^^ Avoid empty expressions.
""".stripIndent)
    context("with nested empty expressions", proc (): void =
      test "registers an offense":
        expectOffense("""          (())
           ^^ Avoid empty expressions.
""".stripIndent)))
  context("when used in a condition", proc (): void =
    test "registers an offense inside `if`":
      expectOffense("""        if (); end
           ^^ Avoid empty expressions.
""".stripIndent)
    test "registers an offense inside `elseif`":
      expectOffense("""        if foo
          1
        elsif ()
              ^^ Avoid empty expressions.
          2
        end
""".stripIndent)
    test "registers an offense inside `case`":
      expectOffense("""        case ()
             ^^ Avoid empty expressions.
        when :foo then 1
        end
""".stripIndent)
    test "registers an offense inside `when`":
      expectOffense("""        case foo
        when () then 1
             ^^ Avoid empty expressions.
        end
""".stripIndent)
    test "registers an offense in the condition of a ternary operator":
      expectOffense("""        () ? true : false
        ^^ Avoid empty expressions.
""".stripIndent)
    test "registers an offense in the return value of a ternary operator":
      expectOffense("""        foo ? () : bar
              ^^ Avoid empty expressions.
""".stripIndent))
  context("when used as a return value", proc (): void =
    test "registers an offense in the return value of a method":
      expectOffense("""        def foo
          ()
          ^^ Avoid empty expressions.
        end
""".stripIndent)
    test "registers an offense in the return value of a condition":
      expectOffense("""        if foo
          ()
          ^^ Avoid empty expressions.
        end
""".stripIndent)
    test "registers an offense in the return value of a case statement":
      expectOffense("""        case foo
        when :bar then ()
                       ^^ Avoid empty expressions.
        end
""".stripIndent))
  context("when used as an assignment", proc (): void =
    test "registers an offense for the assigned value":
      expectOffense("""        foo = ()
              ^^ Avoid empty expressions.
""".stripIndent))
