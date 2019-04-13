
import
  tables

import
  empty_lines_around_block_body, test_tools

RSpec.describe(EmptyLinesAroundBlockBody, "config", proc (): void =
  var cop = ()
  for open, close in @[@["{", "}"], @["do", "end"]]:
    context("""when EnforcedStyle is no_empty_lines for (lvar :open) (lvar :close) block""", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyle": "no_empty_lines"}.newTable())
      test "registers an offense for block body starting with a blank":
        inspectSource("""          some_method (lvar :open)

            do_something
          (lvar :close)
""".stripIndent)
        expect(cop().messages).to(eq(@["Extra empty line detected at block body beginning."]))
      test "autocorrects block body containing only a blank":
        var corrected = autocorrectSource("""          some_method (lvar :open)

          (lvar :close)
""".stripIndent)
        expect(corrected).to(eq("""          some_method (lvar :open)
          (lvar :close)
""".stripIndent))
      test "registers an offense for block body ending with a blank":
        inspectSource("""          some_method (lvar :open)
            do_something

            (lvar :close)
""".stripIndent)
        expect(cop().messages).to(eq(@["Extra empty line detected at block body end."]))
      test "accepts block body starting with a line with spaces":
        expectNoOffenses("""          some_method (lvar :open)
            
            do_something
          (lvar :close)
""".stripIndent)
      test "is not fooled by single line blocks":
        expectNoOffenses("""          some_method (lvar :open) do_something (lvar :close)

          something_else
""".stripIndent))
    context("""when EnforcedStyle is empty_lines for (lvar :open) (lvar :close) block""", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyle": "empty_lines"}.newTable())
      test """registers an offense for block body not starting or ending with a blank""":
        inspectSource("""          some_method (lvar :open)
            do_something
          (lvar :close)
""".stripIndent)
        expect(cop().messages).to(eq(("""Empty line missing at block body beginning.""",
                                      "Empty line missing at block body end.")))
      test "ignores block with an empty body":
        var
          source = """some_method (lvar :open)
(lvar :close)"""
          corrected = autocorrectSource(source)
        expect(corrected).to(eq(source))
      test "autocorrects beginning and end":
        var newSource = autocorrectSource("""          some_method (lvar :open)
            do_something
          (lvar :close)
""".stripIndent)
        expect(newSource).to(eq("""          some_method (lvar :open)

            do_something

          (lvar :close)
""".stripIndent))
      test "is not fooled by single line blocks":
        expectNoOffenses("""          some_method (lvar :open) do_something (lvar :close)
          something_else
""".stripIndent)))
