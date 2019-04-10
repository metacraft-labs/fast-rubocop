
import
  redundant_sort_by, test_tools

suite "RedundantSortBy":
  var cop = RedundantSortBy()
  test "autocorrects array.sort_by { |x| x }":
    var newSource = autocorrectSource("array.sort_by { |x| x }")
    expect(newSource).to(eq("array.sort"))
  test "autocorrects array.sort_by { |y| y }":
    var newSource = autocorrectSource("array.sort_by { |y| y }")
    expect(newSource).to(eq("array.sort"))
  test "autocorrects array.sort_by do |x| x end":
    var newSource = autocorrectSource("""      array.sort_by do |x|
        x
      end
""".stripIndent)
    expect(newSource).to(eq("array.sort\n"))
  test "formats the error message correctly for array.sort_by { |x| x }":
    expectOffense("""      array.sort_by { |x| x }
            ^^^^^^^^^^^^^^^^^ Use `sort` instead of `sort_by { |x| x }`.
""".stripIndent)
