
import
  sequtils

import
  ignoredMethods

cop :
  type
    MethodCallWithoutArgsParentheses* = ref object of Cop
    ##  This cop checks for unwanted parentheses in parameterless method calls.
    ## 
    ##  @example
    ##    # bad
    ##    object.some_method()
    ## 
    ##    # good
    ##    object.some_method
  const
    MSG = """Do not use parentheses for method calls with no arguments."""
  method onSend*(self: MethodCallWithoutArgsParentheses; node: Node): void =
    if isIneligibleNode(node):
      return
    if node.isArguments.! and node.isParenthesized:
    if isIgnoredMethod(node.methodName):
      return
    if isSameNameAssignment(node):
      return
    addOffense(node, location = node.loc.begin.join(node.loc.end))

  method autocorrect*(self: MethodCallWithoutArgsParentheses; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.remove(node.loc.begin)
      corrector.remove(node.loc.end))

  method isIneligibleNode*(self: MethodCallWithoutArgsParentheses; node: Node): void =
    node.isCamelCaseMethod or node.isImplicitCall or node.isPrefixNot

  method isSameNameAssignment*(self: MethodCallWithoutArgsParentheses; node: Node): void =
    isAnyAssignment(node, proc (asgnNode: Node): void =
      if asgnNode.isMasgnType():
        continue
      asgnNode.loc.name.source == `$`())

  iterator isAnyAssignment*(self: MethodCallWithoutArgsParentheses; node: Node): void =
    node.eachAncestor().anyIt:
      if it.isShorthandAsgn:
        if it.isSendType():
          continue
      yield it

  method isVariableInMassAssignment*(self: MethodCallWithoutArgsParentheses;
                                    variableName: Symbol; node: Node): void =
    var varNodes = @[]
    varNodes.anyIt:
      it.toA[0] == variableName

