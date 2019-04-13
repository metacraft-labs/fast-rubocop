
cop :
  type
    EmptyInterpolation* = ref object of Cop
  const
    MSG = "Empty interpolation detected."
  method onDstr*(self: EmptyInterpolation; node: Node): void =
    node.eachChildNode("begin", proc (beginNode: Node): void =
      if beginNode.children.isEmpty:
        addOffense(beginNode)
    )

  method autocorrect*(self: EmptyInterpolation; node: Node): void =
    lambda(proc (collector: Corrector): void =
      collector.remove(node.loc.expression))

