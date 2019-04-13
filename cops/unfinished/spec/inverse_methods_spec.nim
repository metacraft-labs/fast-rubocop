
import
  tables

import
  inverse_methods, test_tools

suite "InverseMethods":
  var cop = InverseMethods()
  let("config", proc (): void =
    Config.new())
  test "registers an offense for calling !.none? with a symbol proc":
    expectOffense("""      !foo.none?(&:even?)
      ^^^^^^^^^^^^^^^^^^^ Use `any?` instead of inverting `none?`.
""".stripIndent)
  test "registers an offense for calling !.none? with a block":
    expectOffense("""      !foo.none? { |f| f.even? }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `any?` instead of inverting `none?`.
""".stripIndent)
  test "allows a method call without a not":
    expectNoOffenses("foo.none?")
  test "allows an inverse method when double negation is used":
    expectNoOffenses("!!(string =~ /^\\w+$/)")
  test "allows an inverse method with a block when double negation is used":
    expectNoOffenses("!!foo.reject { |e| !e }")
  context("auto-correct", proc (): void =
    test "corrects !.none? with a symbol proc to any?":
      var newSource = autocorrectSource("!foo.none?(&:even?)")
      expect(newSource).to(eq("foo.any?(&:even?)"))
    test "corrects !.none? with a block to any?":
      var newSource = autocorrectSource("!foo.none? { |f| f.even? }")
      expect(newSource).to(eq("foo.any? { |f| f.even? }")))
  sharedExamples("all variable types", proc (variable: string): void =
    test """registers an offense for calling !(lvar :variable).none?""":
      inspectSource("""!(lvar :variable).none?""")
      expect(cop().messages).to(eq(@["Use `any?` instead of inverting `none?`."]))
      expect(cop().highlights).to(eq(@["""!(lvar :variable).none?"""]))
    test """registers an offense for calling not (lvar :variable).none?""":
      inspectSource("""not (lvar :variable).none?""")
      expect(cop().messages).to(eq(@["Use `any?` instead of inverting `none?`."]))
      expect(cop().highlights).to(eq(@["""not (lvar :variable).none?"""]))
    test """corrects !(lvar :variable).none? to (lvar :variable).any?""":
      var newSource = autocorrectSource("""!(lvar :variable).none?""")
      expect(newSource).to(eq("""(lvar :variable).any?"""))
    test """corrects not (lvar :variable).none? to (lvar :variable).any?""":
      var newSource = autocorrectSource("""not (lvar :variable).none?""")
      expect(newSource).to(eq("""(lvar :variable).any?""")))
  itBehavesLike("all variable types", "foo")
  itBehavesLike("all variable types", "$foo")
  itBehavesLike("all variable types", "@foo")
  itBehavesLike("all variable types", "@@foo")
  itBehavesLike("all variable types", "FOO")
  itBehavesLike("all variable types", "FOO::BAR")
  itBehavesLike("all variable types", "foo[\"bar\"]")
  itBehavesLike("all variable types", "foo.bar")
  for method, inverse in {"any?": "none?", "even?": "odd?", "present?": "blank?",
                      "include?": "exclude?", "none?": "any?", "odd?": "even?",
                      "blank?": "present?", "exclude?": "include?"}.newTable():
    test """registers an offense for !foo.(lvar :method)""":
      inspectSource("""!foo.(lvar :method)""")
      expect(cop().messages).to(eq(@["""Use `(lvar :inverse)` instead of inverting `(lvar :method)`."""]))
    test """corrects (lvar :method) to (lvar :inverse)""":
      var newSource = autocorrectSource("""!foo.(lvar :method)""")
      expect(newSource).to(eq("""foo.(lvar :inverse)"""))
  for method, inverse in {"==": "!=", "!=": "==", "=~": "!~", "!~": "=~", "<": ">=", ">": "<="}.newTable():
    test """registers an offense for !(foo (lvar :method) bar)""":
      inspectSource("""!(foo (lvar :method) bar)""")
      expect(cop().messages).to(eq(@["""Use `(lvar :inverse)` instead of inverting `(lvar :method)`."""]))
    test """registers an offense for not (foo (lvar :method) bar)""":
      inspectSource("""not (foo (lvar :method) bar)""")
      expect(cop().messages).to(eq(@["""Use `(lvar :inverse)` instead of inverting `(lvar :method)`."""]))
    test """corrects (lvar :method) to (lvar :inverse)""":
      var newSource = autocorrectSource("""!(foo (lvar :method) bar)""")
      expect(newSource).to(eq("""foo (lvar :inverse) bar"""))
  test "allows comparing camel case constants on the right":
    expectNoOffenses("""      klass = self.class
      !(klass < BaseClass)
""".stripIndent)
  test "allows comparing camel case constants on the left":
    expectNoOffenses("""      klass = self.class
      !(BaseClass < klass)
""".stripIndent)
  test "registers an offense for comparing snake case constants on the right":
    expectOffense("""      klass = self.class
      !(klass < FOO_BAR)
      ^^^^^^^^^^^^^^^^^^ Use `>=` instead of inverting `<`.
""".stripIndent)
  test "registers an offense for comparing snake case constants on the left":
    expectOffense("""      klass = self.class
      !(FOO_BAR < klass)
      ^^^^^^^^^^^^^^^^^^ Use `>=` instead of inverting `<`.
""".stripIndent)
  context("inverse blocks", proc (): void =
    for method, inverse in {"select": "reject", "reject": "select",
                        "select!": "reject!", "reject!": "select!"}.newTable():
      test """registers an offense for foo.(lvar :method) { |e| !e }""":
        inspectSource("""foo.(lvar :method) { |e| !e }""")
        expect(cop().messages).to(eq(@["""Use `(lvar :inverse)` instead of inverting `(lvar :method)`."""]))
      test """registers an offense for a multiline method call where the last method is inverted""":
        inspectSource("""          foo.(lvar :method) do |e|
            something
            !e.bar
          end
""".stripIndent)
        expect(cop().messages).to(eq(@["""Use `(lvar :inverse)` instead of inverting `(lvar :method)`."""]))
      test "registers an offense for an inverted equality block":
        expectOffense("""          foo.select { |e| e != 2 }
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `reject` instead of inverting `select`.
""".stripIndent)
      test "registers an offense for a multiline inverted equality block":
        inspectSource("""          foo.(lvar :method) do |e|
            something
            something_else
            e != 2
          end
""".stripIndent)
        expect(cop().messages).to(eq(@["""Use `(lvar :inverse)` instead of inverting `(lvar :method)`."""]))
      test "registers a single offense for nested inverse method calls":
        inspectSource("""          y.(lvar :method) { |key, _value| !(key =~ /cd/) }
""".stripIndent)
        expect(cop().messages).to(eq(@["""Use `(lvar :inverse)` instead of inverting `(lvar :method)`."""]))
      test "corrects nested inverse method calls":
        var newSource = autocorrectSource("""y.(lvar :method) { |key, _value| !(key =~ /cd/) }""")
        expect(newSource).to(eq("""y.(lvar :inverse) { |key, _value| (key =~ /cd/) }"""))
      test "corrects a simple inverted block":
        var newSource = autocorrectSource("""foo.(lvar :method) { |e| !e }""")
        expect(newSource).to(eq("""foo.(lvar :inverse) { |e| e }"""))
      test "corrects an inverted method call":
        var newSource = autocorrectSource("""foo.(lvar :method) { |e| !e.bar? }""")
        expect(newSource).to(eq("""foo.(lvar :inverse) { |e| e.bar? }"""))
      test "corrects a complex inverted method call":
        var
          source = """puts 1 if !foo.(lvar :method) { |e| !e.bar? }"""
          newSource = autocorrectSource(source)
        expect(newSource).to(eq("""puts 1 if !foo.(lvar :inverse) { |e| e.bar? }"""))
      test "corrects an inverted do end method call":
        var newSource = autocorrectSource("""          foo.(lvar :method) do |e|
            !e.bar
          end
""".stripIndent)
        expect(newSource).to(eq("""          foo.(lvar :inverse) do |e|
            e.bar
          end
""".stripIndent))
      test "corrects a multiline method call where the last method is inverted":
        var newSource = autocorrectSource("""          foo.(lvar :method) do |e|
            something
            something_else
            !e.bar
          end
""".stripIndent)
        expect(newSource).to(eq("""          foo.(lvar :inverse) do |e|
            something
            something_else
            e.bar
          end
""".stripIndent))
      test "corrects an offense for an inverted equality block":
        var newSource = autocorrectSource("""foo.(lvar :method) { |e| e != 2 }""")
        expect(newSource).to(eq("""foo.(lvar :inverse) { |e| e == 2 }"""))
      test "corrects an offense for a multiline inverted equality block":
        var newSource = autocorrectSource("""          foo.(lvar :method) do |e|
            something
            something_else
            e != 2
          end
""".stripIndent)
        expect(newSource).to(eq("""          foo.(lvar :inverse) do |e|
            something
            something_else
            e == 2
          end
""".stripIndent)))
