
import
  braces_around_hash_parameters, test_tools

RSpec.describe(BracesAroundHashParameters, "config", proc (): void =
  var cop = ()
  sharedExamples("general non-offenses", proc (): void =
    test "accepts one non-hash parameter":
      expectNoOffenses("where(2)")
    test "accepts multiple non-hash parameters":
      expectNoOffenses("where(1, \"2\")")
    test "accepts one empty hash parameter":
      expectNoOffenses("where({})")
    test "accepts one empty hash parameter with whitespace":
      expectNoOffenses(@["where(  {     ", " }\t   )  "].join("\n")))
  sharedExamples("no_braces and context_dependent non-offenses", proc (): void =
    test "accepts one hash parameter without braces":
      expectNoOffenses("where(x: \"y\")")
    test "accepts one hash parameter without braces and with multiple keys":
      expectNoOffenses("where(x: \"y\", foo: \"bar\")")
    test "accepts one hash parameter without braces and with one hash value":
      expectNoOffenses("where(x: { \"y\" => \"z\" })")
    test "accepts property assignment with braces":
      expectNoOffenses("x.z = { y: \"z\" }")
    test "accepts operator with a hash parameter with braces":
      expectNoOffenses("x.z - { y: \"z\" }"))
  sharedExamples("no_braces and context_dependent offenses", proc (): void =
    test """registers an offense for one non-hash parameter followed by a hash parameter with braces""":
      expectOffense("""        where(1, { y: 2 })
                 ^^^^^^^^ Redundant curly braces around a hash parameter.
""".stripIndent)
    context("when using safe navigation operator", "ruby23", proc (): void =
      test """registers an offense for one non-hash parameter followed by a hash parameter with braces""":
        expectOffense("""          a&.where(1, { y: 2 })
                      ^^^^^^^^ Redundant curly braces around a hash parameter.
""".stripIndent))
    test """registers an offense for one object method hash parameter with braces""":
      expectOffense("""        x.func({ y: "z" })
               ^^^^^^^^^^ Redundant curly braces around a hash parameter.
""".stripIndent)
    test "registers an offense for one hash parameter with braces":
      expectOffense("""        where({ x: 1 })
              ^^^^^^^^ Redundant curly braces around a hash parameter.
""".stripIndent)
    test """registers an offense for one hash parameter with braces and whitespace""":
      expectOffense("""        where(  
          { x: 1 }   )
          ^^^^^^^^ Redundant curly braces around a hash parameter.
""".stripIndent)
    test """registers an offense for one hash parameter with braces and multiple keys""":
      expectOffense("""        where({ x: 1, foo: "bar" })
              ^^^^^^^^^^^^^^^^^^^^ Redundant curly braces around a hash parameter.
""".stripIndent))
  sharedExamples("no_braces and context_dependent auto-corrections", proc (): void =
    test """corrects one non-hash parameter followed by a hash parameter with braces""":
      var corrected = autocorrectSource("where(1, { y: 2 })")
      expect(corrected).to(eq("where(1, y: 2)"))
    test "corrects one object method hash parameter with braces":
      var corrected = autocorrectSource("x.func({ y: \"z\" })")
      expect(corrected).to(eq("x.func(y: \"z\")"))
    test "corrects one hash parameter with braces":
      var corrected = autocorrectSource("where({ x: 1 })")
      expect(corrected).to(eq("where(x: 1)"))
    test "corrects one hash parameter with braces and whitespace":
      var corrected = autocorrectSource(@["where(  ", " { x: 1 }   )"].join("\n"))
      expect(corrected).to(eq(@["where(  ", " x: 1   )"].join("\n")))
    test "corrects one hash parameter with braces and multiple keys":
      var corrected = autocorrectSource("where({ x: 1, foo: \"bar\" })")
      expect(corrected).to(eq("where(x: 1, foo: \"bar\")"))
    test "corrects one hash parameter with braces and extra leading whitespace":
      var corrected = autocorrectSource("where({   x: 1, y: 2 })")
      expect(corrected).to(eq("where(x: 1, y: 2)"))
    test """corrects one hash parameter with braces and extra trailing whitespace""":
      var corrected = autocorrectSource("where({ x: 1, y: 2   })")
      expect(corrected).to(eq("where(x: 1, y: 2)"))
    test "corrects one hash parameter with braces and a trailing comma":
      var corrected = autocorrectSource("where({ x: 1, y: 2, })")
      expect(corrected).to(eq("where(x: 1, y: 2)"))
    test """corrects one hash parameter with braces and trailing comma and whitespace""":
      var corrected = autocorrectSource("where({ x: 1, y: 2,   })")
      expect(corrected).to(eq("where(x: 1, y: 2)"))
    test "corrects one hash parameter with braces without adding extra space":
      var corrected = autocorrectSource("get :i, { q: { x: 1 } }")
      expect(corrected).to(eq("get :i, q: { x: 1 }"))
    test "does not break indent":
      var
        src = """      foo({
        a: 1,
        b: 2
      })
"""
        corrected = autocorrectSource(src)
      expect(corrected).to(eq("""      foo(
        a: 1,
        b: 2
      )
"""))
    test "does not remove trailing comma nor realign args":
      var
        src = """      foo({
        a: 1,
        b: 2,
      })
""".stripIndent
        corrected = autocorrectSource(src)
      expect(corrected).to(eq("""      foo(
        a: 1,
        b: 2,
      )
""".stripIndent))
    test "corrects brace removal with 2 extra lines":
      var
        src = """      foo(
        {
          baz: 10
        }
      )
""".stripIndent
        corrected = autocorrectSource(src)
      expect(corrected).to(eq("""      foo(
          baz: 10
      )
""".stripIndent))
    test "corrects brace removal with extra lines & multiple pairs":
      var
        src = """      foo(
        {
          qux: "bar",
          baz: "bar",
          thud: "bar"
        }
      )
""".stripIndent
        corrected = autocorrectSource(src)
      expect(corrected).to(eq("""      foo(
          qux: "bar",
          baz: "bar",
          thud: "bar"
      )
""".stripIndent))
    test "corrects brace removal with lower extra line":
      var
        src = """      foo({
        baz: 7
        }
      )
""".stripIndent
        corrected = autocorrectSource(src)
      expect(corrected).to(eq("""      foo(
        baz: 7
      )
""".stripIndent))
    test "corrects brace removal with top extra line":
      var
        src = """      foo(
        {
          baz: 5
      })
""".stripIndent
        corrected = autocorrectSource(src)
      expect(corrected).to(eq("""      foo(
          baz: 5
      )
""".stripIndent))
    context("with a comment following the last key-value pair", proc (): void =
      test "corrects and leaves line breaks":
        var
          src = """          r = opts.merge({
            p1: opts[:a],
            p2: (opts[:b] || opts[:c]) # a comment
          })
""".stripIndent
          corrected = autocorrectSource(src)
        expect(corrected).to(eq("""          r = opts.merge(
            p1: opts[:a],
            p2: (opts[:b] || opts[:c]) # a comment
          )
""".stripIndent)))
    context("in a method call without parentheses", proc (): void =
      test "corrects a hash parameter with trailing comma":
        var
          src = "get :i, { x: 1, }"
          corrected = autocorrectSource(src)
        expect(corrected).to(eq("get :i, x: 1")))
    context("in a method call with multi line arguments without parentheses", proc (): void =
      test "removes hash braces":
        var
          src = "render \'foo\', {\n  foo: bar\n}"
          corrected = autocorrectSource(src)
        expect(corrected).to(eq("render \'foo\', \n  foo: bar\n"))))
  context("when EnforcedStyle is no_braces", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "no_braces"}.newTable())
    context("for correct code", proc (): void =
      includeExamples("general non-offenses")
      includeExamples("no_braces and context_dependent non-offenses"))
    context("for incorrect code", proc (): void =
      includeExamples("no_braces and context_dependent offenses")
      test "registers an offense for two hash parameters with braces":
        expectOffense("""          where({ x: 1 }, { y: 2 })
                          ^^^^^^^^ Redundant curly braces around a hash parameter.
""".stripIndent))
    describe("#autocorrect", proc (): void =
      includeExamples("no_braces and context_dependent auto-corrections")
      test "corrects one hash parameter with braces":
        var corrected = autocorrectSource("where(1, { x: 1 })")
        expect(corrected).to(eq("where(1, x: 1)"))
      test "corrects two hash parameters with braces":
        var corrected = autocorrectSource("where(1, { x: 1 }, { y: 2 })")
        expect(corrected).to(eq("where(1, { x: 1 }, y: 2)"))
      test "corrects two hash parameters with braces & extra lines":
        var
          src = """        foo(
          {
            qux: 9
          },
          {
            bar: 0
          }
        )
""".stripIndent
          corrected = autocorrectSource(src)
        expect(corrected).to(eq("""        foo(
          {
            qux: 9
          },
            bar: 0
        )
""".stripIndent))
      test "corrects parameters with braces & trailing comma":
        var corrected = autocorrectSource("foo(1, { x: 1, y: 2, },)")
        expect(corrected).to(eq("foo(1, x: 1, y: 2,)"))
      test "corrects hash multiline parameters with braces & trailing comma":
        var
          src = """        foo(
          {
            foo: 1,
            bar: 2,
          } ,
        )
""".stripIndent
          corrected = autocorrectSource(src)
        expect(corrected).to(eq("""        foo(
            foo: 1,
            bar: 2,
        )
""".stripIndent))
      test """corrects when the opening brace is before the first hash elementat same line""":
        var corrected = autocorrectSource("""          foo = Foo.new(
            { foo: 'foo',
              bar: 'bar',
              baz: 'this is the last element'}
          )
""".stripIndent)
        expect(corrected).to(eq("""          foo = Foo.new(
             foo: 'foo',
              bar: 'bar',
              baz: 'this is the last element'
          )
""".stripIndent))))
  context("when EnforcedStyle is context_dependent", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "context_dependent"}.newTable())
    context("for correct code", proc (): void =
      includeExamples("general non-offenses")
      includeExamples("no_braces and context_dependent non-offenses")
      test "accepts two hash parameters with braces":
        expectNoOffenses("where({ x: 1 }, { y: 2 })"))
    context("for incorrect code", proc (): void =
      includeExamples("no_braces and context_dependent offenses")
      test """registers an offense for one hash parameter with braces and one without""":
        expectOffense("""          where({ x: 1 }, y: 2)
                          ^^^^ Missing curly braces around a hash parameter.
""".stripIndent))
    describe("#autocorrect", proc (): void =
      includeExamples("no_braces and context_dependent auto-corrections")
      test "corrects one hash parameter with braces and one without":
        var corrected = autocorrectSource("where(1, { x: 1 }, y: 2)")
        expect(corrected).to(eq("where(1, { x: 1 }, {y: 2})"))
      test "corrects one hash parameter with braces":
        var corrected = autocorrectSource("where(1, { x: 1 })")
        expect(corrected).to(eq("where(1, x: 1)"))))
  context("when EnforcedStyle is braces", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "braces"}.newTable())
    context("for correct code", proc (): void =
      includeExamples("general non-offenses")
      test "accepts one hash parameter with braces":
        expectNoOffenses("where({ x: 1 })")
      test "accepts multiple hash parameters with braces":
        expectNoOffenses("where({ x: 1 }, { y: 2 })")
      test "accepts one hash parameter with braces and whitespace":
        expectNoOffenses("""          where( 	    {  x: 1
            }   )
""".stripIndent))
    context("for incorrect code", proc (): void =
      test "registers an offense for one hash parameter without braces":
        expectOffense("""          where(x: "y")
                ^^^^^^ Missing curly braces around a hash parameter.
""".stripIndent)
      test """registers an offense for one hash parameter with multiple keys and without braces""":
        expectOffense("""          where(x: "y", foo: "bar")
                ^^^^^^^^^^^^^^^^^^ Missing curly braces around a hash parameter.
""".stripIndent)
      test """registers an offense for one hash parameter without braces with one hash value""":
        expectOffense("""          where(x: { "y" => "z" })
                ^^^^^^^^^^^^^^^^^ Missing curly braces around a hash parameter.
""".stripIndent))
    describe("#autocorrect", proc (): void =
      test "corrects one hash parameter without braces":
        var corrected = autocorrectSource("where(x: \"y\")")
        expect(corrected).to(eq("where({x: \"y\"})"))
      test "corrects one hash parameter with multiple keys and without braces":
        var corrected = autocorrectSource("where(x: \"y\", foo: \"bar\")")
        expect(corrected).to(eq("where({x: \"y\", foo: \"bar\"})"))
      test "corrects one hash parameter without braces with one hash value":
        var corrected = autocorrectSource("where(x: { \"y\" => \"z\" })")
        expect(corrected).to(eq("where({x: { \"y\" => \"z\" }})")))))
