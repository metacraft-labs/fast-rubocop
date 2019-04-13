
import
  redundant_with_object, test_tools

suite "RedundantWithObject":
  var cop = RedundantWithObject()
  let("config", proc (): void =
    Config.new)
  test "registers an offense when using `ary.each_with_object { |v| v }`":
    expectOffense("""      ary.each_with_object([]) { |v| v }
          ^^^^^^^^^^^^^^^^^^^^ Use `each` instead of `each_with_object`.
""".stripIndent)
  test "registers an offense when using `ary.each.with_object([]) { |v| v }`":
    expectOffense("""      ary.each.with_object([]) { |v| v }
               ^^^^^^^^^^^^^^^ Remove redundant `with_object`.
""".stripIndent)
  test "autocorrects to ary.each from ary.each_with_object([])":
    var newSource = autocorrectSource("ary.each_with_object([]) { |v| v }")
    expect(newSource).to(eq("ary.each { |v| v }"))
  test "autocorrects to ary.each from ary.each_with_object []":
    var newSource = autocorrectSource("ary.each_with_object [] { |v| v }")
    expect(newSource).to(eq("ary.each { |v| v }"))
  test "autocorrects to ary.each from ary.each_with_object([]) do-end block":
    var newSource = autocorrectSource("""      ary.each_with_object([]) do |v|
        v
      end
""".stripIndent)
    expect(newSource).to(eq("""      ary.each do |v|
        v
      end
""".stripIndent))
  test "autocorrects to ary.each from ary.each_with_object do-end block":
    var newSource = autocorrectSource("""      ary.each_with_object [] do |v|
        v
      end
""".stripIndent)
    expect(newSource).to(eq("""      ary.each do |v|
        v
      end
""".stripIndent))
  test "autocorrects to ary.each from ary.each.with_object([]) { |v| v }":
    var newSource = autocorrectSource("ary.each.with_object([]) { |v| v }")
    expect(newSource).to(eq("ary.each { |v| v }"))
  test "autocorrects to ary.each from ary.each.with_object [] { |v| v }":
    var newSource = autocorrectSource("ary.each.with_object [] { |v| v }")
    expect(newSource).to(eq("ary.each { |v| v }"))
  test "an object is used as a block argument":
    expectNoOffenses("ary.each_with_object([]) { |v, o| v; o }")
  context("when missing argument to `each_with_object`", proc (): void =
    test "does not register an offense when block has 2 arguments":
      expectNoOffenses("ary.each_with_object { |v, o| v; o }")
    test "does not register an offense when block has 1 argument":
      expectNoOffenses("ary.each_with_object { |v| v }"))
