
import
  rangeHelp

cop :
  type
    RedundantWithObject* = ref object of Cop
  const
    MSGEACHWITHOBJECT = "Use `each` instead of `each_with_object`."
  const
    MSGWITHOBJECT = "Remove redundant `with_object`."
  nodeMatcher isRedundantWithObject, """          (block
            $(send _ {:each_with_object :with_object}
              _)
            (args
              (arg _))
            ...)
"""
  method onBlock*(self: RedundantWithObject; node: Node): void =
    isRedundantWithObject node:
      addOffense(node, location = withObjectRange(send))

  method autocorrect*(self: RedundantWithObject; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      isRedundantWithObject node:
        if send.methodName == "each_with_object":
          corrector.replace(withObjectRange(send), "each")
        else:
          corrector.remove(withObjectRange(send))
          corrector.remove(send.loc.dot))

  method message*(self: RedundantWithObject; node: Node): void =
    if node.methodName == "each_with_object":
      MSGEACHWITHOBJECT
  
  method withObjectRange*(self: RedundantWithObject; send: Node): void =
    rangeBetween(send.loc.selector.beginPos, send.loc.expression.endPos)

