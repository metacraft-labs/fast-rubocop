
cop :
  type
    NextWithoutAccumulator* = ref object of Cop
  const
    MSG = "Use `next` with an accumulator argument in a `reduce`."
  nodeMatcher onBodyOfReduce, "          (block (send _recv {:reduce :inject} !sym) _blockargs $(begin ...))\n"
  method onBlock*(self: NextWithoutAccumulator; node: Node): void =
    onBodyOfReduce node:
      var voidNext = body.eachNode("next").find(proc (n: Node): void =
        n.children.isEmpty and parentBlockNode(n) == node)
      if voidNext:
        addOffense(voidNext)
  
  method parentBlockNode*(self: NextWithoutAccumulator; node: Node): void =
    node.eachAncestor("block")[0]

