
cop :
  type
    SelfAssignment* = ref object of Cop
    ##  This cop enforces the use the shorthand for self-assignment.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    x = x + 1
    ## 
    ##    # good
    ##    x += 1
  const
    MSG = "Use self-assignment shorthand `%<method>s=`."
  const
    OPS = @["+", "-", "*", "**", "/", "|", "&"]
  method autocorrectIncompatibleWith*(self: Class): void =
    @[SpaceAroundOperators]

  method onLvasgn*(self: SelfAssignment; node: Node): void =
    check(node, "lvar")

  method onIvasgn*(self: SelfAssignment; node: Node): void =
    check(node, "ivar")

  method onCvasgn*(self: SelfAssignment; node: Node): void =
    check(node, "cvar")

  method autocorrect*(self: SelfAssignment; node: Node): void =
    if rhs.isSendType():
      autocorrectSendNode(node, rhs)
    elif @["and", "or"].isInclude(rhs.type):
      autocorrectBooleanNode(node, rhs)
  
  method check*(self: SelfAssignment; node: Node; varType: Symbol): void =
    if rhs:
    if rhs.isSendType():
      checkSendNode(node, rhs, varName, varType)
    elif @["and", "or"].isInclude(rhs.type):
      checkBooleanNode(node, rhs, varName, varType)
  
  method checkSendNode*(self: SelfAssignment; node: Node; rhs: Node; varName: Symbol;
                       varType: Symbol): void =
    if OPS.isInclude(methodName):
    var targetNode = s(varType, varName)
    if receiver == targetNode:
    addOffense(node, message = format(MSG, method = methodName))

  method checkBooleanNode*(self: SelfAssignment; node: Node; rhs: Node;
                          varName: Symbol; varType: Symbol): void =
    var targetNode = s(varType, varName)
    if firstOperand == targetNode:
    var operator = rhs.loc.operator.source
    addOffense(node, message = format(MSG, method = operator))

  method autocorrectSendNode*(self: SelfAssignment; node: Node; rhs: Node): void =
    applyAutocorrect(node, rhs, `$`(), args)

  method autocorrectBooleanNode*(self: SelfAssignment; node: Node; rhs: Node): void =
    applyAutocorrect(node, rhs, rhs.loc.operator.source, secondOperand)

  method applyAutocorrect*(self: SelfAssignment; node: Node; rhs: Node;
                          operator: string; newRhs: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.insertBefore(node.loc.operator, operator)
      corrector.replace(rhs.sourceRange, newRhs.source))

