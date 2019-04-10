
import
  sequtils

import
  rangeHelp

cop :
  type
    EachWithObject* = ref object of Cop
    ##  This cop looks for inject / reduce calls where the passed in object is
    ##  returned at the end and so could be replaced by each_with_object without
    ##  the need to return the object at the end.
    ## 
    ##  However, we can't replace with each_with_object if the accumulator
    ##  parameter is assigned to within the block.
    ## 
    ##  @example
    ##    # bad
    ##    [1, 2].inject({}) { |a, e| a[e] = e; a }
    ## 
    ##    # good
    ##    [1, 2].each_with_object({}) { |e, a| a[e] = e }
  const
    MSG = "Use `each_with_object` instead of `%<method>s`."
  const
    METHODS = @["inject", "reduce"]
  nodeMatcher isEachWithObjectCandidate,
             "          (block $(send _ {:inject :reduce} _) $_ $_)\n"
  method onBlock*(self: EachWithObject; node: Node): void =
    isEachWithObjectCandidate node:
      if isSimpleMethodArg(methodArg):
        return
      var returnValue = returnValue(body)
      if returnValue:
      if isFirstArgumentReturned(args, returnValue):
      if isAccumulatorParamAssignedTo(body, args):
        return
      addOffense(node, location = method.loc.selector,
                 message = format(MSG, method = methodName))

  method autocorrect*(self: EachWithObject; node: Node): void =
    ##  rubocop:disable Metrics/AbcSize
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sendNode.loc.selector, "each_with_object")
      corrector.replace(firstArg.loc.expression, secondArg.source)
      corrector.replace(secondArg.loc.expression, firstArg.source)
      var returnValue = returnValue(node.body)
      if isReturnValueOccupiesWholeLine(returnValue):
        corrector.remove(wholeLineExpression(returnValue))
      else:
        corrector.remove(returnValue.loc.expression)
    )

  method isSimpleMethodArg*(self: EachWithObject; methodArg: Node): void =
    methodArg and methodArg.isBasicLiteral

  method isAccumulatorParamAssignedTo*(self: EachWithObject; body: Node; args: Node): void =
    ##  if the accumulator parameter is assigned to in the block,
    ##  then we can't convert to each_with_object
    var
      firstArg = args[0]
      accumulatorVar = firstArg[0]
    body.eachDescendant.anyIt:
      if it.isAssignment:
      lhs.isEqual(accumulatorVar)

  method returnValue*(self: EachWithObject; body: Node): void =
    if body:
    var returnValue = if body.isBeginType():
      body.children.last()
    if returnValue and returnValue.isLvarType():
      returnValue
  
  method isFirstArgumentReturned*(self: EachWithObject; args: Node; returnValue: Node): void =
    var
      firstArg = args[0]
      accumulatorVar = firstArg[0]
      returnVar = returnValue[0]
    accumulatorVar == returnVar

  method isReturnValueOccupiesWholeLine*(self: EachWithObject; node: Node): void =
    wholeLineExpression(node).source.strip() == node.source

  method wholeLineExpression*(self: EachWithObject; node: Node): void =
    rangeByWholeLines(node.loc.expression, includeFinalNewline = true)

