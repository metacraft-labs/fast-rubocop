
import
  trailing_comma_in_array_literal, test_tools

RSpec.describe(TrailingCommaInArrayLiteral, "config", proc (): void =
  var cop = ()
  sharedExamples("single line lists", proc (extraInfo: string): void =
    test "registers an offense for trailing comma":
      expectOffense("""        VALUES = [1001, 2020, 3333, ]
                                  ^ Avoid comma after the last item of an array(lvar :extra_info).
""".stripIndent)
    test "accepts literal without trailing comma":
      expectNoOffenses("VALUES = [1001, 2020, 3333]")
    test "accepts single element literal without trailing comma":
      expectNoOffenses("VALUES = [1001]")
    test "accepts empty literal":
      expectNoOffenses("VALUES = []")
    test "accepts rescue clause":
      expectNoOffenses("""        begin
          do_something
        rescue RuntimeError
        end
""".stripIndent)
    test "auto-corrects unwanted comma in literal":
      var newSource = autocorrectSource("VALUES = [1001, 2020, 3333, ]")
      expect(newSource).to(eq("VALUES = [1001, 2020, 3333 ]")))
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
      test "registers an offense for trailing comma":
        expectOffense("""          VALUES = [
                     1001,
                     2020,
                     3333,
                         ^ Avoid comma after the last item of an array.
                   ]
""".stripIndent)
      test "accepts a literal with no trailing comma":
        expectNoOffenses("""          VALUES = [ 1001,
                     2020,
                     3333 ]
""".stripIndent)
      test "auto-corrects unwanted comma":
        var newSource = autocorrectSource("""          VALUES = [
                     1001,
                     2020,
                     3333,
                   ]
""".stripIndent)
        expect(newSource).to(eq("""          VALUES = [
                     1001,
                     2020,
                     3333
                   ]
""".stripIndent))
      test "accepts HEREDOC with commas":
        expectNoOffenses("""          [
            <<-TEXT, 123
              Something with a , in it
            TEXT
          ]
""".stripIndent)
      test "auto-corrects unwanted comma where HEREDOC has commas":
        var newSource = autocorrectSource("""          [
            <<-TEXT, 123,
              Something with a , in it
            TEXT
          ]
""".stripIndent)
        expect(newSource).to(eq("""          [
            <<-TEXT, 123
              Something with a , in it
            TEXT
          ]
""".stripIndent)))
    context("when EnforcedStyleForMultiline is comma", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyleForMultiline": "comma"}.newTable())
      context("when closing bracket is on same line as last value", proc (): void =
        test "accepts literal with no trailing comma":
          expectNoOffenses("""            VALUES = [
                       1001,
                       2020,
                       3333]
""".stripIndent))
      test "accepts literal with two of the values on the same line":
        expectNoOffenses("""          VALUES = [
                     1001, 2020,
                     3333
                   ]
""".stripIndent)
      test """registers an offense for a literal with two of the values on the same line and a trailing comma""":
        expectOffense("""          VALUES = [
                     1001, 2020,
                     3333,
                         ^ Avoid comma after the last item of an array, unless each item is on its own line.
                   ]
""".stripIndent)
      test "accepts trailing comma":
        expectNoOffenses("""          VALUES = [1001,
                    2020,
                    3333,
                   ]
""".stripIndent)
      test "accepts a multiline word array":
        expectNoOffenses("""          ingredients = %w(
            sausage
            anchovies
            olives
          )
""".stripIndent)
      test "accepts an empty array being passed as a method argument":
        expectNoOffenses("""          Foo.new([
                   ])
""".stripIndent)
      test """auto-corrects literal with two of the values on the same line and a trailing comma""":
        var newSource = autocorrectSource("""          VALUES = [
                     1001, 2020,
                     3333
                   ]
""".stripIndent)
        expect(newSource).to(eq("""          VALUES = [
                     1001, 2020,
                     3333
                   ]
""".stripIndent))
      test "accepts a multiline array with a single item and trailing comma":
        expectNoOffenses("""          foo = [
            1,
          ]
""".stripIndent))
    context("when EnforcedStyleForMultiline is consistent_comma", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyleForMultiline": "consistent_comma"}.newTable())
      context("when closing bracket is on same line as last value", proc (): void =
        test "registers an offense for no trailing comma":
          expectOffense("""            VALUES = [
                       1001,
                       2020,
                       3333]
                       ^^^^ Put a comma after the last item of a multiline array.
""".stripIndent))
      test "accepts two values on the same line":
        expectNoOffenses("""          VALUES = [
                     1001, 2020,
                     3333,
                   ]
""".stripIndent)
      test """registers an offense for literal with two of the values on the same line and no trailing comma""":
        expectOffense("""          VALUES = [
                     1001, 2020,
                     3333
                     ^^^^ Put a comma after the last item of a multiline array.
                   ]
""".stripIndent)
      test "accepts trailing comma":
        expectNoOffenses("""          VALUES = [1001,
                    2020,
                    3333,
                   ]
""".stripIndent)
      test "accepts a multiline word array":
        expectNoOffenses("""          ingredients = %w(
            sausage
            anchovies
            olives
          )
""".stripIndent)
      test """auto-corrects a literal with two of the values on the same line and a trailing comma""":
        var newSource = autocorrectSource("""          VALUES = [
                     1001, 2020,
                     3333
                   ]
""".stripIndent)
        expect(newSource).to(eq("""          VALUES = [
                     1001, 2020,
                     3333,
                   ]
""".stripIndent))
      test "accepts a multiline array with a single item and trailing comma":
        expectNoOffenses("""          foo = [
            1,
          ]
""".stripIndent)
      test """accepts a multiline array with items on a single line andtrailing comma""":
        expectNoOffenses("""          foo = [
            1, 2,
          ]
""".stripIndent))))
