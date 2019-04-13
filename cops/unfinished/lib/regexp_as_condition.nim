
cop :
  type
    RegexpAsCondition* = ref object of Cop
  const
    MSG = """Do not use regexp literal as a condition. The regexp literal matches `$_` implicitly."""
  method onMatchCurrentLine*(self: RegexpAsCondition; node: Node): void =
    addOffense(node)

