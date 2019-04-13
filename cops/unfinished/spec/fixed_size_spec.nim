
import
  fixed_size, test_tools

suite "FixedSize":
  var cop = FixedSize()
  let("message", proc (): void =
    "Do not compute the size of statically sized objects.")
  sharedExamples("common functionality", proc (method: string): void =
    context("strings", proc (): void =
      test """(str "registers an offense when calling ")string""":
        inspectSource("""'a'.(lvar :method)""")
        expect(cop().messages).to(eq(@[message()]))
      test """(str "registers an offense when calling ")string""":
        inspectSource(""""a".(lvar :method)""")
        expect(cop().messages).to(eq(@[message()]))
      test """registers an offense when calling (lvar :method) on a %q string""":
        inspectSource("""%q(a).(lvar :method)""")
        expect(cop().messages).to(eq(@[message()]))
      test """registers an offense when calling (lvar :method) on a %Q string""":
        inspectSource("""%Q(a).(lvar :method)""")
        expect(cop().messages).to(eq(@[message()]))
      test """registers an offense when calling (lvar :method) on a % string""":
        inspectSource("""%(a).(lvar :method)""")
        expect(cop().messages).to(eq(@[message()]))
      test """(str "accepts calling ")contains interpolation""":
        expectNoOffenses(""""#{foo}".(lvar :method)""")
      test """(str "accepts calling ")interpolation""":
        expectNoOffenses("""%Q(#{foo}).(lvar :method)""")
      test """(str "accepts calling ")interpolation""":
        expectNoOffenses("""%(#{foo}).(lvar :method)""")
      test """(str "accepts calling ")is assigned to a constant""":
        expectNoOffenses("""CONST = 'a'.(lvar :method)""")
      test """(str "accepts calling ")is assigned to a constant""":
        expectNoOffenses("""CONST = "a".(lvar :method)""")
      test """(str "accepts calling ")a constant""":
        expectNoOffenses("""CONST = %q(a).(lvar :method)""")
      test """accepts calling (lvar :method) on a variable """:
        expectNoOffenses("""          foo = "abc"
          foo.(lvar :method)
""".stripIndent))
    context("symbols", proc (): void =
      test """registers an offense when calling (lvar :method) on a symbol""":
        inspectSource(""":foo.(lvar :method)""")
        expect(cop().messages).to(eq(@[message()]))
      test """registers an offense when calling (lvar :method) on a quoted symbol""":
        inspectSource(""":'foo-bar'.(lvar :method)""")
        expect(cop().messages).to(eq(@[message()]))
      test """accepts calling (lvar :method) on an interpolated quoted symbol""":
        expectNoOffenses(""":"foo-#{bar}".(lvar :method)""")
      test """registers an offense when calling (lvar :method) on %s""":
        inspectSource("""%s(foo-bar).(lvar :method)""")
        expect(cop().messages).to(eq(@[message()]))
      test """(str "accepts calling ")to a constant""":
        expectNoOffenses("""CONST = :foo.(lvar :method)"""))
    context("arrays", proc (): void =
      test """registers an offense when calling (lvar :method) on an array using []""":
        inspectSource("""[1, 2, foo].(lvar :method)""")
        expect(cop().messages).to(eq(@[message()]))
      test """registers an offense when calling (lvar :method) on an array using %w""":
        inspectSource("""%w(1, 2, foo).(lvar :method)""")
        expect(cop().messages).to(eq(@[message()]))
      test """registers an offense when calling (lvar :method) on an array using %W""":
        inspectSource("""%W(1, 2, foo).(lvar :method)""")
        expect(cop().messages).to(eq(@[message()]))
      test """(str "accepts calling ")a splat""":
        expectNoOffenses("""[1, 2, *foo].(lvar :method)""")
      test """accepts calling (lvar :method) on array that is set to a variable""":
        expectNoOffenses("""          foo = [1, 2, 3]
          foo.(lvar :method)
""".stripIndent)
      test """(str "accepts calling ")to a constant""":
        expectNoOffenses("""CONST = [1, 2, 3].(lvar :method)"""))
    context("hashes", proc (): void =
      test """registers an offense when calling (lvar :method) on a hash using {}""":
        inspectSource("""{a: 1, b: 2}.(lvar :method)""")
        expect(cop().messages).to(eq(@[message()]))
      test """accepts calling (lvar :method) on a hash set to a variable""":
        expectNoOffenses("""          foo = {a: 1, b: 2}
          foo.(lvar :method)
""".stripIndent)
      test """accepts calling (lvar :method) on a hash that contains a double splat""":
        expectNoOffenses("""{a: 1, **foo}.(lvar :method)""")
      test """(str "accepts calling ")to a constant""":
        expectNoOffenses("""CONST = {a: 1, b: 2}.(lvar :method)""")))
  itBehavesLike("common functionality", "size")
  itBehavesLike("common functionality", "length")
  itBehavesLike("common functionality", "count")
  sharedExamples("count with arguments", proc (variable: string): void =
    test "accepts calling count with a variable":
      expectNoOffenses("""(lvar :variable).count(bar)""")
    test "accepts calling count with an instance variable":
      expectNoOffenses("""(lvar :variable).count(@bar)""")
    test "registers an offense when calling count with a string":
      inspectSource("""(lvar :variable).count('o')""")
      expect(cop().messages).to(eq(@[message()]))
    test "accepts calling count with a block":
      expectNoOffenses("""(lvar :variable).count { |v| v == 'a' }""")
    test "accepts calling count with a symbol proc":
      expectNoOffenses("""(lvar :variable).count(&:any?) """))
  itBehavesLike("count with arguments", "\"foo\"")
  itBehavesLike("count with arguments", "[1, 2, 3]")
  itBehavesLike("count with arguments", "{a: 1, b: 2}")
