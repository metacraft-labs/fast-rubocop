
cop :
  type
    BigDecimalNew* = ref object of Cop
  const
    MSG = """`%<double_colon>sBigDecimal.new()` is deprecated. Use `%<double_colon>sBigDecimal()` instead."""
  nodeMatcher bigDecimalNew, """          (send
            (const ${nil? cbase} :BigDecimal) :new ...)
"""
  method onSend*(self: BigDecimalNew; node: Node): void =
    if bigDecimalNew node:
      var
        doubleColon = if capturedValue:
          "::"
        message = format(MSG, doubleColon = doubleColon)
      addOffense(node, location = "selector", message = message):

  method autocorrect*(self: BigDecimalNew; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.remove(node.loc.selector)
      corrector.remove(node.loc.dot))

