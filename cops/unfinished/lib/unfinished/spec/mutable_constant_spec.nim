
import
  mutable_constant, test_tools

RSpec.describe(MutableConstant, "config", proc (): void =
  var cop = ()
  let("prefix", proc (): void =
  )
  sharedExamples("mutable objects", proc (o: string): void =
    context("when assigning with =", proc (): void =
      test """registers an offense for (lvar :o) assigned to a constant""":
        var source = (prefix(), """CONST = (lvar :o)""").compact().join("\n")
        inspectSource(source)
        expect(cop().offenses.size).to(eq(1))
      test "auto-corrects by adding .freeze":
        var
          source = (prefix(), """CONST = (lvar :o)""").compact().join("\n")
          newSource = autocorrectSource(source)
        expect(newSource).to(eq("""(lvar :source).freeze""")))
    context("when assigning with ||=", proc (): void =
      test """registers an offense for (lvar :o) assigned to a constant""":
        var source = (prefix(), """CONST ||= (lvar :o)""").compact().join("\n")
        inspectSource(source)
        expect(cop().offenses.size).to(eq(1))
      test "auto-corrects by adding .freeze":
        var
          source = (prefix(), """CONST ||= (lvar :o)""").compact().join("\n")
          newSource = autocorrectSource(source)
        expect(newSource).to(eq("""(lvar :source).freeze"""))))
  sharedExamples("immutable objects", proc (o: string): void =
    test """allows (lvar :o) to be assigned to a constant""":
      var source = (prefix(), """CONST = (lvar :o)""").compact().join("\n")
      expectNoOffenses(source)
    test """allows (lvar :o) to be ||= to a constant""":
      var source = (prefix(), """CONST ||= (lvar :o)""").compact().join("\n")
      expectNoOffenses(source))
  context("Strict: false", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "literals"}.newTable())
    itBehavesLike("mutable objects", "[1, 2, 3]")
    itBehavesLike("mutable objects", "%w(a b c)")
    itBehavesLike("mutable objects", "{ a: 1, b: 2 }")
    itBehavesLike("mutable objects", "\'str\'")
    itBehavesLike("mutable objects", "\"top#{1 + 2}\"")
    itBehavesLike("immutable objects", "1")
    itBehavesLike("immutable objects", "1.5")
    itBehavesLike("immutable objects", ":sym")
    itBehavesLike("immutable objects", "FOO + BAR")
    itBehavesLike("immutable objects", "FOO - BAR")
    itBehavesLike("immutable objects", "\'foo\' + \'bar\'")
    itBehavesLike("immutable objects", "ENV[\'foo\']")
    test "allows method call assignments":
      expectNoOffenses("TOP_TEST = Something.new")
    context("splat expansion", proc (): void =
      context("expansion of a range", proc (): void =
        test "registers an offense":
          expectOffense("""            FOO = *1..10
                  ^^^^^^ Freeze mutable objects assigned to constants.
""".stripIndent)
        test "correct to use to_a.freeze":
          var newSource = autocorrectSource("FOO = *1..10")
          expect(newSource).to(eq("FOO = (1..10).to_a.freeze"))
        context("with parentheses", proc (): void =
          test "registers an offense":
            expectOffense("""              FOO = *(1..10)
                    ^^^^^^^^ Freeze mutable objects assigned to constants.
""".stripIndent)
          test "correct to use to_a.freeze":
            var newSource = autocorrectSource("FOO = *(1..10)")
            expect(newSource).to(eq("FOO = (1..10).to_a.freeze")))))
    context("when assigning an array without brackets", proc (): void =
      test "adds brackets when auto-correcting":
        var newSource = autocorrectSource("XXX = YYY, ZZZ")
        expect(newSource).to(eq("XXX = [YYY, ZZZ].freeze"))
      test "does not add brackets to %w() arrays":
        var newSource = autocorrectSource("XXX = %w(YYY ZZZ)")
        expect(newSource).to(eq("XXX = %w(YYY ZZZ).freeze")))
    context("when assigning a range (irange) without parenthesis", proc (): void =
      test "adds parenthesis when auto-correcting":
        var newSource = autocorrectSource("XXX = 1..99")
        expect(newSource).to(eq("XXX = (1..99).freeze"))
      test "does not add parenthesis to range enclosed in parentheses":
        var newSource = autocorrectSource("XXX = (1..99)")
        expect(newSource).to(eq("XXX = (1..99).freeze")))
    context("when assigning a range (erange) without parenthesis", proc (): void =
      test "adds parenthesis when auto-correcting":
        var newSource = autocorrectSource("XXX = 1...99")
        expect(newSource).to(eq("XXX = (1...99).freeze"))
      test "does not add parenthesis to range enclosed in parentheses":
        var newSource = autocorrectSource("XXX = (1...99)")
        expect(newSource).to(eq("XXX = (1...99).freeze")))
    context("when the constant is a frozen string literal", proc (): void =
      if KNOWNRUBIES.isInclude(0.0):
        context("when the target ruby version >= 3.0", proc (): void =
          let("ruby_version", proc (): void =
            0.0)
          context("when the frozen string literal comment is missing", proc (): void =
            itBehavesLike("immutable objects", "\"#{a}\""))
          context("when the frozen string literal comment is true", proc (): void =
            let("prefix", proc (): void =
              "# frozen_string_literal: true")
            itBehavesLike("immutable objects", "\"#{a}\""))
          context("when the frozen string literal comment is false", proc (): void =
            let("prefix", proc (): void =
              "# frozen_string_literal: false")
            itBehavesLike("immutable objects", "\"#{a}\"")))
      context("when the target ruby version >= 2.3", proc (): void =
        let("ruby_version", proc (): void =
          0.0)
        context("when the frozen string literal comment is missing", proc (): void =
          itBehavesLike("mutable objects", "\"#{a}\""))
        context("when the frozen string literal comment is true", proc (): void =
          let("prefix", proc (): void =
            "# frozen_string_literal: true")
          itBehavesLike("immutable objects", "\"#{a}\""))
        context("when the frozen string literal comment is false", proc (): void =
          let("prefix", proc (): void =
            "# frozen_string_literal: false")
          itBehavesLike("mutable objects", "\"#{a}\"")))))
  context("Strict: true", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "strict"}.newTable())
    itBehavesLike("mutable objects", "[1, 2, 3]")
    itBehavesLike("mutable objects", "%w(a b c)")
    itBehavesLike("mutable objects", "{ a: 1, b: 2 }")
    itBehavesLike("mutable objects", "\'str\'")
    itBehavesLike("mutable objects", "\"top#{1 + 2}\"")
    itBehavesLike("mutable objects", "Something.new")
    itBehavesLike("immutable objects", "1")
    itBehavesLike("immutable objects", "1.5")
    itBehavesLike("immutable objects", ":sym")
    itBehavesLike("immutable objects", "ENV[\'foo\']")
    itBehavesLike("immutable objects", "OTHER_CONST")
    itBehavesLike("immutable objects", "Namespace::OTHER_CONST")
    itBehavesLike("immutable objects", "Struct.new")
    itBehavesLike("immutable objects", "Struct.new(:a, :b)")
    itBehavesLike("immutable objects", """      Struct.new(:node) do
        def assignment?
          true
        end
      end
""".stripIndent)
    test "allows calls to freeze":
      expectNoOffenses("        CONST = [1].freeze\n".stripIndent)
    context("splat expansion", proc (): void =
      context("expansion of a range", proc (): void =
        test "registers an offense":
          expectOffense("""            FOO = *1..10
                  ^^^^^^ Freeze mutable objects assigned to constants.
""".stripIndent)
        test "correct to use to_a.freeze":
          var newSource = autocorrectSource("FOO = *1..10")
          expect(newSource).to(eq("FOO = (1..10).to_a.freeze"))
        context("with parentheses", proc (): void =
          test "registers an offense":
            expectOffense("""              FOO = *(1..10)
                    ^^^^^^^^ Freeze mutable objects assigned to constants.
""".stripIndent)
          test "correct to use to_a.freeze":
            var newSource = autocorrectSource("FOO = *(1..10)")
            expect(newSource).to(eq("FOO = (1..10).to_a.freeze")))))
    context("when assigning with an operator", proc (): void =
      sharedExamples("operator methods", proc (o: string): void =
        test "registers an offense":
          inspectSource("""CONST = FOO (lvar :o) BAR""")
          expect(cop().offenses.size).to(eq(1))
          expect(cop().highlights).to(eq(@["""FOO (lvar :o) BAR"""]))
        test "corrects by wrapping in parentheses and calling freeze":
          var newSource = autocorrectSource("""            CONST = FOO (lvar :o) BAR
""".stripIndent)
          expect(newSource).to(eq("""            CONST = (FOO (lvar :o) BAR).freeze
""".stripIndent)))
      itBehavesLike("operator methods", "+")
      itBehavesLike("operator methods", "-")
      itBehavesLike("operator methods", "*")
      itBehavesLike("operator methods", "/")
      itBehavesLike("operator methods", "%")
      itBehavesLike("operator methods", "**"))
    context("when assigning with multiple operator calls", proc (): void =
      test "registers an offense":
        expectOffense("""          FOO = [1].freeze
          BAR = [2].freeze
          BAZ = [3].freeze
          CONST = FOO + BAR + BAZ
                  ^^^^^^^^^^^^^^^ Freeze mutable objects assigned to constants.
""".stripIndent)
      test "corrects by wrapping in parens and calling freeze":
        var newSource = autocorrectSource("""          FOO = [1].freeze
          BAR = [2].freeze
          BAZ = [3].freeze
          CONST = FOO + BAR + BAZ
""".stripIndent)
        expect(newSource).to(eq("""          FOO = [1].freeze
          BAR = [2].freeze
          BAZ = [3].freeze
          CONST = (FOO + BAR + BAZ).freeze
""".stripIndent)))
    context("methods and operators that produce frozen objects", proc (): void =
      test "accepts assigning to an environment variable with a fallback":
        expectNoOffenses("          CONST = ENV[\'foo\'] || \'foo\'\n".stripIndent)
      test "accepts operating on a constant and an interger":
        expectNoOffenses("          CONST = FOO + 2\n".stripIndent)
      test "accepts operating on multiple integers":
        expectNoOffenses("          CONST = 1 + 2\n".stripIndent)
      test "accepts operating on a constant and a float":
        expectNoOffenses("          CONST = FOO + 2.1\n".stripIndent)
      test "accepts operating on multiple floats":
        expectNoOffenses("          CONST = 1.2 + 2.1\n".stripIndent)
      test "accepts comparison operators":
        expectNoOffenses("          CONST = FOO == BAR\n".stripIndent)
      test "accepts checking fixed size":
        expectNoOffenses("""          CONST = 'foo'.count
          CONST = 'foo'.count('f')
          CONST = [1, 2, 3].count { |n| n > 2 }
          CONST = [1, 2, 3].count(2) { |n| n > 2 }
          CONST = 'foo'.length
          CONST = 'foo'.size
""".stripIndent))
    context("operators that produce unfrozen objects", proc (): void =
      test "registers an offense when operating on a constant and a string":
        expectOffense("""          CONST = FOO + 'bar'
                  ^^^^^^^^^^^ Freeze mutable objects assigned to constants.
""".stripIndent)
      test "registers an offense when operating on multiple strings":
        expectOffense("""          CONST = 'foo' + 'bar' + 'baz'
                  ^^^^^^^^^^^^^^^^^^^^^ Freeze mutable objects assigned to constants.
""".stripIndent))
    context("when assigning an array without brackets", proc (): void =
      test "adds brackets when auto-correcting":
        var newSource = autocorrectSource("XXX = YYY, ZZZ")
        expect(newSource).to(eq("XXX = [YYY, ZZZ].freeze"))
      test "does not add brackets to %w() arrays":
        var newSource = autocorrectSource("XXX = %w(YYY ZZZ)")
        expect(newSource).to(eq("XXX = %w(YYY ZZZ).freeze")))
    test "freezes a heredoc":
      var newSource = autocorrectSource("""        FOO = <<-HERE
          SOMETHING
        HERE
""".stripIndent)
      expect(newSource).to(eq("""        FOO = <<-HERE.freeze
          SOMETHING
        HERE
""".stripIndent))
    context("when the target ruby version >= 2.3", proc (): void =
      let("ruby_version", proc (): void =
        0.0)
      context("when the frozen string literal comment is missing", proc (): void =
        itBehavesLike("mutable objects", "\"#{a}\""))
      context("when the frozen string literal comment is true", proc (): void =
        let("prefix", proc (): void =
          "# frozen_string_literal: true")
        itBehavesLike("immutable objects", "\"#{a}\""))
      context("when the frozen string literal comment is false", proc (): void =
        let("prefix", proc (): void =
          "# frozen_string_literal: false")
        itBehavesLike("mutable objects", "\"#{a}\"")))))
