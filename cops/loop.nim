
cop :
  type
    Loop* = ref object of Cop
  const
    MSG = """Use `Kernel#loop` with `break` rather than `begin/end/until`(or `while`)."""
  method onWhilePost*(self: Loop; node: Node): void =
    registerOffense(node)

  method onUntilPost*(self: Loop; node: Node): void =
    registerOffense(node)

  method registerOffense*(self: Loop; node: Node): void =
    addOffense(node, location = "keyword")

