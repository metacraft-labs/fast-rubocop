
import
  inefficient_hash_search, test_tools

suite "InefficientHashSearch":
  var cop = InefficientHashSearch()
  sharedExamples("correct behavior", proc (expected: Symbol): void =
    let("expected_key_method", proc (): void =
      if expected == "short":
        "key?"
    )
    let("expected_value_method", proc (): void =
      if expected == "short":
        "value?"
    )
    test "registers an offense when a hash literal receives `keys.include?`":
      expectOffense("""        { a: 1 }.keys.include? 1
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `#(send nil :expected_key_method)` instead of `#keys.include?`.
""".stripIndent)
    test "registers an offense when an existing hash receives `keys.include?`":
      expectOffense("""        h = { a: 1 }; h.keys.include? 1
                      ^^^^^^^^^^^^^^^^^ Use `#(send nil :expected_key_method)` instead of `#keys.include?`.
""".stripIndent)
    test "registers an offense when a hash literal receives `values.include?`":
      expectOffense("""        { a: 1 }.values.include? 1
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `#(send nil :expected_value_method)` instead of `#values.include?`.
""".stripIndent)
    test "registers an offense when a hash variable receives `values.include?`":
      expectOffense("""        h = { a: 1 }; h.values.include? 1
                      ^^^^^^^^^^^^^^^^^^^ Use `#(send nil :expected_value_method)` instead of `#values.include?`.
""".stripIndent)
    test "finds no offense when a `keys` array variable receives `include?`":
      expectNoOffenses("        h = { a: 1 }; keys = h.keys ; keys.include? 1\n".stripIndent)
    test "finds no offense when a `values` array variable receives `include?` ":
      expectNoOffenses("        h = { a: 1 }; values = h.values ; values.include? 1\n".stripIndent)
    test """does not register an offense when `keys` method defined by itself and `include?` method are method chaining""":
      expectNoOffenses("""        def my_include?(key)
          keys.include?(key)
        end
""".stripIndent)
    describe("autocorrect", proc (): void =
      context("when using `keys.include?`", proc (): void =
        test "corrects to `key?` or `has_key?`":
          var newSource = autocorrectSource("{ a: 1 }.keys.include?(1)")
          expect(newSource).to(eq("""{ a: 1 }.(send nil :expected_key_method)(1)"""))
        test "corrects when hash is not a literal":
          var newSource = autocorrectSource("h = { a: 1 }; h.keys.include?(1)")
          expect(newSource).to(eq("""h = { a: 1 }; h.(send nil :expected_key_method)(1)"""))
        test "gracefully handles whitespace":
          var newSource = autocorrectSource("{ a: 1 }.  keys.\ninclude?  1")
          expect(newSource).to(eq("""{ a: 1 }.(send nil :expected_key_method)(1)""")))
      context("when using `values.include?`", proc (): void =
        test "corrects to `value?` or `has_value?`":
          var newSource = autocorrectSource("{ a: 1 }.values.include?(1)")
          expect(newSource).to(eq("""{ a: 1 }.(send nil :expected_value_method)(1)"""))
        test "corrects when hash is not a literal":
          var newSource = autocorrectSource("h = { a: 1 }; h.values.include?(1)")
          expect(newSource).to(eq("""h = { a: 1 }; h.(send nil :expected_value_method)(1)"""))
        test "gracefully handles whitespace":
          var newSource = autocorrectSource("{ a: 1 }.  values.\ninclude?  1")
          expect(newSource).to(eq("""{ a: 1 }.(send nil :expected_value_method)(1)""")))))
  context("when config is empty", proc (): void =
    let("config", proc (): void =
      Config.new)
    itBehavesLike("correct behavior", "short"))
  context("when config enforces short hash methods", proc (): void =
    let("config", proc (): void =
      Config.new())
    itBehavesLike("correct behavior", "short"))
  context("when config specifies long hash methods but is not enabled", proc (): void =
    let("config", proc (): void =
      Config.new())
    itBehavesLike("correct behavior", "short"))
  context("when config enforces long hash methods", proc (): void =
    let("config", proc (): void =
      Config.new())
    itBehavesLike("correct behavior", "long"))
