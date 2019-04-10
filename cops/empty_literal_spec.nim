
import
  empty_literal, test_tools

suite "EmptyLiteral":
  var cop = EmptyLiteral()
  describe("Empty Array", proc (): void =
    test "registers an offense for Array.new()":
      expectOffense("""        test = Array.new()
               ^^^^^^^^^^^ Use array literal `[]` instead of `Array.new`.
""".stripIndent)
    test "registers an offense for Array.new":
      expectOffense("""        test = Array.new
               ^^^^^^^^^ Use array literal `[]` instead of `Array.new`.
""".stripIndent)
    test "does not register an offense for Array.new(3)":
      expectNoOffenses("test = Array.new(3)")
    test "auto-corrects Array.new to []":
      var newSource = autocorrectSource("test = Array.new")
      expect(newSource).to(eq("test = []"))
    test "auto-corrects Array.new in block in block":
      var
        source = "puts { Array.new }"
        newSource = autocorrectSource(source)
      expect(newSource).to(eq("puts { [] }"))
    test "does not registers an offense Array.new with block":
      expectNoOffenses("test = Array.new { 1 }")
    test "does not register Array.new with block in other block":
      expectNoOffenses("puts { Array.new { 1 } }"))
  describe("Empty Hash", proc (): void =
    test "registers an offense for Hash.new()":
      expectOffense("""        test = Hash.new()
               ^^^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
""".stripIndent)
    test "registers an offense for Hash.new":
      expectOffense("""        test = Hash.new
               ^^^^^^^^ Use hash literal `{}` instead of `Hash.new`.
""".stripIndent)
    test "does not register an offense for Hash.new(3)":
      expectNoOffenses("test = Hash.new(3)")
    test "does not register an offense for Hash.new { block }":
      expectNoOffenses("test = Hash.new { block }")
    test "auto-corrects Hash.new to {}":
      var newSource = autocorrectSource("Hash.new")
      expect(newSource).to(eq("{}"))
    test "auto-corrects Hash.new in block ":
      var
        source = "puts { Hash.new }"
        newSource = autocorrectSource(source)
      expect(newSource).to(eq("puts { {} }"))
    test "auto-corrects Hash.new to {} in various contexts":
      var newSource = autocorrectSource("""          test = Hash.new
          Hash.new.merge("a" => 3)
          yadayada.map { a }.reduce(Hash.new, :merge)
""".stripIndent)
      expect(newSource).to(eq("""          test = {}
          {}.merge("a" => 3)
          yadayada.map { a }.reduce({}, :merge)
""".stripIndent))
    test "auto-correct Hash.new to {} as the only parameter to a method":
      var
        source = "yadayada.map { a }.reduce Hash.new"
        newSource = autocorrectSource(source)
      expect(newSource).to(eq("yadayada.map { a }.reduce({})"))
    test "auto-correct Hash.new to {} as the first parameter to a method":
      var
        source = "yadayada.map { a }.reduce Hash.new, :merge"
        newSource = autocorrectSource(source)
      expect(newSource).to(eq("yadayada.map { a }.reduce({}, :merge)"))
    test """auto-correct changes Hash.new to {} and wraps it in parentheses when it is the only argument to super""":
      var newSource = autocorrectSource("""        def foo
          super Hash.new
        end
""".stripIndent)
      expect(newSource).to(eq("""        def foo
          super({})
        end
""".stripIndent))
    test """auto-correct changes Hash.new to {} and wraps all arguments in parentheses when it is the first argument to super""":
      var newSource = autocorrectSource("""        def foo
          super Hash.new, something
        end
""".stripIndent)
      expect(newSource).to(eq("""        def foo
          super({}, something)
        end
""".stripIndent)))
  describe("Empty String", proc (): void =
    test "registers an offense for String.new()":
      expectOffense("""        test = String.new()
               ^^^^^^^^^^^^ Use string literal `''` instead of `String.new`.
""".stripIndent)
    test "registers an offense for String.new":
      expectOffense("""        test = String.new
               ^^^^^^^^^^ Use string literal `''` instead of `String.new`.
""".stripIndent)
    test "does not register an offense for String.new(\"top\")":
      expectNoOffenses("test = String.new(\"top\")")
    test "auto-corrects String.new to empty string literal":
      var newSource = autocorrectSource("test = String.new")
      expect(newSource).to(eq("test = \'\'"))
    context("when double-quoted string literals are preferred", proc (): void =
      var cop = EmptyLiteral()
      let("config", proc (): void =
        Config.new())
      test "registers an offense for String.new":
        expectOffense("""          test = String.new
                 ^^^^^^^^^^ Use string literal `""` instead of `String.new`.
""".stripIndent)
      test "auto-corrects String.new to a double-quoted empty string literal":
        var newSource = autocorrectSource("test = String.new")
        expect(newSource).to(eq("test = \"\"")))
    context("when frozen string literals is enabled", proc (): void =
      let("ruby_version", proc (): void =
        0.0)
      test "does not register an offense for String.new":
        expectNoOffenses("""          # frozen_string_literal: true
          test = String.new
""".stripIndent)))
