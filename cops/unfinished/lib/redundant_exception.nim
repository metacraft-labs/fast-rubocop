
cop :
  type
    RedundantException* = ref object of Cop
    ##  This cop checks for RuntimeError as the argument of raise/fail.
    ## 
    ##  It checks for code like this:
    ## 
    ##  @example
    ##    # Bad
    ##    raise RuntimeError, 'message'
    ## 
    ##    # Bad
    ##    raise RuntimeError.new('message')
    ## 
    ##    # Good
    ##    raise 'message'
  const
    MSG1 = "Redundant `RuntimeError` argument can be removed."
  const
    MSG2 = """Redundant `RuntimeError.new` call can be replaced with just the message."""
  nodeMatcher isExploded, "          (send nil? ${:raise :fail} (const nil? :RuntimeError) $_)\n"
  nodeMatcher isCompact, "          (send nil? {:raise :fail} $(send (const nil? :RuntimeError) :new $_))\n"
  method onSend*(self: RedundantException; node: Node): void =
    isExploded node:
      return addOffense(node, message = MSG1)
    isCompact node:
      addOffense(node, message = MSG2)

  method autocorrect*(self: RedundantException; node: Node): void =
    ##  Switch `raise RuntimeError, 'message'` to `raise 'message'`, and
    ##  `raise RuntimeError.new('message')` to `raise 'message'`.
    isExploded node:
      return lambda(proc (corrector: Corrector): void =
        if node.isParenthesized:
          corrector.replace(node.sourceRange, """(lvar :command)((send
  (lvar :message) :source))""")
        else:
          corrector.replace(node.sourceRange, """(lvar :command) (send
  (lvar :message) :source)""")
      )
    isCompact node:
      lambda(proc (corrector: Corrector): void =
        corrector.replace(newCall.sourceRange, message.source))

