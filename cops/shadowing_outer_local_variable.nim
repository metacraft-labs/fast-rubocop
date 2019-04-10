
cop :
  type
    ShadowingOuterLocalVariable* = ref object of Cop
  const
    MSG = "Shadowing outer local variable - `%<variable>s`."
  method isJoinForce*(self: ShadowingOuterLocalVariable; forceClass: Class): void =
    forceClass == VariableForce

  method beforeDeclaringVariable*(self: ShadowingOuterLocalVariable;
                                 variable: Variable; variableTable: VariableTable): void =
    if variable.isShouldBeUnused:
      return
    var outerLocalVariable = variableTable.findVariable(variable.name)
    if outerLocalVariable:
    var message = format(MSG, variable = variable.name)
    addOffense(variable.declarationNode, message = message)

