
import
  ternary_parentheses, test_tools

RSpec.describe(TernaryParentheses, "config", proc (): void =
  var cop = ()
  before(proc (): void =
    inspectSource(source()))
  let("redundant_parens_enabled", proc (): void =
    false)
  let("other_cops", proc (): void =
    {"Style/RedundantParentheses": {"Enabled": redundantParensEnabled()}.newTable()}.newTable())
  sharedExamples("code with offense", proc (code: string; expected: string): void =
    context("""when checking (lvar :code)""", proc (): void =
      let("source", proc (): void =
        code)
      test "registers an offense":
        expect(cop().offenses.size).to(eq(1))
        expect(cop().messages).to(eq(@[message()]))
      if expected:
        test "auto-corrects":
          expect(autocorrectSource(code)).to(eq(expected))
        test "claims to auto-correct":
          autocorrectSource(code)
          expect(cop().offenses.last().status).to(eq("corrected"))
      else:
        test "does not auto-correct":
          expect(autocorrectSource(code)).to(eq(code))
        test "does not claim to auto-correct":
          autocorrectSource(code)
          expect(cop().offenses.last().status).to(eq("uncorrected"))))
  sharedExamples("code without offense", proc (code: string): void =
    let("source", proc (): void =
      code)
    test "does not register an offense":
      expect(cop().offenses.isEmpty).to(be(true)))
  sharedExamples("safe assignment disabled", proc (style: string): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": style, "AllowSafeAssignment": false}.newTable())
    itBehavesLike("code with offense", "foo = (bar = find_bar) ? a : b")
    itBehavesLike("code with offense", "foo = bar = (baz = find_baz) ? a : b")
    itBehavesLike("code with offense", "foo = (bar = baz = find_baz) ? a : b"))
  context("when configured to enforce parentheses inclusion", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "require_parentheses"}.newTable())
    let("message", proc (): void =
      "Use parentheses for ternary conditions.")
    context("with a simple condition", proc (): void =
      itBehavesLike("code with offense", "foo = bar? ? a : b",
                    "foo = (bar?) ? a : b")
      itBehavesLike("code with offense", "foo = yield ? a : b",
                    "foo = (yield) ? a : b")
      itBehavesLike("code with offense", "foo = bar[:baz] ? a : b",
                    "foo = (bar[:baz]) ? a : b"))
    context("with a complex condition", proc (): void =
      itBehavesLike("code with offense", "foo = 1 + 1 == 2 ? a : b",
                    "foo = (1 + 1 == 2) ? a : b")
      itBehavesLike("code with offense", "foo = bar && baz ? a : b",
                    "foo = (bar && baz) ? a : b")
      itBehavesLike("code with offense", "foo = foo1 == foo2 ? a : b",
                    "foo = (foo1 == foo2) ? a : b")
      itBehavesLike("code with offense", "foo = bar.baz? ? a : b",
                    "foo = (bar.baz?) ? a : b")
      itBehavesLike("code with offense", "foo = bar && (baz || bar) ? a : b",
                    "foo = (bar && (baz || bar)) ? a : b"))
    context("with an assignment condition", proc (): void =
      itBehavesLike("code with offense", "foo = bar = baz ? a : b",
                    "foo = bar = (baz) ? a : b")
      itBehavesLike("code with offense", "foo = bar = baz = find_baz ? a : b",
                    "foo = bar = baz = (find_baz) ? a : b")
      itBehavesLike("code with offense", "foo = bar = baz == 1 ? a : b",
                    "foo = bar = (baz == 1) ? a : b")
      itBehavesLike("code without offense",
                    "foo = (bar = baz = find_baz) ? a : b")))
  context("when configured to enforce parentheses omission", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "require_no_parentheses"}.newTable())
    let("message", proc (): void =
      "Omit parentheses for ternary conditions.")
    context("with a simple condition", proc (): void =
      itBehavesLike("code with offense", "foo = (bar?) ? a : b",
                    "foo = bar? ? a : b")
      itBehavesLike("code with offense", "foo = (yield) ? a : b",
                    "foo = yield ? a : b")
      itBehavesLike("code with offense", "foo = (bar[:baz]) ? a : b",
                    "foo = bar[:baz] ? a : b"))
    context("with a complex condition", proc (): void =
      itBehavesLike("code with offense", "foo = (1 + 1 == 2) ? a : b",
                    "foo = 1 + 1 == 2 ? a : b")
      itBehavesLike("code with offense", "foo = (foo1 == foo2) ? a : b",
                    "foo = foo1 == foo2 ? a : b")
      itBehavesLike("code with offense", "foo = (bar && baz) ? a : b",
                    "foo = bar && baz ? a : b")
      itBehavesLike("code with offense", "foo = (bar.baz?) ? a : b",
                    "foo = bar.baz? ? a : b")
      itBehavesLike("code without offense", "foo = bar && (baz || bar) ? a : b"))
    context("with an assignment condition", proc (): void =
      itBehavesLike("code without offense", "foo = (bar = find_bar) ? a : b")
      itBehavesLike("code without offense",
                    "foo = bar = (baz = find_baz) ? a : b")
      itBehavesLike("code with offense", "foo = bar = (baz == 1) ? a : b",
                    "foo = bar = baz == 1 ? a : b")
      itBehavesLike("code without offense",
                    "foo = (bar = baz = find_baz) ? a : b")
      itBehavesLike("safe assignment disabled", "require_no_parentheses"))
    context("with an unparenthesized method call condition", proc (): void =
      itBehavesLike("code with offense", "foo = (defined? bar) ? a : b")
      itBehavesLike("code with offense", "foo = (baz? bar) ? a : b")
      context("when calling method on a receiver", proc (): void =
        itBehavesLike("code with offense", "foo = (baz.foo? bar) ? a : b"))
      context("when calling method on a literal receiver", proc (): void =
        itBehavesLike("code with offense", "foo = (\"bar\".foo? bar) ? a : b"))
      context("when calling method on a constant receiver", proc (): void =
        itBehavesLike("code with offense", "foo = (Bar.foo? bar) ? a : b"))
      context("when calling method with multiple arguments", proc (): void =
        itBehavesLike("code with offense", "foo = (baz.foo? bar, baz) ? a : b")))
    context("with condition including a range", proc (): void =
      itBehavesLike("code without offense", "(foo..bar).include?(baz) ? a : b"))
    context("with no space between the parentheses and question mark", proc (): void =
      itBehavesLike("code with offense", "(foo)? a : b", "foo ? a : b")))
  context("configured for parentheses on complex and there are parens", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "require_parentheses_when_complex"}.newTable())
    let("message", proc (): void =
      "Only use parentheses for ternary expressions with complex conditions.")
    context("with a simple condition", proc (): void =
      itBehavesLike("code with offense", "foo = (bar?) ? a : b",
                    "foo = bar? ? a : b")
      itBehavesLike("code with offense", "foo = (yield) ? a : b",
                    "foo = yield ? a : b")
      itBehavesLike("code with offense", "foo = (bar[:baz]) ? a : b",
                    "foo = bar[:baz] ? a : b"))
    context("with a complex condition", proc (): void =
      itBehavesLike("code with offense", "foo = (bar.baz?) ? a : b",
                    "foo = bar.baz? ? a : b")
      itBehavesLike("code without offense", "foo = (bar && (baz || bar)) ? a : b"))
    context("with an assignment condition", proc (): void =
      itBehavesLike("code without offense", "foo = (bar = find_bar) ? a : b")
      itBehavesLike("code without offense",
                    "foo = baz = (bar = find_bar) ? a : b")
      itBehavesLike("code without offense", "foo = bar = (bar == 1) ? a : b")
      itBehavesLike("code without offense",
                    "foo = (bar = baz = find_bar) ? a : b")
      itBehavesLike("safe assignment disabled",
                    "require_parentheses_when_complex"))
    context("with method call condition", proc (): void =
      itBehavesLike("code with offense", "foo = (defined? bar) ? a : b")
      itBehavesLike("code with offense",
                    "(%w(a b).include? params[:t]) ? \"ab\" : \"c\"")
      itBehavesLike("code with offense",
                    "(%w(a b).include? params[:t], 3) ? \"ab\" : \"c\"")
      itBehavesLike("code with offense",
                    "(%w(a b).include?(params[:t], x)) ? \"ab\" : \"c\"",
                    "%w(a b).include?(params[:t], x) ? \"ab\" : \"c\"")
      itBehavesLike("code with offense",
                    "(%w(a b).include? \"a\") ? \"ab\" : \"c\"")
      itBehavesLike("code with offense",
                    "(%w(a b).include?(\"a\")) ? \"ab\" : \"c\"",
                    "%w(a b).include?(\"a\") ? \"ab\" : \"c\"")
      itBehavesLike("code with offense", "foo = (baz? bar) ? a : b")
      context("when calling method on a receiver", proc (): void =
        itBehavesLike("code with offense", "foo = (baz.foo? bar) ? a : b")))
    context("with condition including a range", proc (): void =
      itBehavesLike("code without offense", "(foo..bar).include?(baz) ? a : b")))
  context("configured for parentheses on complex and there are no parens", proc (): void =
    let("cop_config", proc (): void =
      {"EnforcedStyle": "require_parentheses_when_complex"}.newTable())
    let("message", proc (): void =
      "Use parentheses for ternary expressions with complex conditions.")
    context("with complex condition", proc (): void =
      itBehavesLike("code with offense", "foo = 1 + 1 == 2 ? a : b",
                    "foo = (1 + 1 == 2) ? a : b")
      itBehavesLike("code with offense", "foo = bar && baz ? a : b",
                    "foo = (bar && baz) ? a : b")
      itBehavesLike("code with offense", "foo = bar && baz || bar ? a : b",
                    "foo = (bar && baz || bar) ? a : b")
      itBehavesLike("code with offense", "foo = bar && (baz != bar) ? a : b",
                    "foo = (bar && (baz != bar)) ? a : b")
      itBehavesLike("code with offense", "foo = 1 < (bar.baz?) ? a : b",
                    "foo = (1 < (bar.baz?)) ? a : b")
      itBehavesLike("code with offense", "foo = 1 <= (bar ** baz) ? a : b",
                    "foo = (1 <= (bar ** baz)) ? a : b")
      itBehavesLike("code with offense", "foo = 1 >= bar * baz ? a : b",
                    "foo = (1 >= bar * baz) ? a : b")
      itBehavesLike("code with offense", "foo = bar + baz ? a : b",
                    "foo = (bar + baz) ? a : b")
      itBehavesLike("code with offense", "foo = bar - baz ? a : b",
                    "foo = (bar - baz) ? a : b")
      itBehavesLike("code with offense", "foo = bar < baz ? a : b",
                    "foo = (bar < baz) ? a : b"))
    context("with an assignment condition", proc (): void =
      itBehavesLike("code with offense", "foo = bar = baz == 1 ? a : b",
                    "foo = bar = (baz == 1) ? a : b")
      itBehavesLike("code without offense", "foo = (bar = baz == 1) ? a : b")))
  context("when `RedundantParenthesis` would cause an infinite loop", proc (): void =
    let("redundant_parens_enabled", proc (): void =
      true)
    let("cop_config", proc (): void =
      {"EnforcedStyle": "require_parentheses",
       "SupportedStyles": @["require_parentheses", "require_no_parentheses"]}.newTable())
    itBehavesLike("code without offense", "foo = bar? ? a : b")))
