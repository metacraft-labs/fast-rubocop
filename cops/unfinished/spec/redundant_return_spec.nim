
import
  redundant_return, test_tools

RSpec.describe(RedundantReturn, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"AllowMultipleReturnValues": false}.newTable())
  test "reports an offense for def with only a return":
    expectOffense("""      def func
        return something
        ^^^^^^ Redundant `return` detected.
      ensure
        2
      end
""".stripIndent)
  test "reports an offense for defs with only a return":
    expectOffense("""      def Test.func
        return something
        ^^^^^^ Redundant `return` detected.
      end
""".stripIndent)
  test "reports an offense for def ending with return":
    expectOffense("""      def func
        one
        two
        return something
        ^^^^^^ Redundant `return` detected.
      end
""".stripIndent)
  test "reports an offense for defs ending with return":
    expectOffense("""      def self.func
        one
        two
        return something
        ^^^^^^ Redundant `return` detected.
      end
""".stripIndent)
  test "accepts return in a non-final position":
    expectNoOffenses("""      def func
        return something if something_else
      end
""".stripIndent)
  test "does not blow up on empty method body":
    expectNoOffenses("""      def func
      end
""".stripIndent)
  test "does not blow up on empty if body":
    expectNoOffenses("""      def func
        if x
        elsif y
        else
        end
      end
""".stripIndent)
  test "auto-corrects by removing redundant returns":
    var
      src = """      def func
        one
        two
        return something
      end
""".stripIndent
      resultSrc = """      def func
        one
        two
        something
      end
""".stripIndent
      newSource = autocorrectSource(src)
    expect(newSource).to(eq(resultSrc))
  context("when return has no arguments", proc (): void =
    sharedExamples("common behavior", proc (ret: string): void =
      let("src", proc (): void =
        """          def func
            one
            two
            (lvar :ret)
            # comment
          end
""".stripIndent)
      test """registers an offense for (lvar :ret)""":
        inspectSource(src())
        expect(cop().offenses.size).to(eq(1))
      test """auto-corrects by replacing (lvar :ret) with nil""":
        var newSource = autocorrectSource(src())
        expect(newSource).to(eq("""          def func
            one
            two
            nil
            # comment
          end
""".stripIndent)))
    itBehavesLike("common behavior", "return")
    itBehavesLike("common behavior", "return()"))
  context("when multi-value returns are not allowed", proc (): void =
    test "reports an offense for def with only a return":
      expectOffense("""        def func
          return something, test
          ^^^^^^ Redundant `return` detected. To return multiple values, use an array.
        end
""".stripIndent)
    test "reports an offense for defs with only a return":
      expectOffense("""        def Test.func
          return something, test
          ^^^^^^ Redundant `return` detected. To return multiple values, use an array.
        end
""".stripIndent)
    test "reports an offense for def ending with return":
      expectOffense("""        def func
          one
          two
          return something, test
          ^^^^^^ Redundant `return` detected. To return multiple values, use an array.
        end
""".stripIndent)
    test "reports an offense for defs ending with return":
      expectOffense("""        def self.func
          one
          two
          return something, test
          ^^^^^^ Redundant `return` detected. To return multiple values, use an array.
        end
""".stripIndent)
    test "auto-corrects by making implicit arrays explicit":
      var
        src = """        def func
          return  1, 2
        end
""".stripIndent
        resultSrc = """        def func
          [1, 2]
        end
""".stripIndent
        newSource = autocorrectSource(src)
      expect(newSource).to(eq(resultSrc))
    test "auto-corrects removes return when using an explicit hash":
      var
        src = """        def func
          return {:a => 1, :b => 2}
        end
""".stripIndent
        resultSrc = """        def func
          {:a => 1, :b => 2}
        end
""".stripIndent
        newSource = autocorrectSource(src)
      expect(newSource).to(eq(resultSrc))
    test "auto-corrects by making an implicit hash explicit":
      var
        src = """        def func
          return :a => 1, :b => 2
        end
""".stripIndent
        resultSrc = """        def func
          {:a => 1, :b => 2}
        end
""".stripIndent
        newSource = autocorrectSource(src)
      expect(newSource).to(eq(resultSrc)))
  context("when multi-value returns are allowed", proc (): void =
    let("cop_config", proc (): void =
      {"AllowMultipleReturnValues": true}.newTable())
    test "accepts def with only a return":
      expectNoOffenses("""        def func
          return something, test
        end
""".stripIndent)
    test "accepts defs with only a return":
      expectNoOffenses("""        def Test.func
          return something, test
        end
""".stripIndent)
    test "accepts def ending with return":
      expectNoOffenses("""        def func
          one
          two
          return something, test
        end
""".stripIndent)
    test "accepts defs ending with return":
      expectNoOffenses("""        def self.func
          one
          two
          return something, test
        end
""".stripIndent)
    test "does not auto-correct":
      var
        src = """        def func
          return  1, 2
        end
""".stripIndent
        newSource = autocorrectSource(src)
      expect(newSource).to(eq(src)))
  context("when return is inside begin-end body", proc (): void =
    let("src", proc (): void =
      """        def func
          begin
            return 1
          end
        end
""".stripIndent)
    test "registers an offense":
      expectOffense("""        def func
          begin
            return 1
            ^^^^^^ Redundant `return` detected.
          end
        end
""".stripIndent)
    test "auto-corrects":
      var corrected = autocorrectSource(src())
      expect(corrected).to(eq("""        def func
          begin
            1
          end
        end
""".stripIndent)))
  context("when rescue and return blocks present", proc (): void =
    let("src", proc (): void =
      """        def func
          1
          2
          return 3
        rescue SomeException
          4
          return 5
        rescue AnotherException
          return 6
        ensure
          return 7
        end
""".stripIndent)
    test "does register an offense when inside function or rescue block":
      expectOffense("""        def func
          1
          2
          return 3
          ^^^^^^ Redundant `return` detected.
        rescue SomeException
          4
          return 5
          ^^^^^^ Redundant `return` detected.
        rescue AnotherException
          return 6
          ^^^^^^ Redundant `return` detected.
        ensure
          return 7
        end
""".stripIndent)
    test "auto-corrects":
      var corrected = autocorrectSource(src())
      expect(corrected).to(eq("""        def func
          1
          2
          3
        rescue SomeException
          4
          5
        rescue AnotherException
          6
        ensure
          return 7
        end
""".stripIndent)))
  context("when return is inside an if-branch", proc (): void =
    let("src", proc (): void =
      """        def func
          if x
            return 1
          elsif y
            return 2
          else
            return 3
          end
        end
""".stripIndent)
    test "registers an offense":
      expectOffense("""        def func
          if x
            return 1
            ^^^^^^ Redundant `return` detected.
          elsif y
            return 2
            ^^^^^^ Redundant `return` detected.
          else
            return 3
            ^^^^^^ Redundant `return` detected.
          end
        end
""".stripIndent)
    test "auto-corrects":
      var corrected = autocorrectSource(src())
      expect(corrected).to(eq("""        def func
          if x
            1
          elsif y
            2
          else
            3
          end
        end
""".stripIndent)))
  context("when return is inside a when-branch", proc (): void =
    let("src", proc (): void =
      """        def func
          case x
          when y then return 1
          when z then return 2
          when q
          else
            return 3
          end
        end
""".stripIndent)
    test "registers an offense":
      expectOffense("""        def func
          case x
          when y then return 1
                      ^^^^^^ Redundant `return` detected.
          when z then return 2
                      ^^^^^^ Redundant `return` detected.
          when q
          else
            return 3
            ^^^^^^ Redundant `return` detected.
          end
        end
""".stripIndent)
    test "auto-corrects":
      var corrected = autocorrectSource(src())
      expect(corrected).to(eq("""        def func
          case x
          when y then 1
          when z then 2
          when q
          else
            3
          end
        end
""".stripIndent)))
  context("when case nodes are empty", proc (): void =
    test "accepts empty when nodes":
      expectNoOffenses("""        def func
          case x
          when y then 1
          when z # do nothing
          else
            3
          end
        end
""".stripIndent)))
