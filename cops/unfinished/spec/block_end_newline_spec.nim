
import
  block_end_newline, test_tools

suite "BlockEndNewline":
  var cop = BlockEndNewline()
  test "accepts a one-liner":
    expectNoOffenses("test do foo end")
  test "accepts multiline blocks with newlines before the end":
    expectNoOffenses("""      test do
        foo
      end
""".stripIndent)
  test "registers an offense when multiline block end is not on its own line":
    expectOffense("""      test do
        foo end
            ^^^ Expression at 2, 7 should be on its own line.
""".stripIndent)
  test "registers an offense when multiline block } is not on its own line":
    expectOffense("""      test {
        foo }
            ^ Expression at 2, 7 should be on its own line.
""".stripIndent)
  test "autocorrects a do/end block where the end is not on its own line":
    var newSource = autocorrectSource("""      test do
        foo  end
""".stripIndent)
    expect(newSource).to(eq("""      test do
        foo
      end
""".stripIndent))
  test "autocorrects a {} block where the } is not on its own line":
    var newSource = autocorrectSource("""      test {
        foo  }
""".stripIndent)
    expect(newSource).to(eq("""      test {
        foo
      }
""".stripIndent))
  test """autocorrects a {} block where the } is top level code outside of a class""":
    var newSource = autocorrectSource("""      # frozen_string_literal: true

      test {[
        foo
      ]}
""".stripIndent)
    expect(newSource).to(eq("""      # frozen_string_literal: true

      test {[
        foo
      ]
      }
""".stripIndent))
