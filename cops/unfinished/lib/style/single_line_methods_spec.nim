
import
  types

import
  single_line_methods, test_tools

suite "SingleLineMethods":
  var cop = SingleLineMethods()
  let("config", proc (): Config =
    initConfig())
  let("cop_config", proc (): Table[string, bool] =
    {"AllowIfMethodIsEmpty": true}.newTable())
  test "registers an offense for a single-line method":
    expectOffense("""      def some_method; body end
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
      def link_to(name, url); {:name => name}; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
      def @table.columns; super; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
""".stripIndent)
  context("when AllowIfMethodIsEmpty is disabled", proc () =
    let("cop_config", proc (): Table[string, bool] =
      {"AllowIfMethodIsEmpty": false}.newTable())
    test "registers an offense for an empty method":
      expectOffense("""        def no_op; end
        ^^^^^^^^^^^^^^ Avoid single-line method definitions.
        def self.resource_class=(klass); end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
        def @table.columns; end
        ^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
""".stripIndent)
    test "auto-corrects an empty method":
      var corrected = autocorrectSource("        def x; end\n".stripIndent)
      expect(corrected).to(eq("""        def x; 
        end
""".stripIndent)))
  context("when AllowIfMethodIsEmpty is enabled", proc () =
    let("cop_config", proc (): Table[string, bool] =
      {"AllowIfMethodIsEmpty": true}.newTable())
    test "accepts a single-line empty method":
      expectNoOffenses("""        def no_op; end
        def self.resource_class=(klass); end
        def @table.columns; end
""".stripIndent))
  test "accepts a multi-line method":
    expectNoOffenses("""      def some_method
        body
      end
""".stripIndent)
  test "does not crash on an method with a capitalized name":
    expectNoOffenses("""      def NoSnakeCase
      end
""".stripIndent)
  test "auto-corrects def with semicolon after method name":
    var corrected = autocorrectSource("  def some_method; body end # Cmnt")
    expect(corrected).to(eq(@["  # Cmnt", "  def some_method; ", "    body ",
                              "  end "].join("\n")))
  test "auto-corrects defs with parentheses after method name":
    var corrected = autocorrectSource("  def self.some_method() body end")
    expect(corrected).to(eq(@["  def self.some_method() ", "    body ", "  end"].join(
        "\n")))
  test "auto-corrects def with argument in parentheses":
    var corrected = autocorrectSource("  def some_method(arg) body end")
    expect(corrected).to(eq(@["  def some_method(arg) ", "    body ", "  end"].join(
        "\n")))
  test "auto-corrects def with argument and no parentheses":
    var corrected = autocorrectSource("  def some_method arg; body end")
    expect(corrected).to(eq(@["  def some_method arg; ", "    body ", "  end"].join(
        "\n")))
  test "auto-corrects def with semicolon before end":
    var corrected = autocorrectSource("  def some_method; b1; b2; end")
    expect(corrected).to(eq(@["  def some_method; ", "    b1; ", "    b2; ",
                              "  end"].join("\n")))
