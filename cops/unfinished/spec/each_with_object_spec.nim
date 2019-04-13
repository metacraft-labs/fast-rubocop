
import
  each_with_object, test_tools

suite "EachWithObject":
  var cop = EachWithObject()
  test "finds inject and reduce with passed in and returned hash":
    expectOffense("""      [].inject({}) { |a, e| a }
         ^^^^^^ Use `each_with_object` instead of `inject`.

      [].reduce({}) do |a, e|
         ^^^^^^ Use `each_with_object` instead of `reduce`.
        a[e] = 1
        a[e] = 1
        a
      end
""".stripIndent)
  test "correctly autocorrects":
    var corrected = autocorrectSource("""      [1, 2, 3].inject({}) do |h, i|
        h[i] = i
        h
      end
""".stripIndent)
    expect(corrected).to(eq("""      [1, 2, 3].each_with_object({}) do |i, h|
        h[i] = i
      end
""".stripIndent))
  test "correctly autocorrects with return value only":
    var corrected = autocorrectSource("""      [1, 2, 3].inject({}) do |h, i|
        h
      end
""".stripIndent)
    expect(corrected).to(eq("""      [1, 2, 3].each_with_object({}) do |i, h|
      end
""".stripIndent))
  test "ignores inject and reduce with passed in, but not returned hash":
    expectNoOffenses("""      [].inject({}) do |a, e|
        a + e
      end

      [].reduce({}) do |a, e|
        my_method e, a
      end
""".stripIndent)
  test "ignores inject and reduce with empty body":
    expectNoOffenses("""      [].inject({}) do |a, e|
      end

      [].reduce({}) { |a, e| }
""".stripIndent)
  test "ignores inject and reduce with condition as body":
    expectNoOffenses("""      [].inject({}) do |a, e|
        a = e if e
      end

      [].inject({}) do |a, e|
        if e
          a = e
        end
      end

      [].reduce({}) do |a, e|
        a = e ? e : 2
      end
""".stripIndent)
  test "ignores inject and reduce passed in symbol":
    expectNoOffenses("[].inject(:+)")
  test "does not blow up for reduce with no arguments":
    expectNoOffenses("[1, 2, 3].inject { |a, e| a + e }")
  test "ignores inject/reduce with assignment to accumulator param in block":
    expectNoOffenses("""      r = [1, 2, 3].reduce({}) do |memo, item|
        memo += item > 2 ? item : 0
        memo
      end
""".stripIndent)
  context("when a simple literal is passed as initial value", proc (): void =
    test "ignores inject/reduce":
      expectNoOffenses("array.reduce(0) { |a, e| a }"))
