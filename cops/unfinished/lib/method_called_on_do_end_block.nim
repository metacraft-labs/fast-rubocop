
import
  rangeHelp

cop :
  type
    MethodCalledOnDoEndBlock* = ref object of Cop
    ##  This cop checks for methods called on a do...end block. The point of
    ##  this check is that it's easy to miss the call tacked on to the block
    ##  when reading code.
    ## 
    ##  @example
    ## 
    ##    a do
    ##      b
    ##    end.c
  const
    MSG = "Avoid chaining a method call on a do...end block."
  method onBlock*(self: MethodCalledOnDoEndBlock; node: Node): void =
    ignoreNode(node.sendNode)

  method onSend*(self: MethodCalledOnDoEndBlock; node: Node): void =
    if isIgnoredNode(node):
      return
    var receiver = node.receiver
    if receiver and receiver.isBlockType() and receiver.loc.end.isIs("end"):
    var range = rangeBetween(receiver.loc.end.beginPos, node.sourceRange.endPos)
    addOffense(location = range)

