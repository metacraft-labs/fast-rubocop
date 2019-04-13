
import
  percent_literal_delimiters, test_tools

RSpec.describe(PercentLiteralDelimiters, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"PreferredDelimiters": {"default": "[]"}.newTable()}.newTable())
  context("`default` override", proc (): void =
    let("cop_config", proc (): void =
      {"PreferredDelimiters": {"default": "[]", "%": "()"}.newTable()}.newTable())
    test "allows all preferred delimiters to be set with one key":
      expectNoOffenses("%w[string] + %i[string]")
    test "allows individual preferred delimiters to override `default`":
      expectNoOffenses("%w[string] + [%(string)]"))
  context("invalid cop config", proc (): void =
    let("cop_config", proc (): void =
      {"PreferredDelimiters": {"foobar": "()"}.newTable()}.newTable())
    test "raises an error when invalid configuration is specified":
      expect(proc (): void =
        inspectSource("%w[string]")).to(raiseError(ArgumentError)))
  context("`%` interpolated string", proc (): void =
    test "does not register an offense for preferred delimiters":
      expectNoOffenses("%[string]")
    test "registers an offense for other delimiters":
      expectOffense("""        %(string)
        ^^^^^^^^^ `%`-literals should be delimited by `[` and `]`.
""".stripIndent)
    test """does not register an offense for other delimiters when containing preferred delimiter characters""":
      expectNoOffenses("        %([string])\n".stripIndent)
    test """registers an offense for other delimiters when containing preferred delimiter characters in interpolation""":
      expectOffense("""        %(#{[1].first})
        ^^^^^^^^^^^^^^^ `%`-literals should be delimited by `[` and `]`.
""".stripIndent))
  context("`%q` string", proc (): void =
    test "does not register an offense for preferred delimiters":
      expectNoOffenses("%q[string]")
    test "registers an offense for other delimiters":
      expectOffense("""        %q(string)
        ^^^^^^^^^^ `%q`-literals should be delimited by `[` and `]`.
""".stripIndent)
    test """does not register an offense for other delimiters when containing preferred delimiter characters""":
      expectNoOffenses("        %q([string])\n".stripIndent))
  context("`%Q` interpolated string", proc (): void =
    test "does not register an offense for preferred delimiters":
      expectNoOffenses("%Q[string]")
    test "registers an offense for other delimiters":
      expectOffense("""        %Q(string)
        ^^^^^^^^^^ `%Q`-literals should be delimited by `[` and `]`.
""".stripIndent)
    test """does not register an offense for other delimiters when containing preferred delimiter characters""":
      expectNoOffenses("        %Q([string])\n".stripIndent)
    test """registers an offense for other delimiters when containing preferred delimiter characters in interpolation""":
      expectOffense("""        %Q(#{[1].first})
        ^^^^^^^^^^^^^^^^ `%Q`-literals should be delimited by `[` and `]`.
""".stripIndent))
  context("`%w` string array", proc (): void =
    test "does not register an offense for preferred delimiters":
      expectNoOffenses("%w[some words]")
    test """does not register an offense for preferred delimiters with a pairing delimiters""":
      expectNoOffenses("%w(\\(some words\\))")
    test """does not register an offense for preferred delimiters with only a closing delimiter""":
      expectNoOffenses("%w(only closing delimiter charapter\\))")
    test """does not register an offense for preferred delimiters with not a pairing delimiter""":
      expectNoOffenses("%w|\\|not pairirng delimiter|")
    test "registers an offense for other delimiters":
      expectOffense("""        %w(some words)
        ^^^^^^^^^^^^^^ `%w`-literals should be delimited by `[` and `]`.
""".stripIndent)
    test """does not register an offense for other delimiters when containing preferred delimiter characters""":
      expectNoOffenses("%w([some] [words])"))
  context("`%W` interpolated string array", proc (): void =
    test "does not register an offense for preferred delimiters":
      expectNoOffenses("%W[some words]")
    test "registers an offense for other delimiters":
      expectOffense("""        %W(some words)
        ^^^^^^^^^^^^^^ `%W`-literals should be delimited by `[` and `]`.
""".stripIndent)
    test """does not register an offense for other delimiters when containing preferred delimiter characters""":
      expectNoOffenses("%W([some] [words])")
    test """registers an offense for other delimiters when containing preferred delimiter characters in interpolation""":
      expectOffense("""        %W(#{[1].first})
        ^^^^^^^^^^^^^^^^ `%W`-literals should be delimited by `[` and `]`.
""".stripIndent))
  context("`%r` interpolated regular expression", proc (): void =
    test "does not register an offense for preferred delimiters":
      expectNoOffenses("%r[regexp]")
    test "registers an offense for other delimiters":
      expectOffense("""        %r(regexp)
        ^^^^^^^^^^ `%r`-literals should be delimited by `[` and `]`.
""".stripIndent)
    test """does not register an offense for other delimiters when containing preferred delimiter characters""":
      expectNoOffenses("%r([regexp])")
    test """registers an offense for other delimiters when containing preferred delimiter characters in interpolation""":
      expectOffense("""        %r(#{[1].first})
        ^^^^^^^^^^^^^^^^ `%r`-literals should be delimited by `[` and `]`.
""".stripIndent))
  context("`%i` symbol array", proc (): void =
    test "does not register an offense for preferred delimiters":
      expectNoOffenses("%i[some symbols]")
    test "registers an offense for other delimiters":
      expectOffense("""        %i(some symbols)
        ^^^^^^^^^^^^^^^^ `%i`-literals should be delimited by `[` and `]`.
""".stripIndent))
  context("`%I` interpolated symbol array", proc (): void =
    test "does not register an offense for preferred delimiters":
      expectNoOffenses("%I[some words]")
    test "registers an offense for other delimiters":
      expectOffense("""        %I(some words)
        ^^^^^^^^^^^^^^ `%I`-literals should be delimited by `[` and `]`.
""".stripIndent)
    test """registers an offense for other delimiters when containing preferred delimiter characters in interpolation""":
      expectOffense("""        %I(#{[1].first})
        ^^^^^^^^^^^^^^^^ `%I`-literals should be delimited by `[` and `]`.
""".stripIndent))
  context("`%s` symbol", proc (): void =
    test "does not register an offense for preferred delimiters":
      expectNoOffenses("%s[symbol]")
    test "registers an offense for other delimiters":
      expectOffense("""        %s(symbol)
        ^^^^^^^^^^ `%s`-literals should be delimited by `[` and `]`.
""".stripIndent))
  context("`%x` interpolated system call", proc (): void =
    test "does not register an offense for preferred delimiters":
      expectNoOffenses("%x[command]")
    test "registers an offense for other delimiters":
      expectOffense("""        %x(command)
        ^^^^^^^^^^^ `%x`-literals should be delimited by `[` and `]`.
""".stripIndent)
    test """does not register an offense for other delimiters when containing preferred delimiter characters""":
      expectNoOffenses("%x([command])")
    test """registers an offense for other delimiters when containing preferred delimiter characters in interpolation""":
      expectOffense("""        %x(#{[1].first})
        ^^^^^^^^^^^^^^^^ `%x`-literals should be delimited by `[` and `]`.
""".stripIndent))
  context("auto-correct", proc (): void =
    test "fixes a string":
      var newSource = autocorrectSource("%(string)")
      expect(newSource).to(eq("%[string]"))
    test "fixes a string with no content":
      var newSource = autocorrectSource("%()")
      expect(newSource).to(eq("%[]"))
    test "fixes a string array":
      var newSource = autocorrectSource("%w(some words)")
      expect(newSource).to(eq("%w[some words]"))
    test "fixes a string array in a scope":
      var newSource = autocorrectSource("""        module Foo
           class Bar
             def baz
               %(one two)
             end
           end
         end
""".stripIndent)
      expect(newSource).to(eq("""        module Foo
           class Bar
             def baz
               %[one two]
             end
           end
         end
""".stripIndent))
    test "fixes a regular expression":
      var
        originalSource = "%r(.*)"
        newSource = autocorrectSource(originalSource)
      expect(newSource).to(eq("%r[.*]"))
    test "fixes a string with interpolation":
      var
        originalSource = "%Q|#{with_interpolation}|"
        newSource = autocorrectSource(originalSource)
      expect(newSource).to(eq("%Q[#{with_interpolation}]"))
    test "fixes a regular expression with interpolation":
      var
        originalSource = "%r|#{with_interpolation}|"
        newSource = autocorrectSource(originalSource)
      expect(newSource).to(eq("%r[#{with_interpolation}]"))
    test "fixes a regular expression with option":
      var
        originalSource = "%r(.*)i"
        newSource = autocorrectSource(originalSource)
      expect(newSource).to(eq("%r[.*]i"))
    test "preserves line breaks when fixing a multiline array":
      var newSource = autocorrectSource("""        %w(
        some
        words
        )
""".stripIndent)
      expect(newSource).to(eq("""        %w[
        some
        words
        ]
""".stripIndent))
    test "preserves indentation when correcting a multiline array":
      var
        originalSource = """        |  array = %w(
        |    first
        |    second
        |  )
""".stripMargin(
            "|")
        correctedSource = """        |  array = %w[
        |    first
        |    second
        |  ]
""".stripMargin(
            "|")
        newSource = autocorrectSource(originalSource)
      expect(newSource).to(eq(correctedSource))
    test "preserves irregular indentation when correcting a multiline array":
      var
        originalSource = """          array = %w(
            first
          second
        )
""".stripIndent
        correctedSource = """          array = %w[
            first
          second
        ]
""".stripIndent
        newSource = autocorrectSource(originalSource)
      expect(newSource).to(eq(correctedSource))
    sharedExamples("escape characters", proc (percentLiteral: string): void =
      test """corrects (lvar :percent_literal) with \n in it""":
        var newSource = autocorrectSource("""(lvar :percent_literal){
}""")
        expect(newSource).to(eq("""(lvar :percent_literal)[
]"""))
      test """corrects (lvar :percent_literal) with \t in it""":
        var newSource = autocorrectSource("""(lvar :percent_literal){	}""")
        expect(newSource).to(eq("""(lvar :percent_literal)[	]""")))
    itBehavesLike("escape characters", "%")
    itBehavesLike("escape characters", "%q")
    itBehavesLike("escape characters", "%Q")
    itBehavesLike("escape characters", "%s")
    itBehavesLike("escape characters", "%w")
    itBehavesLike("escape characters", "%W")
    itBehavesLike("escape characters", "%x")
    itBehavesLike("escape characters", "%r")
    itBehavesLike("escape characters", "%i")))
