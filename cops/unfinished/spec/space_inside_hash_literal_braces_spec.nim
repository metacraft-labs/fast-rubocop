
import
  space_inside_hash_literal_braces, test_tools

RSpec.describe(SpaceInsideHashLiteralBraces, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"EnforcedStyle": "space"}.newTable())
  context("with space inside empty braces not allowed", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyleForEmptyBraces": "no_space"}.newTable())
    test "accepts empty braces with no space inside":
      expectNoOffenses("h = {}")
    test "registers an offense for empty braces with space inside":
      expectOffense("""        h = { }
             ^ Space inside empty hash literal braces detected.
""".stripIndent)
    test "auto-corrects unwanted space":
      var newSource = autocorrectSource("h = { }")
      expect(newSource).to(eq("h = {}")))
  context("with space inside empty braces allowed", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyleForEmptyBraces": "space"}.newTable())
    test "accepts empty braces with space inside":
      expectNoOffenses("h = { }")
    test "registers an offense for empty braces with no space inside":
      expectOffense("""        h = {}
            ^ Space inside empty hash literal braces missing.
""".stripIndent)
    test "auto-corrects missing space":
      var newSource = autocorrectSource("h = {}")
      expect(newSource).to(eq("h = { }")))
  test "registers an offense for hashes with no spaces if so configured":
    expectOffense("""      h = {a: 1, b: 2}
          ^ Space inside { missing.
                     ^ Space inside } missing.
      h = {a => 1}
          ^ Space inside { missing.
                 ^ Space inside } missing.
""".stripIndent)
  test "registers an offense for correct + opposite":
    expectOffense("""      h = { a: 1}
                ^ Space inside } missing.
""".stripIndent)
  test "auto-corrects missing space":
    var newSource = autocorrectSource("""      h = {a: 1, b: 2}
      h = {a => 1 }
""".stripIndent)
    expect(newSource).to(eq("""      h = { a: 1, b: 2 }
      h = { a => 1 }
""".stripIndent))
  context("when EnforcedStyle is no_space", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "no_space"}.newTable())
    test "registers an offense for hashes with spaces":
      expectOffense("""        h = { a: 1, b: 2 }
             ^ Space inside { detected.
                        ^ Space inside } detected.
""".stripIndent)
    test "registers an offense for opposite + correct":
      expectOffense("""        h = {a: 1 }
                 ^ Space inside } detected.
""".stripIndent)
    test "auto-corrects unwanted space":
      var newSource = autocorrectSource("""        h = { a: 1, b: 2 }
        h = {a => 1 }
""".stripIndent)
      expect(newSource).to(eq("""        h = {a: 1, b: 2}
        h = {a => 1}
""".stripIndent))
    test "accepts hashes with no spaces":
      expectNoOffenses("""        h = {a: 1, b: 2}
        h = {a => 1}
""".stripIndent)
    test "accepts multiline hash":
      expectNoOffenses("""        h = {
              a: 1,
              b: 2,
        }
""".stripIndent)
    test "accepts multiline hash with comment":
      expectNoOffenses("""        h = { # Comment
              a: 1,
              b: 2,
        }
""".stripIndent))
  context("when EnforcedStyle is compact", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "compact"}.newTable())
    test "doesn\'t register an offense for non-nested hashes with spaces":
      expectNoOffenses("        h = { a: 1, b: 2 }\n".stripIndent)
    test "registers an offense for nested hashes with spaces":
      expectOffense("""        h = { a: { a: 1, b: 2 } }
                               ^ Space inside } detected.
""".stripIndent)
    test "registers an offense for opposite + correct":
      expectOffense("""        h = {a: 1 }
            ^ Space inside { missing.
""".stripIndent)
    test "auto-corrects hashes with no space":
      var newSource = autocorrectSource("""        h = {a: 1, b: 2}
        h = {a => 1 }
""".stripIndent)
      expect(newSource).to(eq("""        h = { a: 1, b: 2 }
        h = { a => 1 }
""".stripIndent))
    test "auto-corrects nested hashes with spaces":
      var newSource = autocorrectSource("""        h = { a: { a: 1, b: 2 } }
        h = {a => method { 1 } }
""".stripIndent)
      expect(newSource).to(eq("""        h = { a: { a: 1, b: 2 }}
        h = { a => method { 1 }}
""".stripIndent))
    test "registers offenses for hashes with no spaces":
      expectOffense("""        h = {a: 1, b: 2}
                       ^ Space inside } missing.
            ^ Space inside { missing.
        h = {a => 1}
                   ^ Space inside } missing.
            ^ Space inside { missing.
""".stripIndent)
    test "accepts multiline hash":
      expectNoOffenses("""        h = {
              a: 1,
              b: 2,
        }
""".stripIndent)
    test "accepts multiline hash with comment":
      expectNoOffenses("""        h = { # Comment
              a: 1,
              b: 2,
        }
""".stripIndent))
  test "accepts hashes with spaces by default":
    expectNoOffenses("""      h = { a: 1, b: 2 }
      h = { a => 1 }
""".stripIndent)
  test "accepts hash literals with no braces":
    expectNoOffenses("x(a: b.c)")
  test "can handle interpolation in a braceless hash literal":
    expectNoOffenses("f(get: \"#{x}\")")
  context("on Hash[{ x: 1 } => [1]]", proc (): void =
    test "does not register an offense":
      expectNoOffenses("Hash[{ x: 1 } => [1]]"))
  context("on { key: \"{\" }", proc (): void =
    test "does not register an offense":
      expectNoOffenses("{ key: \"{\" }")))
