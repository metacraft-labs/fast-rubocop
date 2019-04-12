
import
  types

cop Send:
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
  method onSend*(self; node) =
    echo node
    let temp0 = node
    echo temp0.len >= 3
    echo not temp0.isNil and temp0.isSendType()
    echo not temp0.isNil and temp0.isCsendType()
    echo temp0[1] == "send"

    if not (isSending(node) and node.isArguments()):
      return
    addOffense(node, location = selector)

