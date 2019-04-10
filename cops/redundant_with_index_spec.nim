
import
  redundant_with_index, test_tools

suite "RedundantWithIndex":
  var cop = RedundantWithIndex()
  let("config", proc (): void =
    Config.new)
  test "registers an offense when using `ary.each_with_index { |v| v }`":
    expectOffense("""      ary.each_with_index { |v| v }
          ^^^^^^^^^^^^^^^ Use `each` instead of `each_with_index`.
""".stripIndent)
  test "registers an offense when using `ary.each.with_index { |v| v }`":
    expectOffense("""      ary.each.with_index { |v| v }
               ^^^^^^^^^^ Remove redundant `with_index`.
""".stripIndent)
  test "registers an offense when using `ary.each.with_index(1) { |v| v }`":
    expectOffense("""      ary.each.with_index(1) { |v| v }
               ^^^^^^^^^^^^^ Remove redundant `with_index`.
""".stripIndent)
  test """registers an offense when using `ary.each_with_object([]).with_index { |v| v }`""":
    expectOffense("""      ary.each_with_object([]).with_index { |v| v }
                               ^^^^^^^^^^ Remove redundant `with_index`.
""".stripIndent)
  test "autocorrects to ary.each from ary.each_with_index":
    var newSource = autocorrectSource("ary.each_with_index { |v| v }")
    expect(newSource).to(eq("ary.each { |v| v }"))
  test "autocorrects to ary.each from ary.each.with_index":
    var newSource = autocorrectSource("ary.each.with_index { |v| v }")
    expect(newSource).to(eq("ary.each { |v| v }"))
  test "autocorrects to ary.each from ary.each.with_index(1)":
    var newSource = autocorrectSource("ary.each.with_index(1) { |v| v }")
    expect(newSource).to(eq("ary.each { |v| v }"))
  test "autocorrects to ary.each from ary.each_with_object([]).with_index":
    var newSource = autocorrectSource("ary.each_with_object([]) { |v| v }")
    expect(newSource).to(eq("ary.each_with_object([]) { |v| v }"))
  test "an index is used as a block argument":
    expectNoOffenses("ary.each_with_index { |v, i| v; i }")
