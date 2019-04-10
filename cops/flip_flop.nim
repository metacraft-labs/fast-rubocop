
cop :
  type
    FlipFlop* = ref object of Cop
  const
    MSG = "Avoid the use of flip-flop operators."
  method onIflipflop*(self: FlipFlop; node: Node): void =
    addOffense(node)

  method onEflipflop*(self: FlipFlop; node: Node): void =
    addOffense(node)

