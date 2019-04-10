
import
  frozenStringLiteral

cop :
  type
    RedundantFreeze* = ref object of Cop
    ##  This cop check for uses of Object#freeze on immutable objects.
    ## 
    ##  @example
    ##    # bad
    ##    CONST = 1.freeze
    ## 
    ##    # good
    ##    CONST = 1
  const
    MSG = """Do not freeze immutable objects, as freezing them has no effect."""
  method onSend*(self: RedundantFreeze; node: Node): void =
    if node.receiver and node.isMethod("freeze") and
        isImmutableLiteral(node.receiver):
    addOffense(node)

  method autocorrect*(self: RedundantFreeze; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.remove(node.loc.dot)
      corrector.remove(node.loc.selector))

  method isImmutableLiteral*(self: RedundantFreeze; node: Node): void =
    node = stripParenthesis(node)
    if node.isImmutableLiteral():
      return true
    FROZENSTRINGLITERALTYPES.isInclude(node.type) and
        isFrozenStringLiteralsEnabled

  method stripParenthesis*(self: RedundantFreeze; node: Node): void =
    if node.isBeginType() and node.children[0]:
      node.children[0]
  
