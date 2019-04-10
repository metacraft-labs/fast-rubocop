
import
  sequtils

import
  safeAssignment

import
  configurableEnforcedStyle

import
  surroundingSpace

cop :
  type
    TernaryParentheses* = ref object of Cop
    ##  This cop checks for the presence of parentheses around ternary
    ##  conditions. It is configurable to enforce inclusion or omission of
    ##  parentheses using `EnforcedStyle`. Omission is only enforced when
    ##  removing the parentheses won't cause a different behavior.
    ## 
    ##  @example EnforcedStyle: require_no_parentheses (default)
    ##    # bad
    ##    foo = (bar?) ? a : b
    ##    foo = (bar.baz?) ? a : b
    ##    foo = (bar && baz) ? a : b
    ## 
    ##    # good
    ##    foo = bar? ? a : b
    ##    foo = bar.baz? ? a : b
    ##    foo = bar && baz ? a : b
    ## 
    ##  @example EnforcedStyle: require_parentheses
    ##    # bad
    ##    foo = bar? ? a : b
    ##    foo = bar.baz? ? a : b
    ##    foo = bar && baz ? a : b
    ## 
    ##    # good
    ##    foo = (bar?) ? a : b
    ##    foo = (bar.baz?) ? a : b
    ##    foo = (bar && baz) ? a : b
    ## 
    ##  @example EnforcedStyle: require_parentheses_when_complex
    ##    # bad
    ##    foo = (bar?) ? a : b
    ##    foo = (bar.baz?) ? a : b
    ##    foo = bar && baz ? a : b
    ## 
    ##    # good
    ##    foo = bar? ? a : b
    ##    foo = bar.baz? ? a : b
    ##    foo = (bar && baz) ? a : b
  const
    VARIABLETYPES = VARIABLES
  const
    NONCOMPLEXTYPES = ("const", "defined?", "yield")
  const
    MSG = "%<command>s parentheses for ternary conditions."
  const
    MSGCOMPLEX = """%<command>s parentheses for ternary expressions with complex conditions."""
  nodeMatcher methodName, """          {($:defined? (send nil? _) ...)
           (send {_ nil?} $_ _ ...)}
"""
  method onIf*(self: TernaryParentheses; node: Node): void =
    if node.isTernary and isInfiniteLoop.! and isOffense(node):
    addOffense(node, location = node.sourceRange)

  method autocorrect*(self: TernaryParentheses; node: Node): void =
    var condition = node.condition
    if isParenthesized(condition) and
      isSafeAssignment(condition) or isUnsafeAutocorrect(condition):
      return
    if isParenthesized(condition):
      correctParenthesized(condition)
    else:
      correctUnparenthesized(condition)
  
  method isOffense*(self: TernaryParentheses; node: Node): void =
    var condition = node.condition
    if isSafeAssignment(condition):
      isSafeAssignmentAllowed.!
    else:
      var parens = isParenthesized(condition)
      case style
      of "require_parentheses_when_complex":
        if isComplexCondition(condition):
          parens.!
      else:
        if isRequireParentheses:
          parens.!
  
  method isComplexCondition*(self: TernaryParentheses; condition: Node): void =
    ##  If the condition is parenthesized we recurse and check for any
    ##  complex expressions within it.
    if condition.isBeginType():
      condition.toA.anyIt:
        isComplexCondition(it)
    elif isNonComplexExpression(condition):
      false
  
  method isNonComplexExpression*(self: TernaryParentheses; condition: Node): void =
    ##  Anything that is not a variable, constant, or method/.method call
    ##  will be counted as a complex expression.
    NONCOMPLEXTYPES.isInclude(condition.type) or isNonComplexSend(condition)

  method isNonComplexSend*(self: TernaryParentheses; node: Node): void =
    if node.isSendType():
    else:
      return false
    node.isOperatorMethod.! or node.isMethod("[]")

  method message*(self: TernaryParentheses; node: Node): void =
    if isRequireParenthesesWhenComplex:
      var command = if isParenthesized(node.condition):
        "Only use"
      format(MSGCOMPLEX, command = command)
    else:
      command = if isRequireParentheses:
        "Use"
      format(MSG, command = command)

  method isRequireParentheses*(self: TernaryParentheses): void =
    style == "require_parentheses"

  method isRequireParenthesesWhenComplex*(self: TernaryParentheses): void =
    style == "require_parentheses_when_complex"

  method isRedundantParenthesesEnabled*(self: TernaryParentheses): void =
    self.config.forCop("Style/RedundantParentheses").fetch("Enabled")

  method isParenthesized*(self: TernaryParentheses; node: Node): void =
    node.isBeginType()

  method isInfiniteLoop*(self: TernaryParentheses): void =
    ##  When this cop is configured to enforce parentheses and the
    ##  `RedundantParentheses` cop is enabled, it will cause an infinite loop
    ##  as they compete to add and remove the parentheses respectively.
    isRequireParentheses and isRedundantParenthesesEnabled

  method isUnsafeAutocorrect*(self: TernaryParentheses; condition: Node): void =
    condition.children.anyIt:
      isUnparenthesizedMethodCall(it)

  method isUnparenthesizedMethodCall*(self: TernaryParentheses; child: Node): void =
    methodName child.=~() and child.isParenthesized.!

  method correctParenthesized*(self: TernaryParentheses; condition: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.remove(condition.loc.begin)
      corrector.remove(condition.loc.end)
      if isWhitespaceAfter(condition):
      else:
        corrector.insertAfter(condition.loc.end, " ")
    )

  method correctUnparenthesized*(self: TernaryParentheses; condition: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.insertBefore(condition.sourceRange, "(")
      corrector.insertAfter(condition.sourceRange, ")"))

  method isWhitespaceAfter*(self: TernaryParentheses; node: Node): void =
    var
      index = indexOfLastToken(node)
      lastToken = processedSource.tokens[index]
    lastToken.isSpaceAfter

