
import
  types

cop MultilineTernaryOperator:
  ##  This cop checks for multi-line ternary op expressions.
  ## 
  ##  @example
  ##    # bad
  ##    a = cond ?
  ##      b : c
  ##    a = cond ? b :
  ##        c
  ##    a = cond ?
  ##        b :
  ##        c
  ## 
  ##    # good
  ##    a = cond ? b : c
  ##    a =
  ##      if cond
  ##        b
  ##      else
  ##        c
  ##      end
  const
    MSG = """Avoid multi-line ternary operators, use `if` or `unless` instead."""
  method onIf*(self; node) =
    if not (node.isTernary and node.isMultiline):
      return
    addOffense(node)

