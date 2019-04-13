
import
  sequtils

import
  configurableEnforcedStyle

cop :
  type
    RaiseArgs* = ref object of Cop
    ##  This cop checks the args passed to `fail` and `raise`. For exploded
    ##  style (default), it recommends passing the exception class and message
    ##  to `raise`, rather than construct an instance of the error. It will
    ##  still allow passing just a message, or the construction of an error
    ##  with more than one argument.
    ## 
    ##  The exploded style works identically, but with the addition that it
    ##  will also suggest constructing error objects when the exception is
    ##  passed multiple arguments.
    ## 
    ##  @example EnforcedStyle: exploded (default)
    ##    # bad
    ##    raise StandardError.new("message")
    ## 
    ##    # good
    ##    raise StandardError, "message"
    ##    fail "message"
    ##    raise MyCustomError.new(arg1, arg2, arg3)
    ##    raise MyKwArgError.new(key1: val1, key2: val2)
    ## 
    ##  @example EnforcedStyle: compact
    ##    # bad
    ##    raise StandardError, "message"
    ##    raise RuntimeError, arg1, arg2, arg3
    ## 
    ##    # good
    ##    raise StandardError.new("message")
    ##    raise MyCustomError.new(arg1, arg2, arg3)
    ##    fail "message"
  const
    EXPLODEDMSG = """Provide an exception class and message as arguments to `%<method>s`."""
  const
    COMPACTMSG = """Provide an exception object as an argument to `%<method>s`."""
  method onSend*(self: RaiseArgs; node: Node): void =
    if node.isCommand("raise") or node.isCommand("fail"):
    case style
    of "compact":
      checkCompact(node)
    of "exploded":
      checkExploded(node)
    else:

  method autocorrect*(self: RaiseArgs; node: Node): void =
    var replacement = if style == "compact":
      correctionExplodedToCompact(node)
    else:
      correctionCompactToExploded(node)
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, replacement))

  method correctionCompactToExploded*(self: RaiseArgs; node: Node): void =
    var arguments = @[exceptionNode, messageNode].compact().mapIt:
      it.ource.join(", ")
    if node.parent and isRequiresParens(node.parent):
      """(send
  (lvar :node) :method_name)((lvar :arguments))"""
  
  method correctionExplodedToCompact*(self: RaiseArgs; node: Node): void =
    if messageNodes.size > 1:
      return node.source
    var argument = messageNodes[0].source
    if node.parent and isRequiresParens(node.parent):
      """(send
  (lvar :node) :method_name)((send
  (lvar :exception_node) :const_name).new((lvar :argument)))"""
  
  method checkCompact*(self: RaiseArgs; node: Node): void =
    if node.arguments.size > 1:
      addOffense(node, proc (): void =
        oppositeStyleDetected)
  
  method checkExploded*(self: RaiseArgs; node: Node): void =
    if node.arguments.isOne():
    else:
      return correctStyleDetected
    var firstArg = node.firstArgument
    if firstArg.isSendType() and firstArg.isMethod("new"):
    if isAcceptableExplodedArgs(firstArg.arguments):
      return
    addOffense(node, proc (): void =
      oppositeStyleDetected)

  method isAcceptableExplodedArgs*(self: RaiseArgs; args: Array): void =
    if args.size > 1:
      return true
    if args.isEmpty:
      return false
    var arg = args[0]
    arg.isHashType() or arg.isSplatType()

  method isRequiresParens*(self: RaiseArgs; parent: Node): void =
    parent.isAndType() or parent.isOrType() or
        parent.isIfType() and parent.isTernary

  method message*(self: RaiseArgs; node: Node): void =
    if style == "compact":
      format(COMPACTMSG, method = node.methodName)
    else:
      format(EXPLODEDMSG, method = node.methodName)
  
