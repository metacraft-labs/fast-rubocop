
import
  tables

import
  useless_comparison, test_tools

suite "UselessComparison":
  var cop = UselessComparison()
  for op in OPS:
    test """registers an offense for a simple comparison with (lvar :op)""":
      inspectSource("""        5 (lvar :op) 5
        a (lvar :op) a
""".stripIndent)
      expect(cop().offenses.size).to(eq(2))
    test """registers an offense for a complex comparison with (lvar :op)""":
      inspectSource("""        5 + 10 * 30 (lvar :op) 5 + 10 * 30
        a.top(x) (lvar :op) a.top(x)
""".stripIndent)
      expect(cop().offenses.size).to(eq(2))
  test "works with lambda.()":
    expectOffense("""      a.(x) > a.(x)
            ^ Comparison of something with itself detected.
""".stripIndent)
