
import
  commented_keyword, test_tools

suite "CommentedKeyword":
  var cop = CommentedKeyword()
  let("config", proc (): void =
    Config.new)
  test "registers an offense when commenting on the same line as `end`":
    expectOffense("""      if x
        y
      end # comment
          ^^^^^^^^^ Do not place comments on the same line as the `end` keyword.
""".stripIndent)
  test "registers an offense when commenting on the same line as `begin`":
    expectOffense("""      begin # comment
            ^^^^^^^^^ Do not place comments on the same line as the `begin` keyword.
        y
      end
""".stripIndent)
  test "registers an offense when commenting on the same line as `class`":
    expectOffense("""      class X # comment
              ^^^^^^^^^ Do not place comments on the same line as the `class` keyword.
        y
      end
""".stripIndent)
  test "registers an offense when commenting on the same line as `module`":
    expectOffense("""      module X # comment
               ^^^^^^^^^ Do not place comments on the same line as the `module` keyword.
        y
      end
""".stripIndent)
  test "registers an offense when commenting on the same line as `def`":
    expectOffense("""      def x # comment
            ^^^^^^^^^ Do not place comments on the same line as the `def` keyword.
        y
      end
""".stripIndent)
  test "registers an offense when commenting on indented keywords":
    expectOffense("""      module X
        class Y # comment
                ^^^^^^^^^ Do not place comments on the same line as the `class` keyword.
          z
        end
      end
""".stripIndent)
  test "registers an offense when commenting after keyword with spaces":
    expectOffense("""      def x(a, b) # comment
                  ^^^^^^^^^ Do not place comments on the same line as the `def` keyword.
        y
      end
""".stripIndent)
  test "registers an offense for one-line cases":
    expectOffense("""      def x; end # comment'
                 ^^^^^^^^^^ Do not place comments on the same line as the `def` keyword.
""".stripIndent)
  test "does not register an offense if there are no comments after keywords":
    expectNoOffenses("""      if x
        y
      end
""".stripIndent)
    expectNoOffenses("""      class X
        y
      end
""".stripIndent)
    expectNoOffenses("""      begin
        x
      end
""".stripIndent)
    expectNoOffenses("""      def x
        y
      end
""".stripIndent)
    expectNoOffenses("""      module X
        y
      end
""".stripIndent)
    expectNoOffenses("      # module Y # trap comment\n".stripIndent)
    expectNoOffenses("      \'end\' # comment\n".stripIndent)
    expectNoOffenses("""      <<-HEREDOC
        def # not a comment
      HEREDOC
""".stripIndent)
  test "does not register an offense for certain comments":
    expectNoOffenses("""      class X # :nodoc:
        y
      end
""".stripIndent)
    expectNoOffenses("""      class X
        def y # :yields:
          yield
        end
      end
""".stripIndent)
    expectNoOffenses("""      def x # rubocop:disable Metrics/MethodLength
        y
      end
""".stripIndent)
  test "does not register an offense if AST contains # symbol":
    expectNoOffenses("""      def x(y = "#value")
        y
      end
""".stripIndent)
    expectNoOffenses("""      def x(y: "#value")
        y
      end
""".stripIndent)
  test "accepts keyword letter sequences that are not keywords":
    expectNoOffenses("""      options = {
        end_buttons: true, # comment
      }
""".stripIndent)
    expectNoOffenses("      defined?(SomeModule).should be_nil # comment\n".stripIndent)
    expectNoOffenses("      foo = beginning_statement # comment\n".stripIndent)
