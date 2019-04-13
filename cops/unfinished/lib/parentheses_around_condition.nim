
import
  safeAssignment

import
  parentheses

cop :
  type
    ParenthesesAroundCondition* = ref object of Cop
    ##  This cop checks for the presence of superfluous parentheses around the
    ##  condition of if/unless/while/until.
    ## 
    ##  @example
    ##    # bad
    ##    x += 1 while (x < 10)
    ##    foo unless (bar || baz)
    ## 
    ##    if (x > 10)
    ##    elsif (x < 3)
    ##    end
    ## 
    ##    # good
    ##    x += 1 while x < 10
    ##    foo unless bar || baz
    ## 
    ##    if x > 10
    ##    elsif x < 3
    ##    end
    ## 
    ##  @example AllowInMultilineConditions: false (default)
    ##    # bad
    ##    if (x > 10 &&
    ##       y > 10)
    ##    end
    ## 
    ##    # good
    ##     if x > 10 &&
    ##        y > 10
    ##     end
    ## 
    ##  @example AllowInMultilineConditions: true
    ##    # good
    ##    if (x > 10 &&
    ##       y > 10)
    ##    end
  nodeMatcher controlOpCondition, "          (begin $_ ...)\n"
  method onIf*(self: ParenthesesAroundCondition; node: Node): void =
    if node.isTernary:
      return
    processControlOp(node)

  method onWhile*(self: ParenthesesAroundCondition; node: Node): void =
    processControlOp(node)

  method autocorrect*(self: ParenthesesAroundCondition; node: Node): void =
    ParenthesesCorrector.correct(node)

  method processControlOp*(self: ParenthesesAroundCondition; node: Node): void =
    var cond = node.condition
    controlOpCondition cond:
      if isModifierOp(firstChild):
        return
      if isParensAllowed(cond):
        return
      addOffense(cond)

  method isModifierOp*(self: ParenthesesAroundCondition; node: Node): void =
    if node.isIfType() and node.isTernary:
      return false
    if node.isRescueType():
      return true
    node.isBasicConditional and node.isModifierForm

  method message*(self: ParenthesesAroundCondition; node: Node): void =
    var
      kw = node.parent.keyword
      article = if kw == "while":
        "a"
    """Don't use parentheses around the condition of (lvar :article) `(lvar :kw)`."""

  method isParensAllowed*(self: ParenthesesAroundCondition; node: Node): void =
    isParensRequired(node) or
      isSafeAssignment(node) and isSafeAssignmentAllowed or
      node.isMultiline and isAllowMultilineConditions

  method isAllowMultilineConditions*(self: ParenthesesAroundCondition): void =
    copConfig["AllowInMultilineConditions"]

