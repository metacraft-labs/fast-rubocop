
import
  emptyLinesAroundBody

cop :
  type
    EmptyLinesAroundBlockBody* = ref object of Cop
  const
    KIND = "block"
  method onBlock*(self: EmptyLinesAroundBlockBody; node: Node): void =
    check(node, node.body)

  method autocorrect*(self: EmptyLinesAroundBlockBody; node: Array): void =
    EmptyLineCorrector.correct(node)

