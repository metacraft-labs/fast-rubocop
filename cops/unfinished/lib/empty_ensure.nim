
cop :
  type
    EmptyEnsure* = ref object of Cop
  const
    MSG = "Empty `ensure` block detected."
  method onEnsure*(self: EmptyEnsure; node: Node): void =
    if node.body:
    else:
      addOffense(node, location = "keyword")
  
  method autocorrect*(self: EmptyEnsure; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.remove(node.loc.keyword))

