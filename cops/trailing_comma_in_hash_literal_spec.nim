
import
  trailing_comma_in_hash_literal, test_tools

RSpec.describe(TrailingCommaInHashLiteral, "config", proc (): void =
  var cop = ()
  sharedExamples("single line lists", proc (extraInfo: string): void =
    test "registers an offense for trailing comma in a literal":
      expectOffense("""        MAP = { a: 1001, b: 2020, c: 3333, }
                                         ^ Avoid comma after the last item of a hash(lvar :extra_info).
""".stripIndent)
    test "accepts literal without trailing comma":
      expectNoOffenses("MAP = { a: 1001, b: 2020, c: 3333 }")
    test "accepts single element literal without trailing comma":
      expectNoOffenses("MAP = { a: 10001 }")
    test "accepts empty literal":
      expectNoOffenses("MAP = {}")
    test "auto-corrects unwanted comma in literal":
      var newSource = autocorrectSource("MAP = { a: 1001, b: 2020, c: 3333, }")
      expect(newSource).to(eq("MAP = { a: 1001, b: 2020, c: 3333 }")))
  context("with single line list of values", proc (): void =
    context("when EnforcedStyleForMultiline is no_comma", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyleForMultiline": "no_comma"}.newTable())
      includeExamples("single line lists", ""))
    context("when EnforcedStyleForMultiline is comma", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyleForMultiline": "comma"}.newTable())
      includeExamples("single line lists",
                      ", unless each item is on its own line"))
    context("when EnforcedStyleForMultiline is consistent_comma", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyleForMultiline": "consistent_comma"}.newTable())
      includeExamples("single line lists",
                      ", unless items are split onto multiple lines")))
  context("with multi-line list of values", proc (): void =
    context("when EnforcedStyleForMultiline is no_comma", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyleForMultiline": "no_comma"}.newTable())
      test "registers an offense for trailing comma in literal":
        expectOffense("""          MAP = { a: 1001,
                  b: 2020,
                  c: 3333,
                         ^ Avoid comma after the last item of a hash.
                }
""".stripIndent)
      test "accepts literal with no trailing comma":
        expectNoOffenses("""          MAP = {
                  a: 1001,
                  b: 2020,
                  c: 3333
                }
""".stripIndent)
      test "accepts comma inside a heredoc parameters at the end":
        expectNoOffenses("""          route(help: {
            'auth' => <<-HELP.chomp
          ,
          HELP
          })
""".stripIndent)
      test "accepts comma in comment after last value item":
        expectNoOffenses("""          {
            foo: 'foo',
            bar: 'bar'.delete(',')#,
          }
""".stripIndent)
      test "auto-corrects unwanted comma in literal":
        var newSource = autocorrectSource("""          MAP = { a: 1001,
                  b: 2020,
                  c: 3333,
                }
""".stripIndent)
        expect(newSource).to(eq("""          MAP = { a: 1001,
                  b: 2020,
                  c: 3333
                }
""".stripIndent)))
    context("when EnforcedStyleForMultiline is comma", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyleForMultiline": "comma"}.newTable())
      context("when closing bracket is on same line as last value", proc (): void =
        test "accepts literal with no trailing comma":
          expectNoOffenses("""            VALUES = {
                       a: "b",
                       c: "d",
                       e: "f"}
""".stripIndent))
      test "registers an offense for no trailing comma":
        expectOffense("""          MAP = { a: 1001,
                  b: 2020,
                  c: 3333
                  ^^^^^^^ Put a comma after the last item of a multiline hash.
          }
""".stripIndent)
      test "registers an offense for trailing comma in a comment":
        expectOffense("""          MAP = { a: 1001,
                  b: 2020,
                  c: 3333 # a comment,
                  ^^^^^^^ Put a comma after the last item of a multiline hash.
          }
""".stripIndent)
      test "accepts trailing comma":
        expectNoOffenses("""          MAP = {
                  a: 1001,
                  b: 2020,
                  c: 3333,
                }
""".stripIndent)
      test "accepts trailing comma after a heredoc":
        expectNoOffenses("""          route(help: {
            'auth' => <<-HELP.chomp,
          ...
          HELP
          })
""".stripIndent)
      test "auto-corrects missing comma":
        var newSource = autocorrectSource("""          MAP = { a: 1001,
                  b: 2020,
                  c: 3333
          }
""".stripIndent)
        expect(newSource).to(eq("""          MAP = { a: 1001,
                  b: 2020,
                  c: 3333,
          }
""".stripIndent))
      test "accepts a multiline hash with a single pair and trailing comma":
        expectNoOffenses("""          bar = {
            a: 123,
          }
""".stripIndent))
    context("when EnforcedStyleForMultiline is consistent_comma", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyleForMultiline": "consistent_comma"}.newTable())
      context("when closing bracket is on same line as last value", proc (): void =
        test "registers an offense for literal with no trailing comma":
          expectOffense("""            VALUES = {
                       a: "b",
                       b: "c",
                       d: "e"}
                       ^^^^^^ Put a comma after the last item of a multiline hash.
""".stripIndent)
        test "auto-corrects a missing comma":
          var newSource = autocorrectSource("""            MAP = { a: 1001,
                    b: 2020,
                    c: 3333}
""".stripIndent)
          expect(newSource).to(eq("""            MAP = { a: 1001,
                    b: 2020,
                    c: 3333,}
""".stripIndent)))
      test "registers an offense for no trailing comma":
        expectOffense("""          MAP = { a: 1001,
                  b: 2020,
                  c: 3333
                  ^^^^^^^ Put a comma after the last item of a multiline hash.
          }
""".stripIndent)
      test "accepts trailing comma":
        expectNoOffenses("""          MAP = {
                  a: 1001,
                  b: 2020,
                  c: 3333,
                }
""".stripIndent)
      test "accepts trailing comma after a heredoc":
        expectNoOffenses("""          route(help: {
            'auth' => <<-HELP.chomp,
          ...
          HELP
          })
""".stripIndent)
      test "auto-corrects missing comma":
        var newSource = autocorrectSource("""          MAP = { a: 1001,
                  b: 2020,
                  c: 3333
          }
""".stripIndent)
        expect(newSource).to(eq("""          MAP = { a: 1001,
                  b: 2020,
                  c: 3333,
          }
""".stripIndent))
      test "accepts a multiline hash with a single pair and trailing comma":
        expectNoOffenses("""          bar = {
            a: 123,
          }
""".stripIndent)
      test """accepts a multiline hash with pairs on a single line andtrailing comma""":
        expectNoOffenses("""          bar = {
            a: 1001, b: 2020,
          }
""".stripIndent))))
