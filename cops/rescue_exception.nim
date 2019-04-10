
import
  sequtils

cop :
  type
    RescueException* = ref object of Cop
  const
    MSG = """Avoid rescuing the `Exception` class. Perhaps you meant to rescue `StandardError`?"""
  method onResbody*(self: RescueException; node: Node): void =
    if node.children[0]:
    var rescueArgs = node.children[0].children
    if rescueArgs.anyIt:
      isTargetsException(it):
    addOffense(node)

  method isTargetsException*(self: RescueException; rescueArgNode: Node): void =
    rescueArgNode.constName == "Exception"

