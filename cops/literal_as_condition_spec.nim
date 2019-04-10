
import
  tables

import
  literal_as_condition, test_tools

suite "LiteralAsCondition":
  var cop = LiteralAsCondition()
  for lit in @["1", "2.0", "[1]", "{}", ":sym", ":\"#{a}\""]:
    test """registers an offense for literal (lvar :lit) in if""":
      inspectSource("""        if (lvar :lit)
          top
        end
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
    test """registers an offense for literal (lvar :lit) in while""":
      inspectSource("""        while (lvar :lit)
          top
        end
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
    test """registers an offense for literal (lvar :lit) in post-loop while""":
      inspectSource("""        begin
          top
        end while((lvar :lit))
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
    test """registers an offense for literal (lvar :lit) in until""":
      inspectSource("""        until (lvar :lit)
          top
        end
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
    test """registers an offense for literal (lvar :lit) in post-loop until""":
      inspectSource("""        begin
          top
        end until (lvar :lit)
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
    test """registers an offense for literal (lvar :lit) in case""":
      inspectSource("""        case (lvar :lit)
        when x then top
        end
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
    test """(str "registers an offense for literal ")of a case without anything after case keyword""":
      inspectSource("""        case
        when (lvar :lit) then top
        end
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
    test """(str "accepts literal ")something after case keyword""":
      expectNoOffenses("""        case x
        when (lvar :lit) then top
        end
""".stripIndent)
    test """registers an offense for literal (lvar :lit) in &&""":
      inspectSource("""        if x && (lvar :lit)
          top
        end
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
    test """registers an offense for literal (lvar :lit) in complex cond""":
      inspectSource("""        if x && !(a && (lvar :lit)) && y && z
          top
        end
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
    test """registers an offense for literal (lvar :lit) in !""":
      inspectSource("""        if !(lvar :lit)
          top
        end
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
    test """registers an offense for literal (lvar :lit) in complex !""":
      inspectSource("""        if !(x && (y && (lvar :lit)))
          top
        end
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
    test """accepts literal (lvar :lit) if it's not an and/or operand""":
      expectNoOffenses("""        if test((lvar :lit))
          top
        end
""".stripIndent)
    test """accepts literal (lvar :lit) in non-toplevel and/or""":
      expectNoOffenses("""        if (a || (lvar :lit)).something
          top
        end
""".stripIndent)
    test """registers an offense for `!(lvar :lit)`""":
      inspectSource("""        !(lvar :lit)
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
    test """registers an offense for `not (lvar :lit)`""":
      inspectSource("""        not((lvar :lit))
""".stripIndent)
      expect(cop().offenses.size).to(eq(1))
  test "accepts array literal in case, if it has non-literal elements":
    expectNoOffenses("""      case [1, 2, x]
      when [1, 2, 5] then top
      end
""".stripIndent)
  test "accepts array literal in case, if it has nested non-literal element":
    expectNoOffenses("""      case [1, 2, [x, 1]]
      when [1, 2, 5] then top
      end
""".stripIndent)
  test "registers an offense for case with a primitive array condition":
    expectOffense("""      case [1, 2, [3, 4]]
           ^^^^^^^^^^^^^^ Literal `[1, 2, [3, 4]]` appeared as a condition.
      when [1, 2, 5] then top
      end
""".stripIndent)
  test "accepts dstr literal in case":
    expectNoOffenses("""      case "#{x}"
      when [1, 2, 5] then top
      end
""".stripIndent)
