
cop :
  type
    RedundantMatch* = ref object of Cop
  const
    MSG = """Use `=~` in places where the `MatchData` returned by `#match` will not be used."""
  nodeMatcher isMatchCall, """          {(send {str regexp} :match _)
           (send !nil? :match {str regexp})}
"""
  nodeMatcher isOnlyTruthinessMatters, "          ^({if while until case while_post until_post} equal?(%0) ...)\n"
  method onSend*(self: RedundantMatch; node: Node): void =
    if isMatchCall node and
      node.isValueUsed.! or isOnlyTruthinessMatters node and
      node.parent and node.parent.isBlockType().!:
    addOffense(node)

  method autocorrect*(self: RedundantMatch; node: Node): void =
    if node.firstArgument.isRegexpType():
    var newSource = node.receiver.source & " =~ " & node.firstArgument.source
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, newSource))

