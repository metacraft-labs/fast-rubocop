
import
  onNormalIfUnless

cop :
  type
    OneLineConditional* = ref object of Cop
    ##  TODO: Make configurable.
    ##  Checks for uses of if/then/else/end on a single line.
    ## 
    ##  @example
    ##    # bad
    ##    if foo then boo else doo end
    ##    unless foo then boo else goo end
    ## 
    ##    # good
    ##    foo ? boo : doo
    ##    boo if foo
    ##    if foo then boo end
    ## 
    ##    # good
    ##    if foo
    ##      boo
    ##    else
    ##      doo
    ##    end
  const
    MSG = """Favor the ternary operator (`?:`) over `%<keyword>s/then/else/end` constructs."""
  method onNormalIfUnless*(self: OneLineConditional; node: Node): void =
    if node.isSingleLine and node.elseBranch:
    addOffense(node)

  method autocorrect*(self: OneLineConditional; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, replacement(node)))

  method message*(self: OneLineConditional; node: Node): void =
    format(MSG, keyword = node.keyword)

  method replacement*(self: OneLineConditional; node: Node): void =
    if node.parent:
    else:
      return toTernary(node)
    if @["and", "or"].isInclude(node.parent.type):
      return """((send nil :to_ternary
  (lvar :node)))"""
    if node.parent.isSendType() and node.parent.isOperatorMethod:
      return """((send nil :to_ternary
  (lvar :node)))"""
    toTernary(node)

  method toTernary*(self: OneLineConditional; node: Node): void =
    """(begin
  (send nil :expr_replacement
    (lvar :cond)))(begin
  (send nil :expr_replacement
    (lvar :else_clause)))"""

  method exprReplacement*(self: OneLineConditional; node: Node): void =
    if node.isNil():
      return "nil"
    if isRequiresParentheses(node):
      """((send
  (lvar :node) :source))"""
    else:
      node.source
  
  method isRequiresParentheses*(self: OneLineConditional; node: Node): void =
    if @["and", "or", "if"].isInclude(node.type):
      return true
    if node.isAssignment:
      return true
    if isMethodCallWithChangedPrecedence(node):
      return true
    isKeywordWithChangedPrecedence(node)

  method isMethodCallWithChangedPrecedence*(self: OneLineConditional; node: Node): void =
    if node.isSendType() and node.isArguments:
    else:
      return false
    if node.isParenthesizedCall:
      return false
    node.isOperatorMethod.!

  method isKeywordWithChangedPrecedence*(self: OneLineConditional; node: Node): void =
    if node.isKeyword:
    else:
      return false
    if node.isPrefixNot:
      return true
    node.isArguments and node.isParenthesizedCall.!

