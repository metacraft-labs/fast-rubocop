
import
  reverse_each, test_tools

suite "ReverseEach":
  var cop = ReverseEach()
  test "registers an offense when each is called on reverse":
    expectOffense("""      [1, 2, 3].reverse.each { |e| puts e }
                ^^^^^^^^^^^^ Use `reverse_each` instead of `reverse.each`.
""".stripIndent)
  test "registers an offense when each is called on reverse on a variable":
    expectOffense("""      arr = [1, 2, 3]
      arr.reverse.each { |e| puts e }
          ^^^^^^^^^^^^ Use `reverse_each` instead of `reverse.each`.
""".stripIndent)
  test "registers an offense when each is called on reverse on a method call":
    expectOffense("""      def arr
        [1, 2, 3]
      end

      arr.reverse.each { |e| puts e }
          ^^^^^^^^^^^^ Use `reverse_each` instead of `reverse.each`.
""".stripIndent)
  test "does not register an offense when reverse is used without each":
    expectNoOffenses("[1, 2, 3].reverse")
  test "does not register an offense when each is used without reverse":
    expectNoOffenses("[1, 2, 3].each { |e| puts e }")
  context("autocorrect", proc (): void =
    test "corrects reverse.each to reverse_each":
      var newSource = autocorrectSource("[1, 2].reverse.each { |e| puts e }")
      expect(newSource).to(eq("[1, 2].reverse_each { |e| puts e }"))
    test "corrects reverse.each to reverse_each on a variable":
      var newSource = autocorrectSource("""        arr = [1, 2]
        arr.reverse.each { |e| puts e }
""".stripIndent)
      expect(newSource).to(eq("""        arr = [1, 2]
        arr.reverse_each { |e| puts e }
""".stripIndent))
    test "corrects reverse.each to reverse_each on a method call":
      var newSource = autocorrectSource("""        def arr
          [1, 2]
        end

        arr.reverse.each { |e| puts e }
""".stripIndent)
      expect(newSource).to(eq("""        def arr
          [1, 2]
        end

        arr.reverse_each { |e| puts e }
""".stripIndent)))
