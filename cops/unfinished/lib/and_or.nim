
import
  configurableEnforcedStyle

import
  rangeHelp

cop :
  type
    AndOr* = ref object of Cop
    ##  This cop checks for uses of `and` and `or`, and suggests using `&&` and
    ##  `||` instead. It can be configured to check only in conditions or in
    ##  all contexts.
    ## 
    ##  @example EnforcedStyle: always (default)
    ##    # bad
    ##    foo.save and return
    ## 
    ##    # bad
    ##    if foo and bar
    ##    end
    ## 
    ##    # good
    ##    foo.save && return
    ## 
    ##    # good
    ##    if foo && bar
    ##    end
    ## 
    ##  @example EnforcedStyle: conditionals
    ##    # bad
    ##    if foo and bar
    ##    end
    ## 
    ##    # good
    ##    foo.save && return
    ## 
    ##    # good
    ##    foo.save and return
    ## 
    ##    # good
    ##    if foo && bar
    ##    end
  const
    MSG = "Use `%<prefer>s` instead of `%<current>s`."
  method onAnd*(self: AndOr; node: Node): void =
    if style == "always":
      processLogicalOperator(node)
  
  method onIf*(self: AndOr; node: Node): void =
    if style == "conditionals":
      onConditionals(node)
  
  method autocorrect*(self: AndOr; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      node.eachChildNode(proc (expr: Node): void =
        if expr.isSendType():
          correctSend(expr, corrector)
        elif expr.isReturnType():
          correctOther(expr, corrector)
        elif expr.isAssignment:
          correctOther(expr, corrector)
      )
      corrector.replace(node.loc.operator, node.alternateOperator))

  method onConditionals*(self: AndOr; node: Node): void =
    node.condition.eachNode(proc (operator: Node): void =
      processLogicalOperator(operator))

  method processLogicalOperator*(self: AndOr; node: Node): void =
    if node.isLogicalOperator:
      return
    addOffense(node, location = "operator")

  method message*(self: AndOr; node: Node): void =
    format(MSG, prefer = node.alternateOperator, current = node.operator)

  method correctSend*(self: AndOr; node: Node; corrector: Corrector): void =
    if node.isMethod("!"):
      return correctNot(node, node.receiver, corrector)
    if node.isSetterMethod:
      return correctSetter(node, corrector)
    if node.isComparisonMethod:
      return correctOther(node, corrector)
    if isCorrectableSend(node):
    corrector.replace(whitespaceBeforeArg(node), "(")
    corrector.insertAfter(node.lastArgument.sourceRange, ")")

  method correctSetter*(self: AndOr; node: Node; corrector: Corrector): void =
    corrector.insertBefore(node.receiver.sourceRange, "(")
    corrector.insertAfter(node.lastArgument.sourceRange, ")")

  method correctNot*(self: AndOr; node: Node; receiver: Node; corrector: Corrector): void =
    ##  ! is a special case:
    ##  'x and !obj.method arg' can be auto-corrected if we
    ##  recurse down a level and add parens to 'obj.method arg'
    ##  however, 'not x' also parses as (send x :!)
    if node.isPrefixBang:
      if receiver.isSendType():
      correctSend(receiver, corrector)
    elif node.isPrefixNot:
      correctOther(node, corrector)
    else:
      raise("unrecognized unary negation operator")
  
  method correctOther*(self: AndOr; node: Node; corrector: Corrector): void =
    if node.sourceRange.begin.isIs("("):
      return
    corrector.insertBefore(node.sourceRange, "(")
    corrector.insertAfter(node.sourceRange, ")")

  method isCorrectableSend*(self: AndOr; node: Node): void =
    node.isParenthesized.! and node.isArguments and node.isMethod("[]").!

  method whitespaceBeforeArg*(self: AndOr; node: Node): void =
    var
      beginParen = node.loc.selector.endPos
      endParen = beginParen
    if node.source.=~():
    else:
      endParen += 1
    rangeBetween(beginParen, endParen)

