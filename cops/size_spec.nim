
import
  size, test_tools

suite "Size":
  var cop = Size()
  test """does not register an offense when calling count as a stand alone method""":
    expectNoOffenses("count(items)")
  test """does not register an offense when calling count on an object other than an array or a hash""":
    expectNoOffenses("object.count(items)")
  describe("on array", proc (): void =
    test "registers an offense when calling count":
      expectOffense("""        [1, 2, 3].count
                  ^^^^^ Use `size` instead of `count`.
""".stripIndent)
    test "registers an offense when calling count on to_a":
      expectOffense("""        (1..3).to_a.count
                    ^^^^^ Use `size` instead of `count`.
""".stripIndent)
    test "registers an offense when calling count on Array[]":
      expectOffense("""        Array[*1..5].count
                     ^^^^^ Use `size` instead of `count`.
""".stripIndent)
    test "does not register an offense when calling size":
      expectNoOffenses("[1, 2, 3].size")
    test "does not register an offense when calling another method":
      expectNoOffenses("[1, 2, 3].each")
    test "does not register an offense when calling count with a block":
      expectNoOffenses("[1, 2, 3].count { |e| e > 3 }")
    test "does not register an offense when calling count with a to_proc block":
      expectNoOffenses("[1, 2, 3].count(&:nil?)")
    test "does not register an offense when calling count with an argument":
      expectNoOffenses("[1, 2, 3].count(1)")
    test "corrects count to size":
      var newSource = autocorrectSource("[1, 2, 3].count")
      expect(newSource).to(eq("[1, 2, 3].size"))
    test "corrects count to size on to_a":
      var newSource = autocorrectSource("(1..3).to_a.count")
      expect(newSource).to(eq("(1..3).to_a.size"))
    test "corrects count to size on Array[]":
      var newSource = autocorrectSource("Array[*1..5].count")
      expect(newSource).to(eq("Array[*1..5].size")))
  describe("on hash", proc (): void =
    test "registers an offense when calling count":
      expectOffense("""        {a: 1, b: 2, c: 3}.count
                           ^^^^^ Use `size` instead of `count`.
""".stripIndent)
    test "registers an offense when calling count on to_h":
      expectOffense("""        [[:foo, :bar], [1, 2]].to_h.count
                                    ^^^^^ Use `size` instead of `count`.
""".stripIndent)
    test "registers an offense when calling count on Hash[]":
      expectOffense("""        Hash[*('a'..'z')].count
                          ^^^^^ Use `size` instead of `count`.
""".stripIndent)
    test "does not register an offense when calling size":
      expectNoOffenses("{a: 1, b: 2, c: 3}.size")
    test "does not register an offense when calling another method":
      expectNoOffenses("{a: 1, b: 2, c: 3}.each")
    test "does not register an offense when calling count with a block":
      expectNoOffenses("{a: 1, b: 2, c: 3}.count { |e| e > 3 }")
    test "does not register an offense when calling count with a to_proc block":
      expectNoOffenses("{a: 1, b: 2, c: 3}.count(&:nil?)")
    test "does not register an offense when calling count with an argument":
      expectNoOffenses("{a: 1, b: 2, c: 3}.count(1)")
    test "corrects count to size":
      var newSource = autocorrectSource("{a: 1, b: 2, c: 3}.count")
      expect(newSource).to(eq("{a: 1, b: 2, c: 3}.size"))
    test "corrects count to size on to_h":
      var newSource = autocorrectSource("[[:foo, :bar], [1, 2]].to_h.count")
      expect(newSource).to(eq("[[:foo, :bar], [1, 2]].to_h.size"))
    test "corrects count to size on Hash[]":
      var newSource = autocorrectSource("Hash[*(\'a\'..\'z\')].count")
      expect(newSource).to(eq("Hash[*(\'a\'..\'z\')].size")))
