
import
  emptyParameter

import
  rangeHelp

cop :
  type
    EmptyLambdaParameter* = ref object of Cop
    ##  This cop checks for parentheses for empty lambda parameters. Parentheses
    ##  for empty lambda parameters do not cause syntax errors, but they are
    ##  redundant.
    ## 
    ##  @example
    ##    # bad
    ##    -> () { do_something }
    ## 
    ##    # good
    ##    -> { do_something }
    ## 
    ##    # good
    ##    -> (arg) { do_something(arg) }
  const
    MSG = "Omit parentheses for the empty lambda parameters."
  method onBlock*(self: EmptyLambdaParameter; node: Node): void =
    var sendNode = node.sendNode
    if sendNode.isSendType():
    if node.sendNode.isLambdaLiteral:
      check(node)
  
  method autocorrect*(self: EmptyLambdaParameter; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var
        sendNode = node.parent.sendNode
        range = rangeBetween(sendNode.loc.expression.endPos,
                           node.loc.expression.endPos)
      corrector.remove(range))

