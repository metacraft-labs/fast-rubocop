
import
  count, test_tools

suite "Count":
  var cop = Count()
  sharedExamples("selectors", proc (selector: string): void =
    test """registers an offense for using array.(lvar :selector)...size""":
      inspectSource("""[1, 2, 3].(lvar :selector) { |e| e.even? }.size""")
      expect(cop().messages).to(eq(@["""Use `count` instead of `(lvar :selector)...size`."""]))
      expect(cop().highlights).to(eq(@["""(lvar :selector) { |e| e.even? }.size"""]))
    test """registers an offense for using hash.(lvar :selector)...size""":
      inspectSource("""{a: 1, b: 2, c: 3}.(lvar :selector) { |e| e == :a }.size""")
      expect(cop().messages).to(eq(@["""Use `count` instead of `(lvar :selector)...size`."""]))
      expect(cop().highlights).to(eq(@["""(lvar :selector) { |e| e == :a }.size"""]))
    test """registers an offense for using array.(lvar :selector)...length""":
      inspectSource("""[1, 2, 3].(lvar :selector) { |e| e.even? }.length""")
      expect(cop().messages).to(eq(@["""Use `count` instead of `(lvar :selector)...length`."""]))
      expect(cop().highlights).to(eq(@["""(lvar :selector) { |e| e.even? }.length"""]))
    test """registers an offense for using hash.(lvar :selector)...length""":
      inspectSource("""{a: 1, b: 2}.(lvar :selector) { |e| e == :a }.length""")
      expect(cop().messages).to(eq(@["""Use `count` instead of `(lvar :selector)...length`."""]))
      expect(cop().highlights).to(eq(@["""(lvar :selector) { |e| e == :a }.length"""]))
    test """registers an offense for using array.(lvar :selector)...count""":
      inspectSource("""[1, 2, 3].(lvar :selector) { |e| e.even? }.count""")
      expect(cop().messages).to(eq(@["""Use `count` instead of `(lvar :selector)...count`."""]))
      expect(cop().highlights).to(eq(@["""(lvar :selector) { |e| e.even? }.count"""]))
    test """registers an offense for using hash.(lvar :selector)...count""":
      inspectSource("""{a: 1, b: 2}.(lvar :selector) { |e| e == :a }.count""")
      expect(cop().messages).to(eq(@["""Use `count` instead of `(lvar :selector)...count`."""]))
      expect(cop().highlights).to(eq(@["""(lvar :selector) { |e| e == :a }.count"""]))
    test """allows usage of (lvar :selector)...count with a block on an array""":
      expectNoOffenses("""        [1, 2, 3].(lvar :selector) { |e| e.odd? }.count { |e| e > 2 }
""".stripIndent)
    test """allows usage of (lvar :selector)...count with a block on a hash""":
      expectNoOffenses("""        {a: 1, b: 2}.(lvar :selector) { |e| e == :a }.count { |e| e > 2 }
""".stripIndent)
    test """registers an offense for (lvar :selector) with params instead of a block""":
      inspectSource("""        Data = Struct.new(:value)
        array = [Data.new(2), Data.new(3), Data.new(2)]
        puts array.(lvar :selector)(&:value).count
""".stripIndent)
      expect(cop().messages).to(eq(@["""Use `count` instead of `(lvar :selector)...count`."""]))
      expect(cop().highlights).to(eq(@["""(lvar :selector)(&:value).count"""]))
    test """registers an offense for (lvar :selector)(&:something).count""":
      inspectSource("""foo.(lvar :selector)(&:something).count""")
      expect(cop().messages).to(eq(@["""Use `count` instead of `(lvar :selector)...count`."""]))
      expect(cop().highlights).to(eq(@["""(lvar :selector)(&:something).count"""]))
    test """(str "registers an offense for ")when called as an instance method on its own class""":
      var source = """        class A < Array
          def count(&block)
            (lvar :selector)(&block).count
          end
        end
""".stripIndent
      inspectSource(source)
      expect(cop().messages).to(eq(@["""Use `count` instead of `(lvar :selector)...count`."""]))
      expect(cop().highlights).to(eq(@["""(lvar :selector)(&block).count"""]))
    test """allows usage of (lvar :selector) without getting the size""":
      expectNoOffenses("""[1, 2, 3].(lvar :selector) { |e| e.even? }""")
    context("bang methods", proc (): void =
      test """allows usage of (lvar :selector)!...size""":
        expectNoOffenses("""[1, 2, 3].(lvar :selector)! { |e| e.odd? }.size""")
      test """allows usage of (lvar :selector)!...count""":
        expectNoOffenses("""[1, 2, 3].(lvar :selector)! { |e| e.odd? }.count""")
      test """allows usage of (lvar :selector)!...length""":
        expectNoOffenses("""[1, 2, 3].(lvar :selector)! { |e| e.odd? }.length""")))
  itBehavesLike("selectors", "select")
  itBehavesLike("selectors", "reject")
  context("ActiveRecord select", proc (): void =
    test "allows usage of select with a string":
      expectNoOffenses("Model.select(\'field AS field_one\').count")
    test "allows usage of select with multiple strings":
      expectNoOffenses("        Model.select(\'field AS field_one\', \'other AS field_two\').count\n".stripIndent)
    test "allows usage of select with a symbol":
      expectNoOffenses("Model.select(:field).count")
    test "allows usage of select with multiple symbols":
      expectNoOffenses("Model.select(:field, :other_field).count"))
  test "allows usage of another method with size":
    expectNoOffenses("[1, 2, 3].map { |e| e + 1 }.size")
  test "allows usage of size on an array":
    expectNoOffenses("[1, 2, 3].size")
  test "allows usage of count on an array":
    expectNoOffenses("[1, 2, 3].count")
  test "allows usage of count on an interstitial method called on select":
    expectNoOffenses("""      Data = Struct.new(:value)
      array = [Data.new(2), Data.new(3), Data.new(2)]
      puts array.select(&:value).uniq.count
""".stripIndent)
  test """allows usage of count on an interstitial method with blocks called on select""":
    expectNoOffenses("""      Data = Struct.new(:value)
      array = [Data.new(2), Data.new(3), Data.new(2)]
      array.select(&:value).uniq { |v| v > 2 }.count
""".stripIndent)
  test "allows usage of size called on an assigned variable":
    expectNoOffenses("""      nodes = [1]
      nodes.size
""".stripIndent)
  test "allows usage of methods called on size":
    expectNoOffenses("shorter.size.to_f")
  context("properly parses non related code", proc (): void =
    test "will not raise an error for Bundler.setup":
      expect(proc (): void =
        inspectSource("Bundler.setup(:default, :development)")).notTo(raiseError)
    test "will not raise an error for RakeTask.new":
      expect(proc (): void =
        inspectSource("RakeTask.new(:spec)")).notTo(raiseError))
  context("autocorrect", proc (): void =
    context("will correct", proc (): void =
      test "select..size to count":
        var newSource = autocorrectSource("[1, 2].select { |e| e > 2 }.size")
        expect(newSource).to(eq("[1, 2].count { |e| e > 2 }"))
      test "select..count without a block to count":
        var newSource = autocorrectSource("[1, 2].select { |e| e > 2 }.count")
        expect(newSource).to(eq("[1, 2].count { |e| e > 2 }"))
      test "select..length to count":
        var newSource = autocorrectSource("[1, 2].select { |e| e > 2 }.length")
        expect(newSource).to(eq("[1, 2].count { |e| e > 2 }"))
      test "select...size when select has parameters":
        var
          source = """          Data = Struct.new(:value)
          array = [Data.new(2), Data.new(3), Data.new(2)]
          puts array.select(&:value).size
""".stripIndent
          newSource = autocorrectSource(source)
        expect(newSource).to(eq("""            Data = Struct.new(:value)
            array = [Data.new(2), Data.new(3), Data.new(2)]
            puts array.count(&:value)
""".stripIndent)))
    describe("will not correct", proc (): void =
      test "reject...size":
        var newSource = autocorrectSource("[1, 2].reject { |e| e > 2 }.size")
        expect(newSource).to(eq("[1, 2].reject { |e| e > 2 }.size"))
      test "reject...count":
        var newSource = autocorrectSource("[1, 2].reject { |e| e > 2 }.count")
        expect(newSource).to(eq("[1, 2].reject { |e| e > 2 }.count"))
      test "reject...length":
        var newSource = autocorrectSource("[1, 2].reject { |e| e > 2 }.length")
        expect(newSource).to(eq("[1, 2].reject { |e| e > 2 }.length"))
      test "select...count when count has a block":
        var
          source = "[1, 2].select { |e| e > 2 }.count { |e| e.even? }"
          newSource = autocorrectSource(source)
        expect(newSource).to(eq(source))
      test "reject...size when select has parameters":
        var
          source = """          Data = Struct.new(:value)
          array = [Data.new(2), Data.new(3), Data.new(2)]
          puts array.reject(&:value).size
""".stripIndent
          newSource = autocorrectSource(source)
        expect(newSource).to(eq(source))))
  context("SafeMode true", proc (): void =
    var cop = Count()
    let("config", proc (): void =
      Config.new())
    sharedExamples("selectors", proc (selector: string): void =
      test """allows using array.(lvar :selector)...size""":
        expectNoOffenses("""[1, 2, 3].(lvar :selector) { |e| e.even? }.size"""))
    itBehavesLike("selectors", "select")
    itBehavesLike("selectors", "reject"))
