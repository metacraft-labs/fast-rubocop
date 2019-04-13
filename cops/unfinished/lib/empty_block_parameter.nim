
import
  emptyParameter

import
  rangeHelp

cop :
  type
    EmptyBlockParameter* = ref object of Cop
    ##  This cop checks for pipes for empty block parameters. Pipes for empty
    ##  block parameters do not cause syntax errors, but they are redundant.
    ## 
    ##  @example
    ##    # bad
    ##    a do ||
    ##      do_something
    ##    end
    ## 
    ##    # bad
    ##    a { || do_something }
    ## 
    ##    # good
    ##    a do
    ##    end
    ## 
    ##    # good
    ##    a { do_something }
  const
    MSG = "Omit pipes for the empty block parameters."
  method onBlock*(self: EmptyBlockParameter; node: Node): void =
    var sendNode = node.sendNode
    if sendNode.isSendType() and sendNode.isLambdaLiteral:
    else:
      check(node)
  
  method autocorrect*(self: EmptyBlockParameter; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var
        block = node.parent
        range = rangeBetween(block.loc.begin.endPos, node.loc.expression.endPos)
      corrector.remove(range))

