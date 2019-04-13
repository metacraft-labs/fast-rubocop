
import
  class_vars, test_tools

suite "ClassVars":
  var cop = ClassVars()
  test "registers an offense for class variable declaration":
    expectOffense("""      class TestClass; @@test = 10; end
                       ^^^^^^ Replace class var @@test with a class instance var.
""".stripIndent)
  test "does not register an offense for class variable usage":
    expectNoOffenses("@@test.test(20)")
