
cop :
  type
    EmptyExpression* = ref object of Cop
  const
    MSG = "Avoid empty expressions."
  method onBegin*(self: EmptyExpression; node: Node): void =
    if isEmptyExpression(node):
    addOffense(node, location = node.sourceRange)

  method isEmptyExpression*(self: EmptyExpression; beginNode: Node): void =
    beginNode.children.isEmpty

