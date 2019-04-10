
import
  sequtils

cop :
  type
    UnreachableCode* = ref object of Cop
  const
    MSG = "Unreachable code detected."
  nodeMatcher isFlowCommand, """          {
            return next break retry redo
            (send
             {nil? (const {nil? cbase} :Kernel)}
             {:raise :fail :throw :exit :exit! :abort}
             ...)
          }
"""
  method onBegin*(self: UnreachableCode; node: Node): void =
    var expressions = @[]
    expressions.eachCons(2, proc (expression1: Node; expression2: Node): void =
      if isFlowExpression(expression1):
      addOffense(expression2))

  method isFlowExpression*(self: UnreachableCode; node: Node): void =
    if isFlowCommand node:
      return true
    case node.type
    of "begin":
      "kwbegin"
    of "if":
      checkIf(node)
    of "case":
      checkCase(node)
    else:
      false
  
  method checkIf*(self: UnreachableCode; node: Node): void =
    var
      ifBranch = node.ifBranch
      elseBranch = node.elseBranch
    ifBranch and elseBranch and isFlowExpression(ifBranch) and
        isFlowExpression(elseBranch)

  method checkCase*(self: UnreachableCode; node: Node): void =
    var elseBranch = node.elseBranch
    if elseBranch:
    else:
      return false
    if isFlowExpression(elseBranch):
    else:
      return false
    node.whenBranches.allIt:
      it.body and isFlowExpression(it.body)

