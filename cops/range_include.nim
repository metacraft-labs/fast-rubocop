
cop :
  type
    RangeInclude* = ref object of Cop
  const
    MSG = "Use `Range#cover?` instead of `Range#include?`."
  nodeMatcher rangeInclude, "          (send {irange erange (begin {irange erange})} :include? ...)\n"
  method onSend*(self: RangeInclude; node: Node): void =
    if rangeInclude node:
    addOffense(node, location = "selector")

  method autocorrect*(self: RangeInclude; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.selector, "cover?"))

