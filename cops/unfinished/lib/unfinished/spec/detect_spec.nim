
import
  tables

import
  detect, test_tools

suite "Detect":
  var cop = Detect()
  let("collection_method", proc (): void =
  )
  let("config", proc (): void =
    Config.new())
  var selectMethods = @["select", "find_all"].freeze()
  for method in selectMethods:
    test """registers an offense when first is called on (lvar :method)""":
      inspectSource("""[1, 2, 3].(lvar :method) { |i| i % 2 == 0 }.first""")
      expect(cop().messages).to(eq(@["""Use `detect` instead of `(lvar :method).first`."""]))
    test """doesn't register an offense when first(n) is called on (lvar :method)""":
      expectNoOffenses("""[1, 2, 3].(lvar :method) { |i| i % 2 == 0 }.first(n)""")
    test """registers an offense when last is called on (lvar :method)""":
      inspectSource("""[1, 2, 3].(lvar :method) { |i| i % 2 == 0 }.last""")
      expect(cop().messages).to(eq(@["""Use `reverse.detect` instead of `(lvar :method).last`."""]))
    test """doesn't register an offense when last(n) is called on (lvar :method)""":
      expectNoOffenses("""[1, 2, 3].(lvar :method) { |i| i % 2 == 0 }.last(n)""")
    test """registers an offense when first is called on multiline (lvar :method)""":
      inspectSource("""        [1, 2, 3].(lvar :method) do |i|
          i % 2 == 0
        end.first
""".stripIndent)
      expect(cop().messages).to(eq(@["""Use `detect` instead of `(lvar :method).first`."""]))
    test """registers an offense when last is called on multiline (lvar :method)""":
      inspectSource("""        [1, 2, 3].(lvar :method) do |i|
          i % 2 == 0
        end.last
""".stripIndent)
      expect(cop().messages).to(eq(@["""Use `reverse.detect` instead of `(lvar :method).last`."""]))
    test """registers an offense when first is called on (lvar :method) short syntax""":
      inspectSource("""[1, 2, 3].(lvar :method)(&:even?).first""")
      expect(cop().messages).to(eq(@["""Use `detect` instead of `(lvar :method).first`."""]))
    test """registers an offense when last is called on (lvar :method) short syntax""":
      inspectSource("""[1, 2, 3].(lvar :method)(&:even?).last""")
      expect(cop().messages).to(eq(@["""Use `reverse.detect` instead of `(lvar :method).last`."""]))
    test """(str "registers an offense when ")on `lazy` without receiver""":
      inspectSource("""lazy.(lvar :method)(&:even?).first""")
      expect(cop().messages).to(eq(@["""Use `detect` instead of `(lvar :method).first`."""]))
    test """(str "does not register an offense when ")without first or last""":
      expectNoOffenses("""[1, 2, 3].(lvar :method) { |i| i % 2 == 0 }""")
    test """(str "does not register an offense when ")without block or args""":
      expectNoOffenses("""adapter.(lvar :method).first""")
    test """(str "does not register an offense when ")with args but without ampersand syntax""":
      expectNoOffenses("""adapter.(lvar :method)('something').first""")
    test """(str "does not register an offense when ")on lazy enumerable""":
      expectNoOffenses("""adapter.lazy.(lvar :method) { 'something' }.first""")
  test "does not register an offense when detect is used":
    expectNoOffenses("[1, 2, 3].detect { |i| i % 2 == 0 }")
  context("autocorrect", proc (): void =
    sharedExamples("detect_autocorrect", proc (preferredMethod: string): void =
      context("""with (lvar :preferred_method)""", proc (): void =
        let("collection_method", proc (): void =
          preferredMethod)
        for method in selectMethods:
          test """corrects (lvar :method).first to (lvar :preferred_method) (with block)""":
            var
              source = """[1, 2, 3].(lvar :method) { |i| i % 2 == 0 }.first"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""[1, 2, 3].(lvar :preferred_method) { |i| i % 2 == 0 }"""))
          test """(str "corrects ")(with block)""":
            var
              source = """[1, 2, 3].(lvar :method) { |i| i % 2 == 0 }.last"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""[1, 2, 3].reverse.(lvar :preferred_method) { |i| i % 2 == 0 }"""))
          test """corrects (lvar :method).first to (lvar :preferred_method) (short syntax)""":
            var
              source = """[1, 2, 3].(lvar :method)(&:even?).first"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""[1, 2, 3].(lvar :preferred_method)(&:even?)"""))
          test """(str "corrects ")(short syntax)""":
            var
              source = """[1, 2, 3].(lvar :method)(&:even?).last"""
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""[1, 2, 3].reverse.(lvar :preferred_method)(&:even?)"""))
          test """corrects (lvar :method).first to (lvar :preferred_method) (multiline)""":
            var
              source = """              [1, 2, 3].(lvar :method) do |i|
                i % 2 == 0
              end.first
""".stripIndent
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""              [1, 2, 3].(lvar :preferred_method) do |i|
                i % 2 == 0
              end
""".stripIndent))
          test """(str "corrects ")(multiline)""":
            var
              source = """              [1, 2, 3].(lvar :method) do |i|
                i % 2 == 0
              end.last
""".stripIndent
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""                [1, 2, 3].reverse.(lvar :preferred_method) do |i|
                  i % 2 == 0
                end
""".stripIndent))
          test """(str "corrects multiline ")with 'first' on the last line""":
            var
              source = """              [1, 2, 3].(lvar :method) { true }
              .first['x']
""".stripIndent
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""[1, 2, 3].(lvar :preferred_method) { true }['x']
"""))
          test """(str "corrects multiline ")with 'first' on the last line (short syntax)""":
            var
              source = """              [1, 2, 3].(lvar :method)(&:blank?)
              .first['x']
""".stripIndent
              newSource = autocorrectSource(source)
            expect(newSource).to(eq("""[1, 2, 3].(lvar :preferred_method)(&:blank?)['x']
"""))))
    itBehavesLike("detect_autocorrect", "detect")
    itBehavesLike("detect_autocorrect", "find"))
  context("SafeMode true", proc (): void =
    let("config", proc (): void =
      Config.new())
    for method in selectMethods:
      test """doesn't register an offense when first is called on (lvar :method)""":
        expectNoOffenses("""[1, 2, 3].(lvar :method) { |i| i % 2 == 0 }.first"""))
