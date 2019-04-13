
import
  trailing_comma_in_arguments, test_tools

RSpec.describe(TrailingCommaInArguments, "config", proc (): void =
  var cop = ()
  sharedExamples("single line lists", proc (extraInfo: string): void =
    test "registers an offense for trailing comma in a method call":
      expectOffense("""        some_method(a, b, c, )
                           ^ Avoid comma after the last parameter of a method call(lvar :extra_info).
""".stripIndent)
    test """registers an offense for trailing comma preceded by whitespace in a method call""":
      expectOffense("""        some_method(a, b, c , )
                            ^ Avoid comma after the last parameter of a method call(lvar :extra_info).
""".stripIndent)
    test """registers an offense for trailing comma in a method call with hash parameters at the end""":
      expectOffense("""        some_method(a, b, c: 0, d: 1, )
                                    ^ Avoid comma after the last parameter of a method call(lvar :extra_info).
""".stripIndent)
    test "accepts method call without trailing comma":
      expectNoOffenses("some_method(a, b, c)")
    test """accepts method call without trailing comma when a line break before a method call""":
      expectNoOffenses("""        obj
          .do_something(:foo, :bar)
""".stripIndent)
    test """accepts method call without trailing comma with single element hash parameters at the end""":
      expectNoOffenses("some_method(a: 1)")
    test "accepts method call without parameters":
      expectNoOffenses("some_method")
    test "accepts chained single-line method calls":
      expectNoOffenses("""        target
          .some_method(a)
""".stripIndent)
    test "auto-corrects unwanted comma in a method call":
      var newSource = autocorrectSource("some_method(a, b, c, )")
      expect(newSource).to(eq("some_method(a, b, c )"))
    test """auto-corrects unwanted comma in a method call with hash parameters at the end""":
      var newSource = autocorrectSource("some_method(a, b, c: 0, d: 1, )")
      expect(newSource).to(eq("some_method(a, b, c: 0, d: 1 )"))
    test "accepts heredoc without trailing comma":
      expectNoOffenses("""        route(1, <<-HELP.chomp)
        ...
        HELP
""".stripIndent)
    context("when using safe navigation operator", "ruby23", proc (): void =
      test "registers an offense for trailing comma in a method call":
        expectOffense("""        receiver&.some_method(a, b, c, )
                                     ^ Avoid comma after the last parameter of a method call(lvar :extra_info).
""".stripIndent)
      test """registers an offense for trailing comma in a method call with hash parameters at the end""":
        expectOffense("""        receiver&.some_method(a, b, c: 0, d: 1, )
                                              ^ Avoid comma after the last parameter of a method call(lvar :extra_info).
""".stripIndent)
      test "auto-corrects unwanted comma in a method call":
        var newSource = autocorrectSource("receiver&.some_method(a, b, c, )")
        expect(newSource).to(eq("receiver&.some_method(a, b, c )"))
      test """auto-corrects unwanted comma in a method call with hash parameters at the end""":
        var newSource = autocorrectSource("receiver&.some_method(a, b, c: 0, d: 1, )")
        expect(newSource).to(eq("receiver&.some_method(a, b, c: 0, d: 1 )"))))
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
  context("with a single argument spanning multiple lines", proc (): void =
    context("when EnforcedStyleForMultiline is consistent_comma", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyleForMultiline": "consistent_comma"}.newTable())
      test "accepts a single argument with no trailing comma":
        expectNoOffenses("""          EmailWorker.perform_async({
            subject: "hey there",
            email: "foo@bar.com"
          })
""".stripIndent)))
  context("with multi-line list of values", proc (): void =
    context("when EnforcedStyleForMultiline is no_comma", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyleForMultiline": "no_comma"}.newTable())
      test """registers an offense for trailing comma in a method call with hash parameters at the end""":
        expectOffense("""          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,)
                            ^ Avoid comma after the last parameter of a method call.
""".stripIndent)
      test """accepts a method call with hash parameters at the end and no trailing comma""":
        expectNoOffenses("""          some_method(a,
                      b,
                      c: 0,
                      d: 1
                     )
""".stripIndent)
      test "accepts comma inside a heredoc parameter at the end":
        expectNoOffenses("""          route(help: {
            'auth' => <<-HELP.chomp
          ,
          HELP
          })
""".stripIndent)
      test "accepts comma inside a heredoc with comments inside":
        expectNoOffenses("""          route(
            <<-HELP
            ,
            # some comment
            HELP
          )
""".stripIndent)
      test "accepts comma inside a heredoc with method and comments inside":
        expectNoOffenses("""          route(
            <<-HELP.chomp
            ,
            # some comment
            HELP
          )
""".stripIndent)
      test "accepts comma inside a heredoc in brackets":
        expectNoOffenses("""          new_source = autocorrect_source(
            autocorrect_source(<<-SOURCE.strip_indent)
              run(
                    :foo, defaults.merge(
                                          bar: 3))
            SOURCE
          )
""".stripIndent)
      test "accepts comma inside a modified heredoc parameter":
        expectNoOffenses("""          some_method(
            <<-LOREM.delete("\n")
              Something with a , in it
            LOREM
          )
""".stripIndent)
      test "auto-corrects unwanted comma after modified heredoc parameter":
        var newSource = autocorrectSource("""          some_method(
            <<-LOREM.delete("\n"),
              Something with a , in it
            LOREM
          )
""".stripIndent)
        expect(newSource).to(eq("""          some_method(
            <<-LOREM.delete("\n")
              Something with a , in it
            LOREM
          )
""".stripIndent))
      context("when there is string interpolation inside heredoc parameter", proc (): void =
        test "accepts comma inside a heredoc parameter":
          expectNoOffenses("""            some_method(
              <<-SQL
                #{variable}.a ASC,
                #{variable}.b ASC
              SQL
            )
""".stripIndent)
        test "accepts comma inside a heredoc parameter when on a single line":
          expectNoOffenses("""            some_method(
              bar: <<-BAR
                #{variable} foo, bar
              BAR
            )
""".stripIndent)
        test "auto-corrects unwanted comma inside string interpolation":
          var newSource = autocorrectSource("""            some_method(
              bar: <<-BAR,
                #{other_method(a, b,)} foo, bar
              BAR
              baz: <<-BAZ
                #{third_method(c, d,)} foo, bar
              BAZ
            )
""".stripIndent)
          expect(newSource).to(eq("""            some_method(
              bar: <<-BAR,
                #{other_method(a, b)} foo, bar
              BAR
              baz: <<-BAZ
                #{third_method(c, d)} foo, bar
              BAZ
            )
""".stripIndent)))
      test """auto-corrects unwanted comma in a method call with hash parameters at the end""":
        var newSource = autocorrectSource("""          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,)
""".stripIndent)
        expect(newSource).to(eq("""          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1)
""".stripIndent)))
    context("when EnforcedStyleForMultiline is comma", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyleForMultiline": "comma"}.newTable())
      context("when closing bracket is on same line as last value", proc (): void =
        test """accepts a method call with Hash as last parameter split on multiple lines""":
          expectNoOffenses("""            some_method(a: "b",
                        c: "d")
""".stripIndent))
      test """registers an offense for no trailing comma in a method call with hash parameters at the end""":
        expectOffense("""          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1
                        ^^^^ Put a comma after the last parameter of a multiline method call.
                     )
""".stripIndent)
      test "accepts a method call with two parameters on the same line":
        expectNoOffenses("""          some_method(a, b
                     )
""".stripIndent)
      test """accepts trailing comma in a method call with hash parameters at the end""":
        expectNoOffenses("""          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                     )
""".stripIndent)
      test "accepts missing comma after heredoc with comments":
        expectNoOffenses("""          route(
            a, <<-HELP.chomp
            ,
            # some comment
            HELP
          )
""".stripIndent)
      test """accepts no trailing comma in a method call with a multiline braceless hash at the end with more than one parameter on a line""":
        expectNoOffenses("""          some_method(
                        a,
                        b: 0,
                        c: 0, d: 1
                     )
""".stripIndent)
      test """accepts a trailing comma in a method call with single line hashes""":
        expectNoOffenses("""          some_method(
           { a: 0, b: 1 },
           { a: 1, b: 0 },
          )
""".stripIndent)
      test "accepts an empty hash being passed as a method argument":
        expectNoOffenses("""          Foo.new({
                   })
""".stripIndent)
      test """auto-corrects missing comma in a method call with hash parameters at the end""":
        var newSource = autocorrectSource("""          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1
                     )
""".stripIndent)
        expect(newSource).to(eq("""          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                     )
""".stripIndent))
      test "accepts a multiline call with a single argument and trailing comma":
        expectNoOffenses("""          method(
            1,
          )
""".stripIndent)
      test "does not break when a method call is chaned on the offending one":
        expectNoOffenses("""          foo.bar(
            baz: 1,
          ).fetch(:qux)
""".stripIndent)
      it("""does not break when a safe method call is chained on the offending one""",
         "ruby23", proc (): void =
        expectNoOffenses("""          foo
            &.do_something(:bar, :baz)
""".stripIndent))
      it("""does not break when a safe method call is chained on the offending one""",
         "ruby23", proc (): void =
        expectNoOffenses("""          foo.bar(
            baz: 1,
          )&.fetch(:qux)
""".stripIndent)))
    context("when EnforcedStyleForMultiline is consistent_comma", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyleForMultiline": "consistent_comma"}.newTable())
      context("when closing bracket is on same line as last value", proc (): void =
        test """registers an offense for a method call, with a Hash as the last parameter, split on multiple lines""":
          expectOffense("""            some_method(a: "b",
                        c: "d")
                        ^^^^^^ Put a comma after the last parameter of a multiline method call.
""".stripIndent))
      test """registers an offense for no trailing comma in a method call with hash parameters at the end""":
        expectOffense("""          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1
                        ^^^^ Put a comma after the last parameter of a multiline method call.
                     )
""".stripIndent)
      test """registers an offense for no trailing comma in a method call withtwo parameters on the same line""":
        expectOffense("""          some_method(a, b
                         ^ Put a comma after the last parameter of a multiline method call.
                     )
""".stripIndent)
      test """accepts trailing comma in a method call with hash parameters at the end""":
        expectNoOffenses("""          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                     )
""".stripIndent)
      test """accepts a trailing comma in a method call with a single hash parameter""":
        expectNoOffenses("""          some_method(
                        a: 0,
                        b: 1,
                     )
""".stripIndent)
      test """accepts a trailing comma in a method call with a single hash parameter to a receiver object""":
        expectNoOffenses("""          obj.some_method(
                            a: 0,
                            b: 1,
                         )
""".stripIndent)
      test """accepts a trailing comma in a method call with single line hashes""":
        expectNoOffenses("""          some_method(
           { a: 0, b: 1 },
           { a: 1, b: 0 },
          )
""".stripIndent)
      test """accepts no trailing comma in a method call with a block parameter at the end""":
        expectNoOffenses("""          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                        &block
                     )
""".stripIndent)
      test "auto-corrects missing comma after a heredoc":
        var newSource = autocorrectSource("""          route(1, <<-HELP.chomp
          ...
          HELP
          )
""".stripIndent)
        expect(newSource).to(eq("""          route(1, <<-HELP.chomp,
          ...
          HELP
          )
""".stripIndent))
      test """auto-corrects missing comma in a method call with hash parameters at the end""":
        var newSource = autocorrectSource("""          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1
                     )
""".stripIndent)
        expect(newSource).to(eq("""          some_method(
                        a,
                        b,
                        c: 0,
                        d: 1,
                     )
""".stripIndent))
      test "accepts a multiline call with a single argument and trailing comma":
        expectNoOffenses("""          method(
            1,
          )
""".stripIndent)
      test """accepts a multiline call with arguments on a single line and trailing comma""":
        expectNoOffenses("""          method(
            1, 2,
          )
""".stripIndent)
      test "accepts a multiline call with single argument on multiple lines":
        expectNoOffenses("""          method(a:
                    "foo")
""".stripIndent))))
