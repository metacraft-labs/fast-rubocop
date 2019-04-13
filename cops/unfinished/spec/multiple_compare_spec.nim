
import
  multiple_compare, test_tools

suite "MultipleCompare":
  var cop = MultipleCompare()
  let("config", proc (): void =
    Config.new)
  sharedExamples("Check to use two comparison operator", proc (operator1: string;
      operator2: string): void =
    var
      badSource = """x (lvar :operator1) y (lvar :operator2) z"""
      goodSource = """x (lvar :operator1) y && y (lvar :operator2) z"""
    test """registers an offense for (lvar :bad_source)""":
      inspectSource(badSource)
      expect(cop().offenses.size).to(eq(1))
      expect(cop().messages).to(eq(@["Use the `&&` operator to compare multiple values."]))
    test "autocorrects":
      var newSource = autocorrectSource(badSource)
      expect(newSource).to(eq(goodSource))
    test """accepts for (lvar :good_source)""":
      expectNoOffenses(goodSource))
  @["<", ">", "<=", ">="].repeatedPermutation(2, proc (operator1: string;
      operator2: string): void =
    includeExamples("Check to use two comparison operator", operator1, operator2))
  test "accepts to use one compare operator":
    expectNoOffenses("x < 1")
