
import
  identical_conditional_branches, test_tools

suite "IdenticalConditionalBranches":
  var cop = IdenticalConditionalBranches()
  context("on if..else with identical bodies", proc (): void =
    test "registers an offense":
      expectOffense("""        if something
          do_x
          ^^^^ Move `do_x` out of the conditional.
        else
          do_x
          ^^^^ Move `do_x` out of the conditional.
        end
""".stripIndent))
  context("on if..else with identical trailing lines", proc (): void =
    test "registers an offense":
      expectOffense("""        if something
          method_call_here(1, 2, 3)
          do_x
          ^^^^ Move `do_x` out of the conditional.
        else
          1 + 2 + 3
          do_x
          ^^^^ Move `do_x` out of the conditional.
        end
""".stripIndent))
  context("on if..else with identical leading lines", proc (): void =
    test "registers an offense":
      expectOffense("""        if something
          do_x
          ^^^^ Move `do_x` out of the conditional.
          method_call_here(1, 2, 3)
        else
          do_x
          ^^^^ Move `do_x` out of the conditional.
          1 + 2 + 3
        end
""".stripIndent))
  context("on if..elsif with no else", proc (): void =
    test "doesn\'t register an offense":
      expectNoOffenses("""        if something
          do_x
        elsif something_else
          do_x
        end
""".stripIndent))
  context("on if..else with slightly different trailing lines", proc (): void =
    test "doesn\'t register an offense":
      expectNoOffenses("""        if something
          do_x(1)
        else
          do_x(2)
        end
""".stripIndent))
  context("on case with identical bodies", proc (): void =
    test "registers an offense":
      expectOffense("""        case something
        when :a
          do_x
          ^^^^ Move `do_x` out of the conditional.
        when :b
          do_x
          ^^^^ Move `do_x` out of the conditional.
        else
          do_x
          ^^^^ Move `do_x` out of the conditional.
        end
""".stripIndent))
  context("when one of the case branches is empty", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        case value
        when cond1
        else
          if cond2
          else
          end
        end
""".stripIndent))
  context("on case with identical trailing lines", proc (): void =
    test "registers an offense":
      expectOffense("""        case something
        when :a
          x1
          do_x
          ^^^^ Move `do_x` out of the conditional.
        when :b
          x2
          do_x
          ^^^^ Move `do_x` out of the conditional.
        else
          x3
          do_x
          ^^^^ Move `do_x` out of the conditional.
        end
""".stripIndent))
  context("on case with identical leading lines", proc (): void =
    test "registers an offense":
      expectOffense("""        case something
        when :a
          do_x
          ^^^^ Move `do_x` out of the conditional.
          x1
        when :b
          do_x
          ^^^^ Move `do_x` out of the conditional.
          x2
        else
          do_x
          ^^^^ Move `do_x` out of the conditional.
          x3
        end
""".stripIndent))
  context("on case without else", proc (): void =
    test "doesn\'t register an offense":
      expectNoOffenses("""        case something
        when :a
          do_x
        when :b
          do_x
        end
""".stripIndent))
  context("on case with empty when", proc (): void =
    test "doesn\'t register an offense":
      expectNoOffenses("""        case something
        when :a
          do_x
          do_y
        when :b
        else
          do_x
          do_z
        end
""".stripIndent))
