
import
  sequtils

cop :
  type
    DoubleStartEndWith* = ref object of Cop
  const
    MSG = """Use `%<receiver>s.%<method>s(%<combined_args>s)` instead of `%<original_code>s`."""
  nodeMatcher twoStartEndWithCalls, """          (or
            (send $_recv [{:start_with? :end_with?} $_method] $...)
            (send _recv _method $...))
"""
  nodeMatcher checkWithActiveSupportAliases, """          (or
            (send $_recv
                    [{:start_with? :starts_with? :end_with? :ends_with?} $_method]
                  $...)
            (send _recv _method $...))
"""
  method onOr*(self: DoubleStartEndWith; node: Node): void =
    if receiver and
        secondCallArgs.allIt:
      it.isUre:
    var combinedArgs = combineArgs(firstCallArgs, secondCallArgs)
    addOffenseForDoubleCall(node, receiver, method, combinedArgs)

  method autocorrect*(self: DoubleStartEndWith; node: Node): void =
    var
      combinedArgs = combineArgs(firstCallArgs, secondCallArgs)
      firstArgument = firstCallArgs[0].loc.expression
      lastArgument = secondCallArgs.last().loc.expression
      range = firstArgument.join(lastArgument)
    lambda(proc (corrector: Corrector): void =
      corrector.replace(range, combinedArgs))

  method processSource*(self: DoubleStartEndWith; node: Node): void =
    if isCheckForActiveSupportAliases:
      checkWithActiveSupportAliases node
    else:
      twoStartEndWithCalls node
  
  method combineArgs*(self: DoubleStartEndWith; firstCallArgs: Array;
                     secondCallArgs: Array): void =
      firstCallArgs & secondCallArgs.mapIt:
      it.ource.join(", ")

  method addOffenseForDoubleCall*(self: DoubleStartEndWith; node: Node;
                                 receiver: Node; method: Symbol;
                                 combinedArgs: string): void =
    var msg = format(MSG, receiver = receiver.source, method = method,
                  combinedArgs = combinedArgs, originalCode = node.source)
    addOffense(node, message = msg)

  method isCheckForActiveSupportAliases*(self: DoubleStartEndWith): void =
    copConfig["IncludeActiveSupportAliases"]

