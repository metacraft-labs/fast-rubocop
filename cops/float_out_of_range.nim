
cop :
  type
    FloatOutOfRange* = ref object of Cop
  const
    MSG = "Float out of range."
  method onFloat*(self: FloatOutOfRange; node: Node): void =
    var value = node[0]
    if value.isInfinite() or value.isZero() and node.source.=~():
    addOffense(node)

