
import
  each_with_object_argument, test_tools

suite "EachWithObjectArgument":
  var cop = EachWithObjectArgument()
  test "registers an offense for fixnum argument":
    expectOffense("""      collection.each_with_object(0) { |e, a| a + e }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The argument to each_with_object can not be immutable.
""".stripIndent)
  test "registers an offense for float argument":
    expectOffense("""      collection.each_with_object(0.1) { |e, a| a + e }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The argument to each_with_object can not be immutable.
""".stripIndent)
  test "registers an offense for bignum argument":
    expectOffense("""      c.each_with_object(100000000000000000000) { |e, o| o + e }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The argument to each_with_object can not be immutable.
""".stripIndent)
  test "accepts a variable argument":
    expectNoOffenses("collection.each_with_object(x) { |e, a| a.add(e) }")
  test "accepts two arguments":
    expectNoOffenses("collection.each_with_object(1, 2) { |e, a| a.add(e) }")
  test "accepts a string argument":
    expectNoOffenses("collection.each_with_object(\'\') { |e, a| a << e.to_s }")
  context("when using safe navigation operator", "ruby23", proc (): void =
    test "registers an offense for fixnum argument":
      expectOffense("""        collection&.each_with_object(0) { |e, a| a + e }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The argument to each_with_object can not be immutable.
""".stripIndent))
