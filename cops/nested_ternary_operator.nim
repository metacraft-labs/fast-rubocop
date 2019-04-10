
import
  tables, sequtils

cop :
  type
    NestedTernaryOperator* = ref object of Cop
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
  method onIf*(self: NestedTernaryOperator; node: Node): void =
    if node.isTernary:
    for nestedTernary in node.eachDescendant("if").filterIt:
      it.isErnary:
      addOffense(nestedTernary)

