
import
  emptyLinesAroundBody

cop :
  type
    EmptyLinesAroundModuleBody* = ref object of Cop
  const
    KIND = "module"
  method onModule*(self: EmptyLinesAroundModuleBody; node: Node): void =
    check(node, body)

  method autocorrect*(self: EmptyLinesAroundModuleBody; node: Array): void =
    EmptyLineCorrector.correct(node)

