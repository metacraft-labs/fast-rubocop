
cop :
  type
    UnderscorePrefixedVariableName* = ref object of Cop
  const
    MSG = "Do not use prefix `_` for a variable that is used."
  method isJoinForce*(self: UnderscorePrefixedVariableName; forceClass: Class): void =
    forceClass == VariableForce

  method afterLeavingScope*(self: UnderscorePrefixedVariableName; scope: Scope;
                           _variableTable: VariableTable): void =
    scope.variables.eachValue(proc (variable: Variable): void =
      checkVariable(variable))

  method checkVariable*(self: UnderscorePrefixedVariableName; variable: Variable): void =
    if variable.isShouldBeUnused:
    if variable.references.isNone(proc (it: void): void =
      it.isXplicit):
      return
    var
      node = variable.declarationNode
      location = if node.isMatchWithLvasgnType():
        node.children[0].sourceRange
      else:
        node.loc.name
    addOffense(location = location)

