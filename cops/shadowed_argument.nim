
import
  sequtils

cop :
  type
    ShadowedArgument* = ref object of Cop
  const
    MSG = """Argument `%<argument>s` was shadowed by a local variable before it was used."""
  method isJoinForce*(self: ShadowedArgument; forceClass: Class): void =
    forceClass == VariableForce

  method afterLeavingScope*(self: ShadowedArgument; scope: Scope;
                           _variableTable: VariableTable): void =
    scope.variables.eachValue(proc (variable: Variable): void =
      checkArgument(variable))

  method checkArgument*(self: ShadowedArgument; argument: Variable): void =
    if argument.isMethodArgument or argument.isBlockArgument:
    if argument.isExplicitBlockLocalVariable:
      return
    shadowingAssignment(argument, proc (node: Node): void =
      var message = format(MSG, argument = argument.name)
      addOffense(node, message = message))

  method shadowingAssignment*(self: ShadowedArgument; argument: Variable): void =
    if argument.isReferenced:
    assignmentWithoutArgumentUsage(argument, proc (node: Node;
        locationKnown: TrueClass): void =
      var
        assignmentWithoutUsagePos = node.sourceRange.beginPos
        references = argumentReferences(argument)
      if references.anyIt:
        if it.isExplicit.! and isIgnoreImplicitReferences:
          continue
        referencePos(it.node) <= assignmentWithoutUsagePos:
        continue
      yield if locationKnown:
        node
      else:
        argument.declarationNode
    )

  method assignmentWithoutArgumentUsage*(self: ShadowedArgument; argument: Variable): void =
    argument.assignments.reduce(true, proc (locationKnown: TrueClass;
        assignment: Assignment): void =
      var assignmentNode = assignment.metaAssignmentNode or assignment.node
      if assignmentNode.isShorthandAsgn:
        continue
      var nodeWithinBlockOrConditional = isNodeWithinBlockOrConditional(
          assignmentNode.parent, argument.scope.node)
      if isUsesVar(assignmentNode, argument.name):
      else:
        if nodeWithinBlockOrConditional:
          continue
        yield assignment.node
        break
      locationKnown)

  method referencePos*(self: ShadowedArgument; node: Node): void =
    node = if node.parent.isMasgnType():
      node.parent
    node.sourceRange.beginPos

  method isNodeWithinBlockOrConditional*(self: ShadowedArgument; node: Node;
                                        stopSearchNode: Node): void =
    if node == stopSearchNode:
      return false
    node.isConditional or node.isBlockType() or
        isNodeWithinBlockOrConditional(node.parent, stopSearchNode)

  method argumentReferences*(self: ShadowedArgument; argument: Variable): void =
    var assignmentReferences = argument.assignments.flatMap(proc (it: void): void =
      it.eferences).mapIt:
      it.ourceRange
    argument.references.reject(proc (ref: Reference): void =
      if ref.isExplicit:
      else:
        continue
      assignmentReferences.isInclude(ref.node.sourceRange))

  method isIgnoreImplicitReferences*(self: ShadowedArgument): void =
    copConfig["IgnoreImplicitReferences"]

  defNodeSearch("uses_var?", "(lvar %)")
