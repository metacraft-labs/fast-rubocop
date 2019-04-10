
cop :
  type
    EndInMethod* = ref object of Cop
  const
    MSG = "`END` found in method definition. Use `at_exit` instead."
  method onPostexe*(self: EndInMethod; node: Node): void =
    var insideOfMethod = node.eachAncestor("def", "defs").count().isNonzero()
    if insideOfMethod:
      addOffense(node, location = "keyword")
  
