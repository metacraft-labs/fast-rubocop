
import
  semicolon, test_tools

RSpec.describe(Semicolon, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"AllowAsExpressionSeparator": false}.newTable())
  test "registers an offense for a single expression":
    expectOffense("""      puts "this is a test";
                           ^ Do not use semicolons to terminate expressions.
""".stripIndent)
  test "registers an offense for several expressions":
    expectOffense("""      puts "this is a test"; puts "So is this"
                           ^ Do not use semicolons to terminate expressions.
""".stripIndent)
  test "registers an offense for one line method with two statements":
    expectOffense("""      def foo(a) x(1); y(2); z(3); end
                     ^ Do not use semicolons to terminate expressions.
""".stripIndent)
  test "accepts semicolon before end if so configured":
    expectNoOffenses("def foo(a) z(3); end")
  test "accepts semicolon after params if so configured":
    expectNoOffenses("def foo(a); z(3) end")
  test "accepts one line method definitions":
    expectNoOffenses("""      def foo1; x(3) end
      def initialize(*_); end
      def foo2() x(3); end
      def foo3; x(3); end
""".stripIndent)
  test "accepts one line empty class definitions":
    expectNoOffenses("""      # Prefer a single-line format for class ...
      class Foo < Exception; end

      class Bar; end
""".stripIndent)
  test "accepts one line empty method definitions":
    expectNoOffenses("""      # One exception to the rule are empty-body methods
      def no_op; end

      def foo; end
""".stripIndent)
  test "accepts one line empty module definitions":
    expectNoOffenses("module Foo; end")
  test "registers an offense for semicolon at the end no matter what":
    expectOffense("""      module Foo; end;
                     ^ Do not use semicolons to terminate expressions.
""".stripIndent)
  test "accept semicolons inside strings":
    expectNoOffenses("""      string = ";
      multi-line string"
""".stripIndent)
  test "registers an offense for a semicolon at the beginning of a line":
    expectOffense("""      ; puts 1
      ^ Do not use semicolons to terminate expressions.
""".stripIndent)
  test "auto-corrects semicolons when syntactically possible":
    var corrected = autocorrectSource("""        module Foo; end;
        puts "this is a test";
        puts "this is a test"; puts "So is this"
        def foo(a) x(1); y(2); z(3); end
        ;puts 1
""".stripIndent)
    expect(corrected).to(eq("""        module Foo; end
        puts "this is a test"
        puts "this is a test"; puts "So is this"
        def foo(a) x(1); y(2); z(3); end
        puts 1
""".stripIndent))
  context("with a multi-expression line without a semicolon", proc (): void =
    test "does not register an offense":
      expectNoOffenses("""        def foo
          bar = baz if qux else quux
        end
""".stripIndent))
  context("when AllowAsExpressionSeparator is true", proc (): void =
    let("cop_config", proc (): void =
      {"AllowAsExpressionSeparator": true}.newTable())
    test "accepts several expressions":
      expectNoOffenses("puts \"this is a test\"; puts \"So is this\"")
    test "accepts one line method with two statements":
      expectNoOffenses("def foo(a) x(1); y(2); z(3); end")))
