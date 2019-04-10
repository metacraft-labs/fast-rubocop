
import
  types

cop BooleanSymbol:
  ##  This cop checks for `:true` and `:false` symbols.
  ##  In most cases it would be a typo.
  ## 
  ##  @example
  ## 
  ##    # bad
  ##    :true
  ## 
  ##    # good
  ##    true
  ## 
  ##  @example
  ## 
  ##    # bad
  ##    :false
  ## 
  ##    # good
  ##    false
  const
    MSG = """Symbol with a boolean name - you probably meant to use `%<boolean>s`."""
  nodeMatcher isBooleanSymbol, "(sym {:true :false})"
  method onSym*(self; node) =
    if not isBooleanSymbol(node):
      return
    addOffense(node, message = format(MSG, boolean = node.value()))

