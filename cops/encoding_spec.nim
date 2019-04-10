
import
  encoding, test_tools

RSpec.describe(Encoding, "config", proc (): void =
  var cop = ()
  test "registers no offense when no encoding present":
    expectNoOffenses("      def foo() end\n".stripIndent)
  test "registers no offense when encoding present but not UTF-8":
    expectNoOffenses("""      # encoding: us-ascii
      def foo() end
""".stripIndent)
  test "registers an offense when encoding present and UTF-8":
    expectOffense("""      # encoding: utf-8
      ^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
      def foo() end
""".stripIndent)
  test "registers an offense when encoding present on 2nd line after shebang":
    expectOffense("""      #!/usr/bin/env ruby
      # encoding: utf-8
      ^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
      def foo() end
""".stripIndent)
  test "registers an offense for vim-style encoding comments":
    expectOffense("""      # vim:filetype=ruby, fileencoding=utf-8
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
      def foo() end
""".stripIndent)
  test "registers no offense when encoding is in the wrong place":
    expectNoOffenses("""      def foo() end
      # encoding: utf-8
""".stripIndent)
  test "registers an offense for encoding inserted by magic_encoding gem":
    expectOffense("""      # -*- encoding : utf-8 -*-
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary utf-8 encoding comment.
      def foo() 'ä' end
""".stripIndent)
  context("auto-correct", proc (): void =
    test "removes encoding comment on first line":
      var newSource = autocorrectSource("# encoding: utf-8\nblah")
      expect(newSource).to(eq("blah"))))
