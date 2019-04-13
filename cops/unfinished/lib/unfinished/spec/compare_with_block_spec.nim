
import
  compare_with_block, test_tools

suite "CompareWithBlock":
  var cop = CompareWithBlock()
  sharedExamples("compare with block", proc (method: string): void =
    test """registers an offense for (lvar :method)""":
      inspectSource("""array.(lvar :method) { |a, b| a.foo <=> b.foo }""")
      expect(cop().offenses.size).to(eq(1))
    test """registers an offense for (lvar :method) with [:foo]""":
      inspectSource("""array.(lvar :method) { |a, b| a[:foo] <=> b[:foo] }""")
      expect(cop().offenses.size).to(eq(1))
    test """registers an offense for (lvar :method) with ['foo']""":
      inspectSource("""array.(lvar :method) { |a, b| a['foo'] <=> b['foo'] }""")
      expect(cop().offenses.size).to(eq(1))
    test """registers an offense for (lvar :method) with [1]""":
      inspectSource("""array.(lvar :method) { |a, b| a[1] <=> b[1] }""")
      expect(cop().offenses.size).to(eq(1))
    test "highlights compare method":
      inspectSource("""array.(lvar :method) { |a, b| a.foo <=> b.foo }""")
      expect(cop().highlights).to(eq(@["""(lvar :method) { |a, b| a.foo <=> b.foo }"""]))
    test """accepts valid (lvar :method) usage""":
      expectNoOffenses("""array.(lvar :method) { |a, b| b <=> a }""")
    test """accepts (lvar :method)_by""":
      expectNoOffenses("""array.(lvar :method)_by { |a| a.baz }""")
    test """autocorrects array.(lvar :method) { |a, b| a.foo <=> b.foo }""":
      var newSource = autocorrectSource("""array.(lvar :method) { |a, b| a.foo <=> b.foo }""")
      expect(newSource).to(eq("""array.(lvar :method)_by(&:foo)"""))
    test """autocorrects array.(lvar :method) { |a, b| a.bar <=> b.bar }""":
      var newSource = autocorrectSource("""array.(lvar :method) { |a, b| a.bar <=> b.bar }""")
      expect(newSource).to(eq("""array.(lvar :method)_by(&:bar)"""))
    test """autocorrects array.(lvar :method) { |x, y| x.foo <=> y.foo }""":
      var newSource = autocorrectSource("""array.(lvar :method) { |x, y| x.foo <=> y.foo }""")
      expect(newSource).to(eq("""array.(lvar :method)_by(&:foo)"""))
    test """autocorrects array.(lvar :method) do |a, b| a.foo <=> b.foo end""":
      var newSource = autocorrectSource("""        array.(lvar :method) do |a, b|
          a.foo <=> b.foo
        end
""".stripIndent)
      expect(newSource).to(eq("""array.(lvar :method)_by(&:foo)
"""))
    test """autocorrects array.(lvar :method) { |a, b| a[:foo] <=> b[:foo] }""":
      var newSource = autocorrectSource("""array.(lvar :method) { |a, b| a[:foo] <=> b[:foo] }""")
      expect(newSource).to(eq("""array.(lvar :method)_by { |a| a[:foo] }"""))
    test """autocorrects array.(lvar :method) { |a, b| a['foo'] <=> b['foo'] }""":
      var newSource = autocorrectSource("""array.(lvar :method) { |a, b| a['foo'] <=> b['foo'] }""")
      expect(newSource).to(eq("""array.(lvar :method)_by { |a| a['foo'] }"""))
    test """autocorrects array.(lvar :method) { |a, b| a[1] <=> b[1] }""":
      var newSource = autocorrectSource("""array.(lvar :method) { |a, b| a[1] <=> b[1] }""")
      expect(newSource).to(eq("""array.(lvar :method)_by { |a| a[1] }"""))
    test """formats the error message correctly for (str "array.")""":
      inspectSource("""array.(lvar :method) { |a, b| a.foo <=> b.foo }""")
      expect(cop().messages).to(eq(@["""(str "Use `")(str "`")"""]))
    test """formats the error message correctly for (str "array.")""":
      inspectSource("""array.(lvar :method) { |a, b| a[:foo] <=> b[:foo] }""")
      var expected = @["""(str "Use `")(str "`")"""]
      expect(cop().messages).to(eq(expected)))
  includeExamples("compare with block", "sort")
  includeExamples("compare with block", "max")
  includeExamples("compare with block", "min")
