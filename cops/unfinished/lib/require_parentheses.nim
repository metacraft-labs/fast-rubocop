
import
  rangeHelp

cop :
  type
    RequireParentheses* = ref object of Cop
  const
    MSG = """Use parentheses in the method call to avoid confusion about precedence."""
  method onSend*(self: RequireParentheses; node: Node): void =
    if node.isArguments.! or node.isParenthesized:
      return
    if node.firstArgument.isIfType() and node.firstArgument.isTernary:
      checkTernary(node.firstArgument, node)
    elif node.isPredicateMethod:
      checkPredicate(node.lastArgument, node)
  
  method checkTernary*(self: RequireParentheses; ternary: Node; node: Node): void =
    if ternary.condition.isOperatorKeyword:
    var range = rangeBetween(node.sourceRange.beginPos,
                          ternary.condition.sourceRange.endPos)
    addOffense(range, location = range)

  method checkPredicate*(self: RequireParentheses; predicate: Node; node: Node): void =
    if predicate.isOperatorKeyword:
    addOffense(node)

