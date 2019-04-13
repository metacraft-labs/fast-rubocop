
import
  ascii_comments, test_tools

suite "AsciiComments":
  var cop = AsciiComments()
  test "registers an offense for a comment with non-ascii chars":
    expectOffense("""      # 这是什么？
        ^^^^^ Use only ascii symbols in comments.
""".stripIndent)
  test "registers an offense for comments with mixed chars":
    expectOffense("""      # foo ∂ bar
            ^ Use only ascii symbols in comments.
""".stripIndent)
  test "accepts comments with only ascii chars":
    expectNoOffenses("# AZaz1@$%~,;*_`|")
  context("when certain non-ascii chars are allowed", "config", proc (): void =
    var cop = AsciiComments()
    let("cop_config", proc (): void =
      {"AllowedChars": @["∂"]}.newTable())
    test "accepts comment with allowed non-ascii chars":
      expectNoOffenses("# foo ∂ bar")
    test "registers an offense for comments with non-allowed non-ascii chars":
      expectOffense("""        # 这是什么？
          ^^^^^ Use only ascii symbols in comments.
""".stripIndent))
