
import
  types

cop SymbolLiteral:
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
  method onSym*(self; node) =
    if not node.source.=~():
      return
    addOffense(node)

