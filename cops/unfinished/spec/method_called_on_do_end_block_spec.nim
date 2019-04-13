
import
  method_called_on_do_end_block, test_tools

suite "MethodCalledOnDoEndBlock":
  var cop = MethodCalledOnDoEndBlock()
  context("with a multi-line do..end block", proc (): void =
    test "registers an offense for a chained call":
      expectOffense("""        a do
          b
        end.c
        ^^^^^ Avoid chaining a method call on a do...end block.
""".stripIndent)
    context("when using safe navigation operator", "ruby23", proc (): void =
      test "registers an offense for a chained call":
        expectOffense("""        a do
          b
        end&.c
        ^^^^^^ Avoid chaining a method call on a do...end block.
""".stripIndent))
    test "accepts it if there is no chained call":
      expectNoOffenses("""        a do
          b
        end
""".stripIndent)
    test "accepts a chained block":
      expectNoOffenses("""        a do
          b
        end.c do
          d
        end
""".stripIndent))
  context("with a single-line do..end block", proc (): void =
    test "registers an offense for a chained call":
      expectOffense("""        a do b end.c
               ^^^^^ Avoid chaining a method call on a do...end block.
""".stripIndent)
    test "accepts a single-line do..end block with a chained block":
      expectNoOffenses("a do b end.c do d end"))
  context("with a {} block", proc (): void =
    test "accepts a multi-line block with a chained call":
      expectNoOffenses("""        a {
          b
        }.c
""".stripIndent)
    test "accepts a single-line block with a chained call":
      expectNoOffenses("a { b }.c"))
