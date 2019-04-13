
import
  float_out_of_range, test_tools

suite "FloatOutOfRange":
  var cop = FloatOutOfRange()
  test "does not register an offense for 0.0":
    expectNoOffenses("0.0")
  test "does not register an offense for tiny little itty bitty floats":
    expectNoOffenses("1.1e-100")
  test "does not register an offense for respectably sized floats":
    expectNoOffenses("55.7e89")
  context("on whopping big floats which tip the scales", proc (): void =
    test "registers an offense":
      expectOffense("""        9.9999e999
        ^^^^^^^^^^ Float out of range.
""".stripIndent))
  context("on floats so close to zero that nobody can tell the difference", proc (): void =
    test "registers an offense":
      expectOffense("""        1.0e-400
        ^^^^^^^^ Float out of range.
""".stripIndent))
