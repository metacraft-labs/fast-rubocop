
cop :
  type
    NonLocalExitFromIterator* = ref object of Cop
  const
    MSG = """Non-local exit from iterator, without return value. `next`, `break`, `Array#find`, `Array#any?`, etc. is preferred."""
  nodeMatcher isChainedSend, "(send !nil? ...)"
  nodeMatcher isDefineMethod,
             "          (send _ {:define_method :define_singleton_method} _)\n"
  method onReturn*(self: NonLocalExitFromIterator; returnNode: Node): void =
    if isReturnValue(returnNode):
      return
    returnNode.eachAncestor("block", "def", "defs", proc (node: Node): void =
      if isScopedNode(node):
        break
      if isDefineMethod sendNode:
        break
      if argsNode.children.isEmpty:
        continue
      if isChainedSend sendNode:
        addOffense(returnNode, location = "keyword")
        break )

  method isScopedNode*(self: NonLocalExitFromIterator; node: Node): void =
    node.isDefType() or node.isDefsType() or node.isLambda

  method isReturnValue*(self: NonLocalExitFromIterator; returnNode: Node): void =
    returnNode.children.isEmpty.!

