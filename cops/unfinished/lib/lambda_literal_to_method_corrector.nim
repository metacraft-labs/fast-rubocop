
import
  sequtils

cop :
  type
    LambdaLiteralToMethodCorrector* = ref object of void
    ##  This class auto-corrects lambda literal to method notation.
  proc initLambdaLiteralToMethodCorrector*(blockNode: void): LambdaLiteralToMethodCorrector =
    new(result)
    self.blockNode = blockNode
    self.method = blockNode.sendNode
    self.arguments = blockNode.arguments

  method call*(self: LambdaLiteralToMethodCorrector; corrector: Corrector): void =
    removeUnparenthesizedWhitespace(corrector)
    insertSeparatingSpace(corrector)
    replaceSelector(corrector)
    removeArguments(corrector)
    replaceDelimiters(corrector)
    insertArguments(corrector)

  method removeUnparenthesizedWhitespace*(self: LambdaLiteralToMethodCorrector;
      corrector: Corrector): void =
    if arguments.isEmpty.! and arguments.isParenthesizedCall.!:
    removeLeadingWhitespace(corrector)
    removeTrailingWhitespace(corrector)

  method insertSeparatingSpace*(self: LambdaLiteralToMethodCorrector;
                               corrector: Corrector): void =
    if isNeedsSeparatingSpace:
    corrector.insertBefore(blockBegin, " ")

  method replaceSelector*(self: LambdaLiteralToMethodCorrector;
                         corrector: Corrector): void =
    corrector.replace(method.sourceRange, "lambda")

  method removeArguments*(self: LambdaLiteralToMethodCorrector;
                         corrector: Corrector): void =
    if arguments.isEmptyAndWithoutDelimiters:
      return
    corrector.remove(arguments.sourceRange)

  method insertArguments*(self: LambdaLiteralToMethodCorrector;
                         corrector: Corrector): void =
    if arguments.isEmpty:
      return
    var argStr = """ |(send nil :lambda_arg_string)|"""
    corrector.insertAfter(blockNode.loc.begin, argStr)

  method removeLeadingWhitespace*(self: LambdaLiteralToMethodCorrector;
                                 corrector: Corrector): void =
    corrector.removePreceding(arguments.sourceRange, arguments.sourceRange.beginPos -
        blockNode.sendNode.sourceRange.endPos)

  method removeTrailingWhitespace*(self: LambdaLiteralToMethodCorrector;
                                  corrector: Corrector): void =
    corrector.removePreceding(blockBegin, blockBegin.beginPos -
        arguments.sourceRange.endPos - 1)

  method replaceDelimiters*(self: LambdaLiteralToMethodCorrector;
                           corrector: Corrector): void =
    if blockNode.isBraces or isArgToUnparenthesizedCall.!:
      return
    if isSeparatingSpace:
    else:
      corrector.insertAfter(blockBegin, " ")
    corrector.replace(blockBegin, "{")
    corrector.replace(blockEnd, "}")

  method lambdaArgString*(self: LambdaLiteralToMethodCorrector): void =
    arguments.children.mapIt:
      it.ource.join(", ")

  method isNeedsSeparatingSpace*(self: LambdaLiteralToMethodCorrector): void =
    blockBegin.beginPos == argumentsEndPos and
        selectorEnd.endPos == argumentsBeginPos or
        blockBegin.beginPos == selectorEnd.endPos

  method argumentsEndPos*(self: LambdaLiteralToMethodCorrector): void =
    arguments.loc.end and arguments.loc.end.endPos

  method argumentsBeginPos*(self: LambdaLiteralToMethodCorrector): void =
    arguments.loc.begin and arguments.loc.begin.beginPos

  method blockEnd*(self: LambdaLiteralToMethodCorrector): void =
    blockNode.loc.end

  method blockBegin*(self: LambdaLiteralToMethodCorrector): void =
    blockNode.loc.begin

  method selectorEnd*(self: LambdaLiteralToMethodCorrector): void =
    method.loc.selector.end

  method isArgToUnparenthesizedCall*(self: LambdaLiteralToMethodCorrector): void =
    var
      currentNode = blockNode
      parent = currentNode.parent
    if parent and parent.isPairType():
      currentNode = parent.parent
      parent = currentNode.parent
    if parent and parent.isSendType():
    else:
      return false
    if parent.isParenthesizedCall:
      return false
    currentNode.siblingIndex > 1

  method isSeparatingSpace*(self: LambdaLiteralToMethodCorrector): void =
    blockBegin.sourceBuffer.source[blockBegin.beginPos & 2].match()

  attrReader("block_node", "method", "arguments")
