
import
  tables

import
  infinite_loop, test_tools

suite "InfiniteLoop":
  var cop = InfiniteLoop()
  let("config", proc (): void =
    Config.new())
  for lit in @["1", "2.0", "[1]", "{}"]:
    test """registers an offense for a while loop with (lvar :lit) as condition""":
      expectOffense("""        while (lvar :lit)
        ^^^^^ Use `Kernel#loop` for infinite loops.
          top
        end
""".stripIndent)
  for lit in @["false", "nil"]:
    test """registers an offense for a until loop with (lvar :lit) as condition""":
      expectOffense("""        until (lvar :lit)
        ^^^^^ Use `Kernel#loop` for infinite loops.
          top
        end
""".stripIndent)
  test "accepts Kernel#loop":
    expectNoOffenses("loop { break if something }")
  test "accepts while true if loop {} would change semantics":
    expectNoOffenses("""      def f1
        a = nil # This `a` is local to `f1` and should not affect `f2`.
        puts a
      end

      def f2
        b = 17
        while true
          # `a` springs into existence here, while `b` already existed. Because
          # of `a` we can't introduce a block.
          a, b = 42, 42
          break
        end
        puts a, b
      end
""".stripIndent)
  test "accepts modifier while true if loop {} would change semantics":
    expectNoOffenses("""      a = next_value or break while true
      p a
""".stripIndent)
  test """registers an offense for modifier until false if loop {} would not change semantics""":
    expectOffense("""      a = nil
      a = next_value or break until false
                              ^^^^^ Use `Kernel#loop` for infinite loops.
      p a
""".stripIndent)
  test """registers an offense for until false if loop {} would work because of previous assignment in a while loop""":
    expectOffense("""      while true
        a = 42
        break
      end
      until false
      ^^^^^ Use `Kernel#loop` for infinite loops.
        # The variable `a` already exits here, having been introduced in the
        # above `while` loop. We can therefore safely change it too `Kernel#loop`.
        a = 43
        break
      end
      puts a
""".stripIndent)
  test """registers an offense for until false if loop {} would work because the assigned variable is not used afterwards""":
    expectOffense("""      until false
      ^^^^^ Use `Kernel#loop` for infinite loops.
        a = 43
        break
      end
""".stripIndent)
  test """registers an offense for while true or until false if loop {} would work because of an earlier assignment""":
    expectOffense("""      a = 0
      while true
      ^^^^^ Use `Kernel#loop` for infinite loops.
        a = 42 # `a` is in scope outside of the `while`
        break
      end
      until false
      ^^^^^ Use `Kernel#loop` for infinite loops.
        a = 43 # `a` is in scope outside of the `while`
        break
      end
      puts a
""".stripIndent)
  test """registers an offense for while true if loop {} would work because it is an instance variable being assigned""":
    expectOffense("""      while true
      ^^^^^ Use `Kernel#loop` for infinite loops.
        @a = 42
        break
      end
      puts @a
""".stripIndent)
  sharedExamplesFor("auto-corrector", proc (keyword: string; lit: string): void =
    test """auto-corrects single line modifier (lvar :keyword)""":
      var newSource = autocorrectSource("""something += 1 (lvar :keyword) (lvar :lit) # comment""")
      expect(newSource).to(eq("loop { something += 1 } # comment"))
    context("with non-default indentation width", proc (): void =
      let("config", proc (): void =
        Config.new())
      test """auto-corrects multi-line modifier (lvar :keyword) and indents correctly""":
        var newSource = autocorrectSource("""          # comment
          something 1, # comment 1
              # comment 2
              2 (lvar :keyword) (lvar :lit)
""".stripIndent)
        expect(newSource).to(eq("""          # comment
          loop do
              something 1, # comment 1
                  # comment 2
                  2
          end
""".stripIndent)))
    test """auto-corrects begin-end-(lvar :keyword) with one statement""":
      var newSource = autocorrectSource("""        begin # comment 1
          something += 1 # comment 2
        end (lvar :keyword) (lvar :lit) # comment 3
""".stripIndent)
      expect(newSource).to(eq("""        loop do # comment 1
          something += 1 # comment 2
        end # comment 3
""".stripIndent))
    test """auto-corrects begin-end-(lvar :keyword) with two statements""":
      var newSource = autocorrectSource("""        begin
          something += 1
          something_else += 1
        end (lvar :keyword) (lvar :lit)
""".stripIndent)
      expect(newSource).to(eq("""        loop do
          something += 1
          something_else += 1
        end
""".stripIndent))
    test """auto-corrects single line modifier (lvar :keyword) with and""":
      var newSource = autocorrectSource("""something and something_else (lvar :keyword) (lvar :lit)""")
      expect(newSource).to(eq("loop { something and something_else }"))
    test """auto-corrects the usage of (lvar :keyword) with do""":
      var newSource = autocorrectSource("""        (lvar :keyword) (lvar :lit) do
        end
""".stripIndent)
      expect(newSource).to(eq("""        loop do
        end
""".stripIndent))
    test """auto-corrects the usage of (lvar :keyword) without do""":
      var newSource = autocorrectSource("""        (lvar :keyword) (lvar :lit)
        end
""".stripIndent)
      expect(newSource).to(eq("""        loop do
        end
""".stripIndent)))
  itBehavesLike("auto-corrector", "while", "true")
  itBehavesLike("auto-corrector", "until", "false")
