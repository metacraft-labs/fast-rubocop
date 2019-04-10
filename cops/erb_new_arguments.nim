
cop :
  type
    ErbNewArguments* = ref object of Cop
  const
    MESSAGES = @["""Passing safe_level with the 2nd argument of `ERB.new` is deprecated. Do not use it, and specify other arguments as keyword arguments.""", """Passing trim_mode with the 3rd argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, trim_mode: %<arg_value>s)` instead.""", """Passing eoutvar with the 4th argument of `ERB.new` is deprecated. Use keyword argument like `ERB.new(str, eoutvar: %<arg_value>s)` instead."""]
  nodeMatcher erbNewWithNonKeywordArguments, """          (send
            (const {nil? cbase} :ERB) :new $...)
"""
  method onSend*(self: ErbNewArguments; node: Node): void =
    erbNewWithNonKeywordArguments node:
      if isCorrectArguments(arguments):
        return
      1.upto(3, proc (i: Integer): void =
        if arguments[i].! or arguments[i].isHashType():
          continue
        var message = format(MESSAGES[i - 1], argValue = arguments[i].source)
        addOffense(node, location = arguments[i].sourceRange, message = message))

  method isCorrectArguments*(self: ErbNewArguments; arguments: Array): void =
    arguments.size == 1 or arguments.size == 2 and arguments[1].isHashType()

  extend(TargetRubyVersion)
  minimumTargetRubyVersion(0.0)
