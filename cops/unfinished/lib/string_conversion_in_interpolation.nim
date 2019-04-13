
cop :
  type
    StringConversionInInterpolation* = ref object of Cop
  const
    MSGDEFAULT = "Redundant use of `Object#to_s` in interpolation."
  const
    MSGSELF = """Use `self` instead of `Object#to_s` in interpolation."""
  nodeMatcher isToSWithoutArgs, "(send _ :to_s)"
  method onDstr*(self: StringConversionInInterpolation; node: Node): void =
    node.eachChildNode("begin", proc (beginNode: Node): void =
      var finalNode = beginNode.children.last()
      if isToSWithoutArgs finalNode:
      addOffense(finalNode, location = "selector"))

  method autocorrect*(self: StringConversionInInterpolation; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var receiver = node.receiver
      corrector.replace(node.sourceRange, if receiver:
        receiver.source
      ))

  method message*(self: StringConversionInInterpolation; node: Node): void =
    if node.receiver:
      MSGDEFAULT
  
