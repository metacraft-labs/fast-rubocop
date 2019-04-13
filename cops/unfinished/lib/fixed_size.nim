
cop :
  type
    FixedSize* = ref object of Cop
  const
    MSG = "Do not compute the size of statically sized objects."
  nodeMatcher counter, "          (send ${array hash str sym} {:count :length :size} $...)\n"
  method onSend*(self: FixedSize; node: Node): void =
    if isAllowedParent(node.parent):
      return
    counter node:
      if isAllowedVariable(var) or isAllowedArgument(arg):
        return
      addOffense(node)

  method isAllowedVariable*(self: FixedSize; var: Node): void =
    isContainsSplat(var) or isContainsDoubleSplat(var)

  method isAllowedArgument*(self: FixedSize; arg: Array): void =
    arg and isNonStringArgument(arg[0])

  method isAllowedParent*(self: FixedSize; node: Node): void =
    node and
      node.isCasgnType() or node.isBlockType()

  method isContainsSplat*(self: FixedSize; node: Node): void =
    if node.isArrayType():
    node.eachChildNode("splat").isAny()

  method isContainsDoubleSplat*(self: FixedSize; node: Node): void =
    if node.isHashType():
    node.eachChildNode("kwsplat").isAny()

  method isNonStringArgument*(self: FixedSize; node: Node): void =
    node and node.isStrType().!

