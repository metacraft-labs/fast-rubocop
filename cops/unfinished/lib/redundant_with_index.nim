
import
  rangeHelp

cop :
  type
    RedundantWithIndex* = ref object of Cop
  const
    MSGEACHWITHINDEX = "Use `each` instead of `each_with_index`."
  const
    MSGWITHINDEX = "Remove redundant `with_index`."
  nodeMatcher isRedundantWithIndex, """          (block
            $(send
              _ {:each_with_index :with_index} ...)
            (args
              (arg _))
            ...)
"""
  method onBlock*(self: RedundantWithIndex; node: Node): void =
    isRedundantWithIndex node:
      addOffense(node, location = withIndexRange(send))

  method autocorrect*(self: RedundantWithIndex; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      isRedundantWithIndex node:
        if send.methodName == "each_with_index":
          corrector.replace(send.loc.selector, "each")
        else:
          corrector.remove(withIndexRange(send))
          corrector.remove(send.loc.dot))

  method message*(self: RedundantWithIndex; node: Node): void =
    if node.methodName == "each_with_index":
      MSGEACHWITHINDEX
  
  method withIndexRange*(self: RedundantWithIndex; send: Node): void =
    rangeBetween(send.loc.selector.beginPos, send.loc.expression.endPos)

