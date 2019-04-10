
cop :
  type
    Size* = ref object of Cop
  const
    MSG = "Use `size` instead of `count`."
  method onSend*(self: Size; node: Node): void =
    if isEligibleNode(node):
    addOffense(node, location = "selector")

  method autocorrect*(self: Size; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.selector, "size"))

  method isEligibleNode*(self: Size; node: Node): void =
    if node.isMethod("count") and node.isArguments.!:
    else:
      return false
    isEligibleReceiver(node.receiver) and isAllowedParent(node.parent).!

  method isEligibleReceiver*(self: Size; node: Node): void =
    if node:
    else:
      return false
    isArray(node) or isHash(node)

  method isAllowedParent*(self: Size; node: NilClass): void =
    node and node.isBlockType()

  method isArray*(self: Size; node: Node): void =
    if node.isArrayType():
      return true
    if node.isSendType():
    else:
      return false
    constant == "Array" or node.methodName == "to_a"

  method isHash*(self: Size; node: Node): void =
    if node.isHashType():
      return true
    if node.isSendType():
    else:
      return false
    constant == "Hash" or node.methodName == "to_h"

