
cop :
  type
    Send* = ref object of Cop
    ##  This cop checks for the use of the send method.
    ## 
    ##  @example
    ##    # bad
    ##    Foo.send(:bar)
    ##    quuz.send(:fred)
    ## 
    ##    # good
    ##    Foo.__send__(:bar)
    ##    quuz.public_send(:fred)
  const
    MSG = """Prefer `Object#__send__` or `Object#public_send` to `send`."""
  nodeMatcher isSending, "({send csend} _ :send ...)"
  method onSend*(self: Send; node: Node): void =
    if isSending node and node.isArguments:
    addOffense(node, location = "selector")

