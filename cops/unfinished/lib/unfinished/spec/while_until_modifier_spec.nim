
import
  statementModifierHelper

import
  while_until_modifier, test_tools

suite "WhileUntilModifier":
  var cop = WhileUntilModifier()
  let("config", proc (): void =
    Config.new())
  test "accepts multiline unless that doesn\'t fit on one line":
    checkTooLong("unless")
  test "accepts multiline unless whose body is more than one line":
    checkShortMultiline("unless")
  context("multiline while that fits on one line", proc (): void =
    test "registers an offense":
      checkReallyShort("while")
    test "does auto-correction":
      autocorrectReallyShort("while"))
  test "accepts multiline while that doesn\'t fit on one line":
    checkTooLong("while")
  test "accepts multiline while whose body is more than one line":
    checkShortMultiline("while")
  test "accepts oneline while when condition has local variable assignment":
    expectNoOffenses("""      lines = %w{first second third}
      while (line = lines.shift)
        puts line
      end
""".stripIndent)
  context("oneline while when assignment is in body", proc (): void =
    let("source", proc (): void =
      """        while true
          x = 0
        end
""".stripIndent)
    test "registers an offense":
      expectOffense("""        while true
        ^^^^^ Favor modifier `while` usage when having a single-line body.
          x = 0
        end
""".stripIndent)
    test "does auto-correction":
      var corrected = autocorrectSource(source())
      expect(corrected).to(eq("x = 0 while true\n")))
  context("multiline until that fits on one line", proc (): void =
    test "registers an offense":
      checkReallyShort("until")
    test "does auto-correction":
      autocorrectReallyShort("until"))
  test "accepts multiline until that doesn\'t fit on one line":
    checkTooLong("until")
  test "accepts multiline until whose body is more than one line":
    checkShortMultiline("until")
  test "accepts an empty condition":
    checkEmpty("while")
    checkEmpty("until")
  test "accepts modifier while":
    expectNoOffenses("ala while bala")
  test "accepts modifier until":
    expectNoOffenses("ala until bala")
  context("when the modifier condition is multiline", proc (): void =
    test "registers an offense":
      expectOffense("""        foo while bar ||
            ^^^^^ Favor modifier `while` usage when having a single-line body.
          baz
""".stripIndent))
  context("when Metrics/LineLength is disabled", proc (): void =
    let("config", proc (): void =
      Config.new())
    test "registers an offense even for a long modifier statement":
      expectOffense("""        while foo
        ^^^^^ Favor modifier `while` usage when having a single-line body.
          "This string would make the line longer than eighty characters if combined with the statement." 
        end
""".stripIndent))
