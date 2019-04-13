
import
  single_line_block_params, test_tools

RSpec.describe(SingleLineBlockParams, "config", proc (): void =
  var cop = ()
  let("cop_config", proc (): void =
    {"Methods": @[{"reduce": @["a", "e"]}.newTable(),
                 {"test": @["x", "y"]}.newTable()]}.newTable())
  test "finds wrong argument names in calls with different syntax":
    expectOffense("""      def m
        [0, 1].reduce { |c, d| c + d }
                        ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce{ |c, d| c + d }
                       ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce(5) { |c, d| c + d }
                           ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce(5){ |c, d| c + d }
                          ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce (5) { |c, d| c + d }
                            ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce(5) { |c, d| c + d }
                           ^^^^^^ Name `reduce` block params `|a, e|`.
        ala.test { |x, z| bala }
                   ^^^^^^ Name `test` block params `|x, y|`.
      end
""".stripIndent)
  test "allows calls with proper argument names":
    expectNoOffenses("""      def m
        [0, 1].reduce { |a, e| a + e }
        [0, 1].reduce{ |a, e| a + e }
        [0, 1].reduce(5) { |a, e| a + e }
        [0, 1].reduce(5){ |a, e| a + e }
        [0, 1].reduce (5) { |a, e| a + e }
        [0, 1].reduce(5) { |a, e| a + e }
        ala.test { |x, y| bala }
      end
""".stripIndent)
  test "allows an unused parameter to have a leading underscore":
    expectNoOffenses("File.foreach(filename).reduce(0) { |a, _e| a + 1 }")
  test "finds incorrectly named parameters with leading underscores":
    expectOffense("""      File.foreach(filename).reduce(0) { |_x, _y| }
                                         ^^^^^^^^ Name `reduce` block params `|a, e|`.
""".stripIndent)
  test "ignores do..end blocks":
    expectNoOffenses("""      def m
        [0, 1].reduce do |c, d|
          c + d
        end
      end
""".stripIndent)
  test "ignores :reduce symbols":
    expectNoOffenses("""      def m
        call_method(:reduce) { |a, b| a + b}
      end
""".stripIndent)
  test "does not report when destructuring is used":
    expectNoOffenses("""      def m
        test.reduce { |a, (id, _)| a + id}
      end
""".stripIndent)
  test "does not report if no block arguments are present":
    expectNoOffenses("""      def m
        test.reduce { true }
      end
""".stripIndent))
