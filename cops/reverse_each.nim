
import
  rangeHelp

cop :
  type
    ReverseEach* = ref object of Cop
  const
    MSG = "Use `reverse_each` instead of `reverse.each`."
  const
    UNDERSCORE = "_"
  nodeMatcher isReverseEach, "          (send $(send _ :reverse) :each)\n"
  method onSend*(self: ReverseEach; node: Node): void =
    isReverseEach node:
      var
        locationOfReverse = receiver.loc.selector.beginPos
        endLocation = node.loc.selector.endPos
        range = rangeBetween(locationOfReverse, endLocation)
      addOffense(node, location = range)

  method autocorrect*(self: ReverseEach; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.dot, UNDERSCORE))

