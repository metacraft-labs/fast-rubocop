
cop :
  type
    AmbiguousBlockAssociation* = ref object of Cop
  const
    MSG = """Parenthesize the param `%<param>s` to make sure that the block will be associated with the `%<method>s` method call."""
  method onSend*(self: AmbiguousBlockAssociation; node: Node): void =
    if node.isArguments.! or node.isParenthesized or node.lastArgument.isLambda or
        isAllowedMethod(node):
      return
    if isAmbiguousBlockAssociation(node):
    addOffense(node)

  method isAmbiguousBlockAssociation*(self: AmbiguousBlockAssociation;
                                     sendNode: Node): void =
    sendNode.lastArgument.isBlockType() and
        sendNode.lastArgument.sendNode.isArguments.!

  method isAllowedMethod*(self: AmbiguousBlockAssociation; node: Node): void =
    node.isAssignment or node.isOperatorMethod or node.isMethod("[]")

  method message*(self: AmbiguousBlockAssociation; sendNode: Node): void =
    var blockParam = sendNode.lastArgument
    format(MSG, param = blockParam.source, method = blockParam.sendNode.source)

