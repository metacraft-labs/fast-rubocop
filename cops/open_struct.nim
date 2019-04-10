
cop :
  type
    OpenStruct* = ref object of Cop
  const
    MSG = """Consider using `Struct` over `OpenStruct` to optimize the performance."""
  nodeMatcher openStruct,
             "          (send (const {nil? cbase} :OpenStruct) :new ...)\n"
  method onSend*(self: OpenStruct; node: Node): void =
    openStruct node:
      addOffense(node, location = "selector", message = format(MSG, method))

