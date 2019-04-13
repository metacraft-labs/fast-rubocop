
import
  types

cop NestedTernaryOperator:
  ##  This cop checks for nested ternary op expressions.
  ## 
  ##  @example
  ##    # bad
  ##    a ? (b ? b1 : b2) : a2
  ## 
  ##    # good
  ##    if a
  ##      b ? b1 : b2
  ##    else
  ##      a2
  ##    end
  const
    MSG = """Ternary operators must not be nested. Prefer `if` or `else` constructs instead."""
  method onIf*(self; node) =
    if not node.isTernary:
      return
    for nestedTernary in node.eachDescendant("if").select(proc (it: void) =
      it.isTernary):
      addOffense(nestedTernary)

