
import
  tables

import
  self_assignment, test_tools

suite "SelfAssignment":
  var cop = SelfAssignment()
  for op, var in @["+", "-", "*", "**", "/", "|", "&", "||", "&&"].product(
      @["x", "@x", "@@x"]):
    test """registers an offense for non-shorthand assignment (lvar :op) and (lvar :var)""":
      inspectSource("""(lvar :var) = (lvar :var) (lvar :op) y""")
      expect(cop().offenses.size).to(eq(1))
      expect(cop().messages).to(eq(@["""Use self-assignment shorthand `(lvar :op)=`."""]))
    test """accepts shorthand assignment for (lvar :op) and (lvar :var)""":
      expectNoOffenses("""(lvar :var) (lvar :op)= y""")
    test """auto-corrects a non-shorthand assignment (lvar :op) and (lvar :var)""":
      var newSource = autocorrectSource("""(lvar :var) = (lvar :var) (lvar :op) y""")
      expect(newSource).to(eq("""(lvar :var) (lvar :op)= y"""))
