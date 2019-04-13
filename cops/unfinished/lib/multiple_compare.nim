
cop :
  type
    MultipleCompare* = ref object of Cop
  const
    MSG = "Use the `&&` operator to compare multiple values."
  nodeMatcher isMultipleCompare,
             "          (send (send _ {:< :> :<= :>=} $_) {:< :> :<= :>=} _)\n"
  method onSend*(self: MultipleCompare; node: Node): void =
    if isMultipleCompare node:
    addOffense(node)

  method autocorrect*(self: MultipleCompare; node: Node): void =
    var
      center = isMultipleCompare node
      newCenter = """(send
  (lvar :center) :source) && (send
  (lvar :center) :source)"""
    lambda(proc (corrector: Corrector): void =
      corrector.replace(center.sourceRange, newCenter))

