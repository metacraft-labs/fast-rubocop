
cop :
  type
    SpaceInsideRangeLiteral* = ref object of Cop
  const
    MSG = "Space inside range literal."
  method onIrange*(self: SpaceInsideRangeLiteral; node: Node): void =
    check(node)

  method onErange*(self: SpaceInsideRangeLiteral; node: Node): void =
    check(node)

  method autocorrect*(self: SpaceInsideRangeLiteral; node: Node): void =
    var
      expression = node.source
      operator = node.loc.operator.source
      operatorEscaped = operator.gsub("\\.")
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange,
                        expression.sub(operator).sub(operator)))

  method check*(self: SpaceInsideRangeLiteral; node: Node): void =
    var
      expression = node.source
      op = node.loc.operator.source
      escapedOp = op.gsub("\\.")
    expression.sub!(op)
    if expression.=~():
    addOffense(node)

