
cop :
  type
    ElseLayout* = ref object of Cop
  const
    MSG = "Odd `else` layout detected. Did you mean to use `elsif`?"
  method onIf*(self: ElseLayout; node: Node): void =
    if node.isTernary or node.isElsif:
      return
    check(node)

  method check*(self: ElseLayout; node: Node): void =
    if node.elseBranch:
    if node.isElse and node.loc.else.isIs("else"):
      checkElse(node)
    elif node.isIf:
      check(node.elseBranch)
  
  method checkElse*(self: ElseLayout; node: Node): void =
    var elseBranch = node.elseBranch
    if elseBranch.isBeginType():
    var firstElse = elseBranch.children[0]
    if firstElse.sourceRange.line == node.loc.else.line:
    addOffense(firstElse)

