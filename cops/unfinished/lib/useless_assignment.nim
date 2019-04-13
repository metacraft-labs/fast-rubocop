
import
  tables, sequtils

import
  nameSimilarity

cop :
  type
    UselessAssignment* = ref object of Cop
  const
    MSG = "Useless assignment to variable - `%<variable>s`."
  method isJoinForce*(self: UselessAssignment; forceClass: Class): void =
    forceClass == VariableForce

  method afterLeavingScope*(self: UselessAssignment; scope: Scope;
                           _variableTable: VariableTable): void =
    scope.variables.eachValue(proc (variable: Variable): void =
      checkForUnusedAssignments(variable))

  method checkForUnusedAssignments*(self: UselessAssignment; variable: Variable): void =
    if variable.isShouldBeUnused:
      return
    for assignment in variable.assignments:
      if assignment.isUsed:
        continue
      var
        message = messageForUselessAssignment(assignment)
        location = if assignment.isRegexpNamedCapture:
          assignment.node.children[0].sourceRange
        else:
          assignment.node.loc.name
      addOffense(location = location, message = message)

  method messageForUselessAssignment*(self: UselessAssignment;
                                     assignment: Assignment): void =
    var variable = assignment.variable
    format(MSG, variable = variable.name) & `$`()

  method messageSpecification*(self: UselessAssignment; assignment: Assignment;
                              variable: Variable): void =
    if assignment.isMultipleAssignment:
      multipleAssignmentMessage(variable.name)
    elif assignment.isOperatorAssignment:
      operatorAssignmentMessage(variable.scope, assignment)
    else:
      similarNameMessage(variable)
  
  method multipleAssignmentMessage*(self: UselessAssignment; variableName: Symbol): void =
    """(str " Use `_` or `_")that it won't be used."""

  method operatorAssignmentMessage*(self: UselessAssignment; scope: Scope;
                                   assignment: Assignment): void =
    var returnValueNode = returnValueNodeOfScope(scope)
    if assignment.metaAssignmentNode.isEqual(returnValueNode):
    """(str " Use `")(str "instead of `")"""

  method similarNameMessage*(self: UselessAssignment; variable: Variable): void =
    var similarName = findSimilarName(variable.name, variable.scope)
    if similarName:
      """ Did you mean `(lvar :similar_name)`?"""
  
  method returnValueNodeOfScope*(self: UselessAssignment; scope: Scope): void =
    var bodyNode = scope.bodyNode
    if bodyNode.isBeginType():
      bodyNode.children.last()
  
  method collectVariableLikeNames*(self: UselessAssignment; scope: Scope): void =
    var
      names = scope.eachNode.withObject(Set.new, proc (node: Node; set: Set): void =
        if isVariableLikeMethodInvocation(node):
          set.<<(methodName))
      variableNames = scope.variables.eachValue().mapIt:
        it.ame
    names.merge(variableNames)

  method isVariableLikeMethodInvocation*(self: UselessAssignment; node: Node): void =
    if node.isSendType():
    else:
      return false
    receiver.isNil() and args.isEmpty

