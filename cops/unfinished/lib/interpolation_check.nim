
cop :
  type
    InterpolationCheck* = ref object of Cop
  const
    MSG = """Interpolation in single quoted string detected. Use double quoted strings if you need interpolation."""
  method onStr*(self: InterpolationCheck; node: Node): void =
    if isHeredoc(node):
      return
    var parent = node.parent
    if parent and
      parent.isDstrType() or parent.isRegexpType():
      return
    if node.source.scrub().=~():
    addOffense(node)

  method isHeredoc*(self: InterpolationCheck; node: Node): void =
    node.loc.isIsA(Heredoc) or
      node.parent and isHeredoc(node.parent)

