
import
  sequtils

import
  unusedArgument

cop :
  type
    UnusedBlockArgument* = ref object of Cop
  method autocorrect*(self: UnusedBlockArgument; node: Node): void =
    UnusedArgCorrector.correct(processedSource, node)

  method checkArgument*(self: UnusedBlockArgument; variable: Variable): void =
    if isAllowedBlock(variable) or isAllowedKeywordArgument(variable):
      return
  
  method isAllowedBlock*(self: UnusedBlockArgument; variable: Variable): void =
    variable.isBlockArgument.! or
      isIgnoreEmptyBlocks and isEmptyBlock(variable)

  method isAllowedKeywordArgument*(self: UnusedBlockArgument; variable: Variable): void =
    variable.isKeywordArgument and isAllowUnusedKeywordArguments

  method message*(self: UnusedBlockArgument; variable: Variable): void =
    var message = """Unused (send nil :variable_type
  (lvar :variable)) - `(send
  (lvar :variable) :name)`."""
    if variable.isExplicitBlockLocalVariable:
      message
    else:
      augmentMessage(message, variable)
  
  method augmentMessage*(self: UnusedBlockArgument; message: string;
                        variable: Variable): void =
    var
      scope = variable.scope
      allArguments = scope.variables.eachValue().filterIt:
        it.isLockArgument
      augmentation = if scope.node.isLambda:
        messageForLambda(variable, allArguments)
      else:
        messageForNormalBlock(variable, allArguments)
    @[message, augmentation].join(" ")

  method variableType*(self: UnusedBlockArgument; variable: Variable): void =
    if variable.isExplicitBlockLocalVariable:
      "block local variable"
  
  method messageForNormalBlock*(self: UnusedBlockArgument; variable: Variable;
                               allArguments: Array): void =
    if allArguments.isNone(proc (it: void): void =
      it.isEferenced) and isDefineMethodCall(variable).!:
      if allArguments.count() > 1:
        "You can omit all the arguments if you don\'t care about them."
    else:
      messageForUnderscorePrefix(variable)
  
  method messageForLambda*(self: UnusedBlockArgument; variable: Variable;
                          allArguments: Array): void =
    var message = messageForUnderscorePrefix(variable)
    if allArguments.isNone(proc (it: void): void =
      it.isEferenced):
      var procMessage = """Also consider using a proc without arguments instead of a lambda if you want it to accept any arguments but don't care about them."""
    @[message, procMessage].compact().join(" ")

  method messageForUnderscorePrefix*(self: UnusedBlockArgument; variable: Variable): void =
    """(str "If it's necessary, use `_` or `_")as an argument name to indicate that it won't be used."""

  method isDefineMethodCall*(self: UnusedBlockArgument; variable: Variable): void =
    var call = variable.scope.node[0]
    method == "define_method"

  method isEmptyBlock*(self: UnusedBlockArgument; variable: Variable): void =
    body.isNil()

  method isAllowUnusedKeywordArguments*(self: UnusedBlockArgument): void =
    copConfig["AllowUnusedKeywordArguments"]

  method isIgnoreEmptyBlocks*(self: UnusedBlockArgument): void =
    copConfig["IgnoreEmptyBlocks"]

