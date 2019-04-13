
cop :
  type
    HandleExceptions* = ref object of Cop
  const
    MSG = "Do not suppress exceptions."
  method onResbody*(self: HandleExceptions; node: Node): void =
    if node.body:
    else:
      addOffense(node)
  
