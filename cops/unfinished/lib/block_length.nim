
import
  sequtils

import
  tooManyLines

cop :
  type
    BlockLength* = ref object of Cop
    ##  This cop checks if the length of a block exceeds some maximum value.
    ##  Comment lines can optionally be ignored.
    ##  The maximum allowed length is configurable.
    ##  The cop can be configured to ignore blocks passed to certain methods.
  const
    LABEL = "Block"
  method onBlock*(self: BlockLength; node: Node): void =
    if isExcludedMethod(node):
      return
    if node.isClassConstructor:
      return
    checkCodeLength(node)

  method isExcludedMethod*(self: BlockLength; node: Node): void =
    var
      nodeReceiver = node.receiver and notEmpty(node.receiver.source)
      nodeMethod = String(node.methodName)
    excludedMethods.anyIt:
      if method:
      else:
        var
          method = receiver
          receiver = nodeReceiver
      method == nodeMethod and receiver == nodeReceiver

  method excludedMethods*(self: BlockLength): void =
    copConfig["ExcludedMethods"] or @[]

  method copLabel*(self: BlockLength): void =
    LABEL

