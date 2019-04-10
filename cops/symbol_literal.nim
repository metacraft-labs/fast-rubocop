
cop :
  type
    SymbolLiteral* = ref object of Cop
    ##  This cop checks symbol literal syntax.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    :"symbol"
    ## 
    ##    # good
    ##    :symbol
  const
    MSG = "Do not use strings for word-like symbol literals."
  method onSym*(self: SymbolLiteral; node: Node): void =
    if node.source.=~():
    addOffense(node)

  method autocorrect*(self: SymbolLiteral; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, node.source.delete("\'\"")))

