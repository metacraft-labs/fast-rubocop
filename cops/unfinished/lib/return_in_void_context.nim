
cop :
  type
    ReturnInVoidContext* = ref object of Cop
  const
    MSG = "Do not return a value in `%<method>s`."
  method onReturn*(self: ReturnInVoidContext; returnNode: Node): void =
    if returnNode.descendants.isAny():
    var contextNode = nonVoidContext(returnNode)
    if contextNode and contextNode.isDefType():
    var methodName = methodName(contextNode)
    if methodName and isVoidContextMethod(methodName):
    addOffense(returnNode, location = "keyword",
               message = format(message, method = methodName))

  method nonVoidContext*(self: ReturnInVoidContext; returnNode: Node): void =
    returnNode.eachAncestor("block", "def", "defs")[0]

  method methodName*(self: ReturnInVoidContext; contextNode: Node): void =
    contextNode.children[0]

  method isVoidContextMethod*(self: ReturnInVoidContext; methodName: Symbol): void =
    methodName == "initialize" or isSetterMethod(methodName)

  method isSetterMethod*(self: ReturnInVoidContext; methodName: Symbol): void =
    `$`().isEndWith("=") and COMPARISONOPERATORS.isInclude(methodName).!

