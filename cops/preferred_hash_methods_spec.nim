
import
  preferred_hash_methods, test_tools

RSpec.describe(PreferredHashMethods, "config", proc (): void =
  var cop = ()
  context("with enforced `short` style", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "short"}.newTable())
    test "registers an offense for has_key? with one arg":
      expectOffense("""        o.has_key?(o)
          ^^^^^^^^ Use `Hash#key?` instead of `Hash#has_key?`.
""".stripIndent)
      expectCorrection("        o.key?(o)\n".stripIndent)
    test "accepts has_key? with no args":
      expectNoOffenses("o.has_key?")
    test "registers an offense for has_value? with one arg":
      expectOffense("""        o.has_value?(o)
          ^^^^^^^^^^ Use `Hash#value?` instead of `Hash#has_value?`.
""".stripIndent)
      expectCorrection("        o.value?(o)\n".stripIndent)
    context("when using safe navigation operator", "ruby23", proc (): void =
      test "registers an offense for has_value? with one arg":
        expectOffense("""          o&.has_value?(o)
             ^^^^^^^^^^ Use `Hash#value?` instead of `Hash#has_value?`.
""".stripIndent)
        expectCorrection("          o&.value?(o)\n".stripIndent))
    test "accepts has_value? with no args":
      expectNoOffenses("o.has_value?"))
  context("with enforced `verbose` style", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "verbose"}.newTable())
    test "registers an offense for key? with one arg":
      expectOffense("""        o.key?(o)
          ^^^^ Use `Hash#has_key?` instead of `Hash#key?`.
""".stripIndent)
      expectCorrection("        o.has_key?(o)\n".stripIndent)
    test "accepts key? with no args":
      expectNoOffenses("o.key?")
    test "registers an offense for value? with one arg":
      expectOffense("""        o.value?(o)
          ^^^^^^ Use `Hash#has_value?` instead of `Hash#value?`.
""".stripIndent)
      expectCorrection("        o.has_value?(o)\n".stripIndent)
    test "accepts value? with no args":
      expectNoOffenses("o.value?")))
