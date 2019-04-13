
import
  rangeHelp

cop :
  type
    UnneededRequireStatement* = ref object of Cop
  const
    MSG = "Remove unnecessary `require` statement."
  nodeMatcher isUnnecessaryRequireStatement, """          (send nil? :require
            (str {"enumerator" "rational" "complex" "thread"}))
"""
  method onSend*(self: UnneededRequireStatement; node: Node): void =
    if isUnnecessaryRequireStatement node:
    addOffense(node)

  method autocorrect*(self: UnneededRequireStatement; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var range = rangeWithSurroundingSpace(range = node.loc.expression,
          side = "right")
      corrector.remove(range))

