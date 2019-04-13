
import
  block_comments, test_tools

suite "BlockComments":
  var cop = BlockComments()
  test "registers an offense for block comments":
    expectOffense("""      =begin
      ^^^^^^ Do not use block comments.
      comment
      =end
""".stripIndent)
  test "accepts regular comments":
    expectNoOffenses("# comment")
  test "auto-corrects a block comment into a regular comment":
    var newSource = autocorrectSource("""      =begin
      comment line 1

      comment line 2
      =end
      def foo
      end
""".stripIndent)
    expect(newSource).to(eq("""      # comment line 1
      #
      # comment line 2
      def foo
      end
""".stripIndent))
  test "auto-corrects an empty block comment by removing it":
    var newSource = autocorrectSource("""      =begin
      =end
      def foo
      end
""".stripIndent)
    expect(newSource).to(eq("""      def foo
      end
""".stripIndent))
