
import
  types

import
  constant_name, test_tools

suite "ConstantName":
  var cop = ConstantName()
  test "registers an offense for camel case in const name":
    expectOffense("""      TopCase = 5
      ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
""".stripIndent)
  test """registers an offense for camel case in const namewhen using frozen object assignment""":
    expectOffense("""      TopCase = 5.freeze
      ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
""".stripIndent)
  test "registers an offense for non-POSIX upper case in const name":
    expectOffense("""      Nö = 'no'
      ^^ Use SCREAMING_SNAKE_CASE for constants.
""".stripIndent)
  test "registers offenses for camel case in multiple const assignment":
    expectOffense("""      TopCase, Test2, TEST_3 = 5, 6, 7
      ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
               ^^^^^ Use SCREAMING_SNAKE_CASE for constants.
""".stripIndent)
  test "registers an offense for snake case in const name":
    expectOffense("""      TOP_test = 5
      ^^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
""".stripIndent)
  test "registers 1 offense if rhs is offending const assignment":
    expectOffense("""      Bar = Foo = 4
            ^^^ Use SCREAMING_SNAKE_CASE for constants.
""".stripIndent)
  test "allows screaming snake case in const name":
    expectNoOffenses("TOP_TEST = 5")
  test "allows screaming snake case in multiple const assignment":
    expectNoOffenses("TOP_TEST, TEST_2 = 5, 6")
  test "allows screaming snake case with POSIX upper case characters":
    expectNoOffenses("TÖP_TEST = 5")
  test "does not check names if rhs is a method call":
    expectNoOffenses("AnythingGoes = test")
  test "does not check names if rhs is a method call with conditional assign":
    expectNoOffenses("AnythingGoes ||= test")
  test "does not check names if rhs is a `Class.new`":
    expectNoOffenses("Invalid = Class.new(StandardError)")
  test "does not check names if rhs is a `Class.new` with conditional assign":
    expectNoOffenses("Invalid ||= Class.new(StandardError)")
  test "does not check names if rhs is a `Struct.new`":
    expectNoOffenses("Investigation = Struct.new(:offenses, :errors)")
  test "does not check names if rhs is a `Struct.new` with conditional assign":
    expectNoOffenses("Investigation ||= Struct.new(:offenses, :errors)")
  test "does not check names if rhs is a method call with block":
    expectNoOffenses("""      AnythingGoes = test do
        do_something
      end
""".stripIndent)
  test "does not check if rhs is another constant":
    expectNoOffenses("Parser::CurrentRuby = Parser::Ruby21")
  test "does not check if rhs is a non-offensive const assignment":
    expectNoOffenses("      Bar = Foo = Qux\n".stripIndent)
  test "checks qualified const names":
    expectOffense("""      ::AnythingGoes = 30
        ^^^^^^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
      a::Bar_foo = 10
         ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
""".stripIndent)
  context("when a rhs is a conditional expression", proc (): Example =
    context("when conditional branches contain only constants", proc (): void =
      test "does not check names":
        expectNoOffenses("Investigation = if true then Foo else Bar end"))
    context("when conditional branches contain a value other than a constant", proc (): void =
      test "does not check names":
        expectNoOffenses("Investigation = if true then \"foo\" else Bar end"))
    context("when conditional branches contain only string values", proc (): void =
      test "registers an offense":
        expectOffense("""          TopCase = if true then 'foo' else 'bar' end
          ^^^^^^^ Use SCREAMING_SNAKE_CASE for constants.
""".stripIndent)))
