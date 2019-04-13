
cop :
  type
    EachWithObjectArgument* = ref object of Cop
  const
    MSG = "The argument to each_with_object can not be immutable."
  nodeMatcher isEachWithObject,
             "          ({send csend} _ :each_with_object $_)\n"
  method onSend*(self: EachWithObjectArgument; node: Node): void =
    isEachWithObject node:
      if arg.isImmutableLiteral:
      addOffense(node)

