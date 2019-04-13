
import
  empty_block_parameter, test_tools

suite "EmptyBlockParameter":
  var cop = EmptyBlockParameter()
  let("config", proc (): void =
    Config.new)
  test "registers an offense for an empty block parameter with do-end wtyle":
    expectOffense("""      a do ||
           ^^ Omit pipes for the empty block parameters.
      end
""".stripIndent)
    expectCorrection("""      a do
      end
""".stripIndent)
  test "registers an offense for an empty block parameter with {} style":
    expectOffense("""      a { || do_something }
          ^^ Omit pipes for the empty block parameters.
""".stripIndent)
    expectCorrection("      a { do_something }\n".stripIndent)
  test "registers an offense for an empty block parameter with super":
    expectOffense("""      def foo
        super { || do_something }
                ^^ Omit pipes for the empty block parameters.
      end
""".stripIndent)
    expectCorrection("""      def foo
        super { do_something }
      end
""".stripIndent)
  test "registers an offense for an empty block parameter with lambda":
    expectOffense("""      lambda { || do_something }
               ^^ Omit pipes for the empty block parameters.
""".stripIndent)
    expectCorrection("      lambda { do_something }\n".stripIndent)
  test "accepts a block that is do-end style without parameter":
    expectNoOffenses("""      a do
      end
""".stripIndent)
  test "accepts a block that is {} style without parameter":
    expectNoOffenses("      a { }\n".stripIndent)
  test "accepts a non-empty block parameter with do-end style":
    expectNoOffenses("""      a do |x|
      end
""".stripIndent)
  test "accepts a non-empty block parameter with {} style":
    expectNoOffenses("      a { |x| }\n".stripIndent)
  test "accepts an empty block parameter with a lambda":
    expectNoOffenses("      -> () { do_something }\n".stripIndent)
