
cop :
  type
    UselessComparison* = ref object of Cop
  const
    MSG = "Comparison of something with itself detected."
  const
    OPS = @["==", "===", "!=", "<", ">", "<=", ">=", "<=>"]
  nodeMatcher isUselessComparison, """(send $_match {:(send
  (const nil :OPS) :join
  (str " :"))} $_match)"""
  method onSend*(self: UselessComparison; node: Node): void =
    if isUselessComparison node:
    addOffense(node, location = "selector")

