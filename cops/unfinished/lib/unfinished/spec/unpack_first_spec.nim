
import
  unpack_first, test_tools

RSpec.describe(UnpackFirst, "config", proc (): void =
  var cop = ()
  context("ruby version >= 2.4", "ruby24", proc (): void =
    context("registers offense", proc (): void =
      test "when using `#unpack` with `#first`":
        expectOffense("""        x.unpack('h*').first
        ^^^^^^^^^^^^^^^^^^^^ Use `x.unpack1('h*')` instead of `x.unpack('h*').first`.
""".stripIndent)
      test "when using `#unpack` with square brackets":
        expectOffense("""        ''.unpack(y)[0]
        ^^^^^^^^^^^^^^^ Use `''.unpack1(y)` instead of `''.unpack(y)[0]`.
""".stripIndent)
      test "when using `#unpack` with dot and square brackets":
        expectOffense("""        ''.unpack(y).[](0)
        ^^^^^^^^^^^^^^^^^^ Use `''.unpack1(y)` instead of `''.unpack(y).[](0)`.
""".stripIndent)
      test "when using `#unpack` with `#slice`":
        expectOffense("""        ''.unpack(y).slice(0)
        ^^^^^^^^^^^^^^^^^^^^^ Use `''.unpack1(y)` instead of `''.unpack(y).slice(0)`.
""".stripIndent)
      test "when using `#unpack` with `#at`":
        expectOffense("""        ''.unpack(y).at(0)
        ^^^^^^^^^^^^^^^^^^ Use `''.unpack1(y)` instead of `''.unpack(y).at(0)`.
""".stripIndent))
    context("does not register offense", proc (): void =
      test "when using `#unpack1`":
        expectNoOffenses("          x.unpack1(y)\n".stripIndent)
      test "when using `#unpack` accessing second element":
        expectNoOffenses("          \'\'.unpack(\'h*\')[1]\n".stripIndent))
    context("autocorrects", proc (): void =
      test "`#unpack` with `#first to `#unpack1`":
        expect(autocorrectSource("x.unpack(\'h*\').first")).to(
            eq("x.unpack1(\'h*\')"))
      test "autocorrects `#unpack` with square brackets":
        expect(autocorrectSource("x.unpack(\'h*\')[0]")).to(
            eq("x.unpack1(\'h*\')"))
      test "autocorrects `#unpack` with dot and square brackets":
        expect(autocorrectSource("x.unpack(\'h*\').[](0)")).to(
            eq("x.unpack1(\'h*\')"))
      test "autocorrects `#unpack` with `#slice`":
        expect(autocorrectSource("x.unpack(\'h*\').slice(0)")).to(
            eq("x.unpack1(\'h*\')"))
      test "autocorrects `#unpack` with `#at`":
        expect(autocorrectSource("x.unpack(\'h*\').at(0)")).to(
            eq("x.unpack1(\'h*\')")))))
