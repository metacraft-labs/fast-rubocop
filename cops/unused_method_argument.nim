
import
  sequtils

import
  unusedArgument

cop :
  type
    UnusedMethodArgument* = ref object of Cop
  method autocorrect*(self: UnusedMethodArgument; node: Node): void =
    UnusedArgCorrector.correct(processedSource, node)

  method checkArgument*(self: UnusedMethodArgument; variable: Variable): void =
    if variable.isMethodArgument:
    if variable.isKeywordArgument and copConfig["AllowUnusedKeywordArguments"]:
      return
    if copConfig["IgnoreEmptyMethods"]:
      var body = variable.scope.node.body
      if body.isNil():
        return
  
  method message*(self: UnusedMethodArgument; variable: Variable): void =
    var message = String.new("""Unused method argument - `(send
  (lvar :variable) :name)`.""")
    if variable.isKeywordArgument:
    else:
      message.<<("""(str " If it's necessary, use `_` or `_")as an argument name to indicate that it won't be used.""")
    var
      scope = variable.scope
      allArguments = scope.variables.eachValue().filterIt:
        it.isEthodArgument
    if allArguments.isNone(proc (it: void): void =
      it.isEferenced):
      message.<<("""(str " You can also write as `")if you want the method to accept any arguments but don't care about them.""")
    message

