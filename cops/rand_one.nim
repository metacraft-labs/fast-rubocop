
cop :
  type
    RandOne* = ref object of Cop
  const
    MSG = """`%<method>s` always returns `0`. Perhaps you meant `rand(2)` or `rand`?"""
  nodeMatcher isRandOne, "          (send {(const nil? :Kernel) nil?} :rand {(int {-1 1}) (float {-1.0 1.0})})\n"
  method onSend*(self: RandOne; node: Node): void =
    if isRandOne node:
    addOffense(node)

  method message*(self: RandOne; node: Node): void =
    format(MSG, method = node.source)

