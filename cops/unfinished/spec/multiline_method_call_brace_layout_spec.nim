
import
  multiline_method_call_brace_layout, test_tools

RSpec.describe(MultilineMethodCallBraceLayout, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"EnforcedStyle": "symmetrical"}.newTable())
  test "ignores implicit calls":
    expectNoOffenses("""      foo 1,
      2
""".stripIndent)
  test "ignores single-line calls":
    expectNoOffenses("foo(1,2)")
  test "ignores calls without arguments":
    expectNoOffenses("puts")
  test "ignores calls with an empty brace":
    expectNoOffenses("puts()")
  test "ignores calls with a multiline empty brace ":
    expectNoOffenses("""      puts(
      )
""".stripIndent)
  itBehavesLike("multiline literal brace layout", proc (): void =
    let("open", proc (): void =
      "foo(")
    let("close", proc (): void =
      ")"))
  itBehavesLike("multiline literal brace layout trailing comma", proc (): void =
    let("open", proc (): void =
      "foo(")
    let("close", proc (): void =
      ")"))
  context("when EnforcedStyle is new_line", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "new_line"}.newTable())
    test "still ignores single-line calls":
      expectNoOffenses("puts(\"Hello world!\")")
    test "ignores single-line calls with multi-line receiver":
      expectNoOffenses("""        [
        ].join(" ")
""".stripIndent)
    test "ignores single-line calls with multi-line receiver with leading dot":
      expectNoOffenses("""        [
        ]
        .join(" ")
""".stripIndent)))
