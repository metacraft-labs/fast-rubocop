
cop :
  type
    EnsureReturn* = ref object of Cop
  const
    MSG = "Do not return from an `ensure` block."
  method onEnsure*(self: EnsureReturn; node: Node): void =
    var ensureBody = node.body
    if ensureBody:
    ensureBody.eachNode("return", proc (returnNode: Node): void =
      addOffense(returnNode))

