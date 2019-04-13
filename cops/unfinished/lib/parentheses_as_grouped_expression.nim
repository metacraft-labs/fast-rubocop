
import
  rangeHelp

cop :
  type
    ParenthesesAsGroupedExpression* = ref object of Cop
  const
    MSG = "`(...)` interpreted as grouped expression."
  method onSend*(self: ParenthesesAsGroupedExpression; node: Node): void =
    if node.arguments.isOne():
    if node.isOperatorMethod or node.isSetterMethod:
      return
    if node.firstArgument.source.isStartWith("("):
    var spaceLength = spacesBeforeLeftParenthesis(node)
    if spaceLength > 0:
    var range = spaceRange(node.firstArgument.sourceRange, spaceLength)
    addOffense(location = range)

  method spacesBeforeLeftParenthesis*(self: ParenthesesAsGroupedExpression;
                                     node: Node): void =
    var
      receiver = node.receiver
      receiverLength = if receiver:
        receiver.source.length
      withoutReceiver = node.source[]
      methodRegexp = Regexp.escape(node.methodName)
      match = withoutReceiver.match()
    if match:
      match.captures()[0].length
  
  method spaceRange*(self: ParenthesesAsGroupedExpression; expr: Range;
                    spaceLength: Integer): void =
    rangeBetween(expr.beginPos - spaceLength, expr.beginPos)

