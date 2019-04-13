
import
  redundant_block_call, test_tools

suite "RedundantBlockCall":
  var cop = RedundantBlockCall()
  test "autocorrects block.call without arguments":
    var newSource = autocorrectSource("""      def method(&block)
        block.call
      end
""".stripIndent)
    expect(newSource).to(eq("""      def method(&block)
        yield
      end
""".stripIndent))
  test "autocorrects block.call with empty parentheses":
    var newSource = autocorrectSource("""      def method(&block)
        block.call()
      end
""".stripIndent)
    expect(newSource).to(eq("""      def method(&block)
        yield
      end
""".stripIndent))
  test "autocorrects block.call with arguments":
    var newSource = autocorrectSource("""      def method(&block)
        block.call 1, 2
      end
""".stripIndent)
    expect(newSource).to(eq("""      def method(&block)
        yield 1, 2
      end
""".stripIndent))
  test "autocorrects multiple occurrences of block.call with arguments":
    var newSource = autocorrectSource("""      def method(&block)
        block.call 1
        block.call 2
      end
""".stripIndent)
    expect(newSource).to(eq("""      def method(&block)
        yield 1
        yield 2
      end
""".stripIndent))
  test "autocorrects even when block arg has a different name":
    var newSource = autocorrectSource("""      def method(&func)
        func.call
      end
""".stripIndent)
    expect(newSource).to(eq("""      def method(&func)
        yield
      end
""".stripIndent))
  test "accepts a block that is not `call`ed":
    expectNoOffenses("""      def method(&block)
       something.call
      end
""".stripIndent)
  test "accepts an empty method body":
    expectNoOffenses("""      def method(&block)
      end
""".stripIndent)
  test "accepts another block being passed as the only arg":
    expectNoOffenses("""      def method(&block)
        block.call(&some_proc)
      end
""".stripIndent)
  test "accepts another block being passed along with other args":
    expectNoOffenses("""      def method(&block)
        block.call(1, &some_proc)
      end
""".stripIndent)
  test "accepts another block arg in at least one occurrence of block.call":
    expectNoOffenses("""      def method(&block)
        block.call(1, &some_proc)
        block.call(2)
      end
""".stripIndent)
  test "accepts an optional block that is defaulted":
    expectNoOffenses("""      def method(&block)
        block ||= ->(i) { puts i }
        block.call(1)
      end
""".stripIndent)
  test "accepts an optional block that is overridden":
    expectNoOffenses("""      def method(&block)
        block = ->(i) { puts i }
        block.call(1)
      end
""".stripIndent)
  test "formats the error message for func.call(1) correctly":
    expectOffense("""      def method(&func)
        func.call(1)
        ^^^^^^^^^^^^ Use `yield` instead of `func.call`.
      end
""".stripIndent)
  test "autocorrects using parentheses when block.call uses parentheses":
    var newSource = autocorrectSource("""      def method(&block)
        block.call(a, b)
      end
""".stripIndent)
    expect(newSource).to(eq("""      def method(&block)
        yield(a, b)
      end
""".stripIndent))
  test """autocorrects when the result of the call is used in a scope that requires parentheses""":
    var
      source = """      def method(&block)
        each_with_object({}) do |(key, value), acc|
          acc.merge!(block.call(key) => rhs[value])
        end
      end
""".stripIndent
      newSource = autocorrectSource(source)
    expect(newSource).to(eq("""      def method(&block)
        each_with_object({}) do |(key, value), acc|
          acc.merge!(yield(key) => rhs[value])
        end
      end
""".stripIndent))
