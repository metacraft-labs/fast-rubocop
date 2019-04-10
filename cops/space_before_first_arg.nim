
import
  precedingFollowingAlignment

import
  rangeHelp

cop :
  type
    SpaceBeforeFirstArg* = ref object of Cop
  const
    MSG = """Put one space between the method name and the first argument."""
  method onSend*(self: SpaceBeforeFirstArg; node: Node): void =
    if isRegularMethodCallWithArguments(node):
    if isExpectParamsAfterMethodName(node):
    var
      firstArg = node.firstArgument.sourceRange
      firstArgWithSpace = rangeWithSurroundingSpace(range = firstArg, side = "left")
      space = rangeBetween(firstArgWithSpace.beginPos, firstArg.beginPos)
    if space.length != 1:
      addOffense(space, location = space)
  
  method autocorrect*(self: SpaceBeforeFirstArg; range: Range): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(range, " "))

  method isRegularMethodCallWithArguments*(self: SpaceBeforeFirstArg; node: Node): void =
    node.isArguments and node.isOperatorMethod.! and node.isSetterMethod.!

  method isExpectParamsAfterMethodName*(self: SpaceBeforeFirstArg; node: Node): void =
    if node.isParenthesized:
      return false
    var firstArg = node.firstArgument
    isSameLine(firstArg, node) and
      isAllowForAlignment and isAlignedWithSomething(firstArg.sourceRange).!

