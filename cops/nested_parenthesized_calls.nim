
import
  rangeHelp

cop :
  type
    NestedParenthesizedCalls* = ref object of Cop
    ##  This cop checks for unparenthesized method calls in the argument list
    ##  of a parenthesized method call.
    ## 
    ##  @example
    ##    # good
    ##    method1(method2(arg), method3(arg))
    ## 
    ##    # bad
    ##    method1(method2 arg, method3, arg)
  const
    MSG = "Add parentheses to nested method call `%<source>s`."
  method onSend*(self: NestedParenthesizedCalls; node: Node): void =
    if node.isParenthesized:
    node.eachChildNode("send", "csend", proc (nested: Node): void =
      if isAllowedOmission(nested):
        continue
      addOffense(nested, location = nested.sourceRange,
                 message = format(MSG, source = nested.source)))

  method autocorrect*(self: NestedParenthesizedCalls; nested: Node): void =
    var
      firstArg = nested.firstArgument.sourceRange
      lastArg = nested.lastArgument.sourceRange
      leadingSpace = rangeWithSurroundingSpace(range = firstArg, side = "left").begin.resize(
          1)
    lambda(proc (corrector: Corrector): void =
      corrector.replace(leadingSpace, "(")
      corrector.insertAfter(lastArg, ")"))

  method isAllowedOmission*(self: NestedParenthesizedCalls; sendNode: Node): void =
    sendNode.isArguments.! or sendNode.isParenthesized or sendNode.isSetterMethod or
        sendNode.isOperatorMethod or isWhitelisted(sendNode)

  method isWhitelisted*(self: NestedParenthesizedCalls; sendNode: Node): void =
    sendNode.parent.arguments.isOne() and whitelistedMethods.isInclude(`$`()) and
        sendNode.arguments.isOne()

  method whitelistedMethods*(self: NestedParenthesizedCalls): void =
    copConfig["Whitelist"] or @[]

