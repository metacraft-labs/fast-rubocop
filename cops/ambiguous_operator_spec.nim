
import
  ambiguous_operator, test_tools

suite "AmbiguousOperator":
  var cop = AmbiguousOperator()
  context("with a splat operator in the first argument", proc (): void =
    context("without parentheses", proc (): void =
      context("without whitespaces on the right of the operator", proc (): void =
        test "registers an offense":
          expectOffense("""            array = [1, 2, 3]
            puts *array
                 ^ Ambiguous splat operator. Parenthesize the method arguments if it's surely a splat operator, or add a whitespace to the right of the `*` if it should be a multiplication.
""".stripIndent))
      context("with a whitespace on the right of the operator", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            array = [1, 2, 3]
            puts * array
""".stripIndent)))
    context("with parentheses around the splatted argument", proc (): void =
      test "does not register an offense":
        expectNoOffenses("""          array = [1, 2, 3]
          puts(*array)
""".stripIndent)))
  context("with a block ampersand in the first argument", proc (): void =
    context("without parentheses", proc (): void =
      context("without whitespaces on the right of the operator", proc (): void =
        test "registers an offense":
          expectOffense("""            process = proc { do_something }
            2.times &process
                    ^ Ambiguous block operator. Parenthesize the method arguments if it's surely a block operator, or add a whitespace to the right of the `&` if it should be a binary AND.
""".stripIndent))
      context("with a whitespace on the right of the operator", proc (): void =
        test "does not register an offense":
          expectNoOffenses("""            process = proc { do_something }
            2.times & process
""".stripIndent)))
    context("with parentheses around the block argument", proc (): void =
      test "does not register an offense":
        expectNoOffenses("""          process = proc { do_something }
          2.times(&process)
""".stripIndent)))
