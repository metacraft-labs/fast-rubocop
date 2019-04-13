
import
  unless_else, test_tools

suite "UnlessElse":
  var cop = UnlessElse()
  context("unless with else", proc (): void =
    test "registers an offense":
      expectOffense("""        unless x # negative 1
        ^^^^^^^^^^^^^^^^^^^^^ Do not use `unless` with `else`. Rewrite these with the positive case first.
          a = 1 # negative 2
        else # positive 1
          a = 0 # positive 2
        end
""".stripIndent)
      expectCorrection("""        if x # positive 1
          a = 0 # positive 2
        else # negative 1
          a = 1 # negative 2
        end
""".stripIndent))
  context("unless with nested if-else", proc (): void =
    test "registers an offense":
      expectOffense("""        unless(x)
        ^^^^^^^^^ Do not use `unless` with `else`. Rewrite these with the positive case first.
          if(y == 0)
            a = 0
          elsif(z == 0)
            a = 1
          else
            a = 2
          end
        else
          a = 3
        end
""".stripIndent)
      expectCorrection("""        if(x)
          a = 3
        else
          if(y == 0)
            a = 0
          elsif(z == 0)
            a = 1
          else
            a = 2
          end
        end
""".stripIndent))
  context("unless without else", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        unless x
          a = 1
        end
""".stripIndent))
