
import
  types

import
  tooManyLines

cop MethodLength:
  ##  This cop checks if the length of a method exceeds some maximum value.
  ##  Comment lines can optionally be ignored.
  ##  The maximum allowed length is configurable.
  const
    LABEL = "Method"
  method onDef*(self; node) =
    var excludedMethods = copConfig.ExcludedMethods
    if $node.methodName in excludedMethods:
      return
    self.checkCodeLength(node)

  method onBlock*(self; node) =
    if not (node.sendNode.methodName() == "define_method"):
      return
    self.checkCodeLength(node)

  method copLabel*(self): string =
    LABEL

