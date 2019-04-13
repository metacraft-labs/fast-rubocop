
import
  rangeHelp

cop :
  type
    StringReplacement* = ref object of Cop
  const
    MSG = "Use `%<prefer>s` instead of `%<current>s`."
  const
    DETERMINISTICREGEX
  const
    DELETE = "delete"
  const
    TR = "tr"
  const
    BANG = "!"
  const
    SINGLEQUOTE = "\'"
  nodeMatcher isStringReplacement, """          (send _ {:gsub :gsub!}
                    ${regexp str (send (const nil? :Regexp) {:new :compile} _)}
                    $str)
"""
  method onSend*(self: StringReplacement; node: Node): void =
    isStringReplacement node:
      if isAcceptSecondParam(secondParam):
        return
      if isAcceptFirstParam(firstParam):
        return
      offense(node, firstParam, secondParam)

  method autocorrect*(self: StringReplacement; node: Node): void =
    var
      firstSource = firstSource(firstParam)[0]
      secondSource = secondParam[0]
    if firstParam.isStrType():
    else:
      firstSource = interpretStringEscapes(firstSource)
    var replacementMethod = replacementMethod(node, firstSource, secondSource)
    replaceMethod(node, firstSource, secondSource, firstParam, replacementMethod)

  method replaceMethod*(self: StringReplacement; node: Node; first: string;
                       second: string; firstParam: Node; replacement: string): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.selector, replacement)
      if firstParam.isStrType():
      else:
        corrector.replace(firstParam.sourceRange, toStringLiteral(first))
      if second.isEmpty and first.length == 1:
        removeSecondParam(corrector, node, firstParam)
    )

  method isAcceptSecondParam*(self: StringReplacement; secondParam: Node): void =
    var secondSource = secondParam[0]
    secondSource.length > 1

  method isAcceptFirstParam*(self: StringReplacement; firstParam: Node): void =
    if firstSource.isNil():
      return true
    if firstParam.isStrType():
    else:
      if options:
        return true
      if firstSource.=~(DETERMINISTICREGEX):
      else:
        return true
      var firstSource = interpretStringEscapes(firstSource)
    firstSource.length != 1

  method offense*(self: StringReplacement; node: Node; firstParam: Node;
                 secondParam: Node): void =
    var firstSource = firstSource(firstParam)[0]
    if firstParam.isStrType():
    else:
      firstSource = interpretStringEscapes(firstSource)
    var
      secondSource = secondParam[0]
      message = message(node, firstSource, secondSource)
    addOffense(node, location = range(node), message = message)

  method firstSource*(self: StringReplacement; firstParam: Node): void =
    case firstParam.type
    of "regexp":
      sourceFromRegexLiteral(firstParam)
    of "send":
      sourceFromRegexConstructor(firstParam)
    of "str":
      firstParam.children[0]
    else:

  method sourceFromRegexLiteral*(self: StringReplacement; node: Node): void =
    var
      source = regex[0]
      options = options[0]
    @[source, options]

  method sourceFromRegexConstructor*(self: StringReplacement; node: Node): void =
    case regex.type
    of "regexp":
      sourceFromRegexLiteral(regex)
    of "str":
      var source = regex[0]
      source
    else:

  method range*(self: StringReplacement; node: Node): void =
    rangeBetween(node.loc.selector.beginPos, node.sourceRange.endPos)

  method replacementMethod*(self: StringReplacement; node: Node; firstSource: string;
                           secondSource: string): void =
    var replacement = if secondSource.isEmpty and firstSource.length == 1:
      DELETE
    """(lvar :replacement)(if
  (send
    (lvar :node) :bang_method?)
  (const nil :BANG) nil)"""

  method message*(self: StringReplacement; node: Node; firstSource: string;
                 secondSource: string): void =
    var replacementMethod = replacementMethod(node, firstSource, secondSource)
    format(MSG, prefer = replacementMethod, current = node.methodName)

  method methodSuffix*(self: StringReplacement; node: Node): void =
    if node.loc.end:
      node.loc.end.source
  
  method removeSecondParam*(self: StringReplacement; corrector: Corrector;
                           node: Node; firstParam: Node): void =
    var endRange = rangeBetween(firstParam.sourceRange.endPos,
                             node.sourceRange.endPos)
    corrector.replace(endRange, methodSuffix(node))

