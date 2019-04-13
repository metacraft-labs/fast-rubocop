
import
  trailing_method_end_statement, test_tools

suite "TrailingMethodEndStatement":
  var cop = TrailingMethodEndStatement()
  let("config", proc (): void =
    Config.new())
  test "register offense with trailing end on 2 line method":
    expectOffense("""      def some_method
      foo; end
           ^^^ Place the end statement of a multi-line method on its own line.
""".stripIndent)
  test "register offense with trailing end on 3 line method":
    expectOffense("""      def a
        b
      { foo: bar }; end
                    ^^^ Place the end statement of a multi-line method on its own line.
""".stripIndent)
  test "register offense with trailing end on method with comment":
    expectOffense("""      def c
        b = calculation
        [b] end # because b
            ^^^ Place the end statement of a multi-line method on its own line.
""".stripIndent)
  test "register offense with trailing end on method with block":
    expectOffense("""      def d
        block do
          foo
        end end
            ^^^ Place the end statement of a multi-line method on its own line.
""".stripIndent)
  test "register offense with trailing end inside class":
    expectOffense("""      class Foo
        def some_method
        foo; end
             ^^^ Place the end statement of a multi-line method on its own line.
      end
""".stripIndent)
  test "does not register on single line no op":
    expectNoOffenses("      def no_op; end\n".stripIndent)
  test "does not register on single line method":
    expectNoOffenses("      def something; do_stuff; end\n".stripIndent)
  test "auto-corrects trailing end in 2 line method":
    var corrected = autocorrectSource("""      def some_method
        []; end
""".stripIndent)
    expect(corrected).to(eq("""      def some_method
        [] 
        end
""".stripIndent))
  test "auto-corrects trailing end in 3 line method":
    var corrected = autocorrectSource("""      def do_this(x)
        y = x + 5
        y / 2; end
""".stripIndent)
    expect(corrected).to(eq("""      def do_this(x)
        y = x + 5
        y / 2 
        end
""".stripIndent))
  test "auto-corrects trailing end with comment":
    var corrected = autocorrectSource("""      def f(x, y)
        process(x)
        process(y) end # comment
""".stripIndent)
    expect(corrected).to(eq("""      def f(x, y)
        process(x)
        process(y) 
        end # comment
""".stripIndent))
  test "auto-corrects trailing end on method with block":
    var corrected = autocorrectSource("""      def d
        block do
          foo
        end end
""".stripIndent)
    expect(corrected).to(eq("""      def d
        block do
          foo
        end 
        end
""".stripIndent))
  test "auto-corrects trailing end for larger example":
    var corrected = autocorrectSource("""      class Foo
        def some_method
          []; end
      end
""".stripIndent)
    expect(corrected).to(eq("""      class Foo
        def some_method
          [] 
        end
      end
""".stripIndent))
