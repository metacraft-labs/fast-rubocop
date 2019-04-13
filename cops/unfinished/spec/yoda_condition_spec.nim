
import
  yoda_condition, test_tools

RSpec.describe(YodaCondition, "config", proc (): void =
  var cop = ()
  let("error_message", proc (): void =
    "Reverse the order of the operands `%s`.")
  let("ruby_version", proc (): void =
    0.0)
  sharedExamples("accepts", proc (code: string): void =
    let("source", proc (): void =
      code)
    test "does not register an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  sharedExamples("offense", proc (code: string): void =
    let("source", proc (): void =
      code)
    test """registers an offense for (lvar :code)""":
      expect(cop().offenses.size).to(eq(1))
      expect(cop().offenses[0].message).to(eq(format(errorMessage(), code))))
  sharedExamples("autocorrect", proc (code: string; corrected: string): void =
    let("source", proc (): void =
      code)
    test "autocorrects code":
      expect(autocorrectSource(source())).to(eq(corrected)))
  before(proc (): void =
    inspectSource(source()))
  context("enforce not yoda", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "forbid_for_all_comparison_operators"}.newTable())
    itBehavesLike("accepts", "b.value == 2")
    itBehavesLike("accepts", "b&.value == 2")
    itBehavesLike("accepts", "@value == 2")
    itBehavesLike("accepts", "@@value == 2")
    itBehavesLike("accepts", "b = 1; b == 2")
    itBehavesLike("accepts", "$var == 5")
    itBehavesLike("accepts", "foo == \"bar\"")
    itBehavesLike("accepts", "foo[0] > \"bar\" || baz != \"baz\"")
    itBehavesLike("accepts", "node = last_node.parent")
    itBehavesLike("accepts", "(first_line - second_line) > 0")
    itBehavesLike("accepts", "5 == 6")
    itBehavesLike("accepts", "[1, 2, 3] <=> [4, 5, 6]")
    itBehavesLike("accepts", "!true")
    itBehavesLike("accepts", "not true")
    itBehavesLike("accepts", "0 <=> val")
    itBehavesLike("accepts", "\"foo\" === bar")
    itBehavesLike("offense", "\"foo\" == bar")
    itBehavesLike("offense", "nil == bar")
    itBehavesLike("offense", "false == active?")
    itBehavesLike("offense", "15 != @foo")
    itBehavesLike("offense", "42 < bar")
    context("autocorrection", proc (): void =
      itBehavesLike("autocorrect", "if 10 == my_var; end", "if my_var == 10; end")
      itBehavesLike("autocorrect", "if 2 < bar;end", "if bar > 2;end")
      itBehavesLike("autocorrect", "foo = 42 if 42 > bar", "foo = 42 if bar < 42")
      itBehavesLike("autocorrect", "42 <= foo ? bar : baz",
                    "foo >= 42 ? bar : baz")
      itBehavesLike("autocorrect", "42 >= foo ? bar : baz",
                    "foo <= 42 ? bar : baz")
      itBehavesLike("autocorrect", "nil != foo ? bar : baz",
                    "foo != nil ? bar : baz"))
    context("with EnforcedStyle: forbid_for_equality_operators_only", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyle": "forbid_for_equality_operators_only"}.newTable())
      itBehavesLike("accepts", "42 < bar")
      itBehavesLike("accepts", "nil >= baz")
      itBehavesLike("accepts", "3 < a && a < 5")
      itBehavesLike("offense", "42 != answer")
      itBehavesLike("offense", "false == foo")))
  context("enforce yoda", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "require_for_all_comparison_operators"}.newTable())
    itBehavesLike("accepts", "2 == b.value")
    itBehavesLike("accepts", "2 == b&.value")
    itBehavesLike("accepts", "2 == @value")
    itBehavesLike("accepts", "2 == @@value")
    itBehavesLike("accepts", "b = 1; 2 == b")
    itBehavesLike("accepts", "5 == $var")
    itBehavesLike("accepts", "\"bar\" == foo")
    itBehavesLike("accepts", "\"bar\" > foo[0] || \"bar\" != baz")
    itBehavesLike("accepts", "node = last_node.parent")
    itBehavesLike("accepts", "0 < (first_line - second_line)")
    itBehavesLike("accepts", "5 == 6")
    itBehavesLike("accepts", "[1, 2, 3] <=> [4, 5, 6]")
    itBehavesLike("accepts", "!true")
    itBehavesLike("accepts", "not true")
    itBehavesLike("accepts", "0 <=> val")
    itBehavesLike("accepts", "bar === \"foo\"")
    itBehavesLike("offense", "bar == \"foo\"")
    itBehavesLike("offense", "bar == nil")
    itBehavesLike("offense", "active? == false")
    itBehavesLike("offense", "@foo != 15")
    itBehavesLike("offense", "bar > 42")
    context("autocorrection", proc (): void =
      itBehavesLike("autocorrect", "if my_var == 10; end", "if 10 == my_var; end")
      itBehavesLike("autocorrect", "if bar > 2;end", "if 2 < bar;end")
      itBehavesLike("autocorrect", "foo = 42 if bar < 42", "foo = 42 if 42 > bar")
      itBehavesLike("autocorrect", "foo >= 42 ? bar : baz",
                    "42 <= foo ? bar : baz")
      itBehavesLike("autocorrect", "foo <= 42 ? bar : baz",
                    "42 >= foo ? bar : baz")
      itBehavesLike("autocorrect", "foo != nil ? bar : baz",
                    "nil != foo ? bar : baz"))
    context("with EnforcedStyle: require_for_equality_operators_only", proc (): void =
      let("cop_config", proc (): void =
        {"EnforcedStyle": "require_for_equality_operators_only"}.newTable())
      itBehavesLike("accepts", "bar > 42")
      itBehavesLike("accepts", "bar <= nil")
      itBehavesLike("accepts", "a > 3 && 5 > a")
      itBehavesLike("offense", "answer != 42")
      itBehavesLike("offense", "foo == false"))))
