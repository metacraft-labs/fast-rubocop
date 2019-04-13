
import
  safeMode

import
  rangeHelp

cop :
  type
    Count* = ref object of Cop
  const
    MSG = "Use `count` instead of `%<selector>s...%<counter>s`."
  nodeMatcher isCountCandidate, """          {
            (send (block $(send _ ${:select :reject}) ...) ${:count :length :size})
            (send $(send _ ${:select :reject} (:block_pass _)) ${:count :length :size})
          }
"""
  method onSend*(self: Count; node: Node): void =
    if isRailsSafeMode:
      return
    isCountCandidate node:
      if isEligibleNode(node):
      var range = sourceStartingAt(node, proc (): void =
        selectorNode.loc.selector.beginPos)
      addOffense(node, location = range,
                 message = format(MSG, selector = selector, counter = counter))

  method autocorrect*(self: Count; node: Node): void =
    var selectorLoc = selectorNode.loc.selector
    if selector == "reject":
      return
    var range = sourceStartingAt(node, proc (n: Node): void =
      n.loc.dot.beginPos)
    lambda(proc (corrector: Corrector): void =
      corrector.remove(range)
      corrector.replace(selectorLoc, "count"))

  method isEligibleNode*(self: Count; node: Node): void =
      node.parent and node.parent.isBlockType().!

  method sourceStartingAt*(self: Count; node: Node): void =
    var beginPos = if isBlockGiven():
      yield node
    else:
      node.sourceRange.beginPos
    rangeBetween(beginPos, node.sourceRange.endPos)

