
import
  safeMode

cop :
  type
    Detect* = ref object of Cop
  const
    MSG = """Use `%<prefer>s` instead of `%<first_method>s.%<second_method>s`."""
  const
    REVERSEMSG = """Use `reverse.%<prefer>s` instead of `%<first_method>s.%<second_method>s`."""
  nodeMatcher isDetectCandidate, """          {
            (send $(block (send _ {:select :find_all}) ...) ${:first :last} $...)
            (send $(send _ {:select :find_all} ...) ${:first :last} $...)
          }
"""
  method onSend*(self: Detect; node: Node): void =
    if isRailsSafeMode:
      return
    isDetectCandidate node:
      if args.isEmpty:
      if receiver:
      if receiver.isBlockType():
      if isAcceptFirstCall(receiver, body):
        return
      registerOffense(node, receiver, secondMethod)

  method autocorrect*(self: Detect; node: Node): void =
    var
      replacement = if firstMethod == "last":
        """reverse.(send nil :preferred_method)"""
      firstRange = receiver.sourceRange.end.join(node.loc.selector)
    if receiver.isBlockType():
    lambda(proc (corrector: Corrector): void =
      corrector.remove(firstRange)
      corrector.replace(receiver.loc.selector, replacement))

  method isAcceptFirstCall*(self: Detect; receiver: Node; body: Node): void =
    if body.isNil() and
      args.isNil() or args.isBlockPassType().!:
      return true
    isLazy(caller)

  method registerOffense*(self: Detect; node: Node; receiver: Node;
                         secondMethod: Symbol): void =
    var
      range = receiver.loc.selector.join(node.loc.selector)
      message = if secondMethod == "last":
        REVERSEMSG
      formattedMessage = format(message, prefer = preferredMethod,
                              firstMethod = firstMethod,
                              secondMethod = secondMethod)
    addOffense(node, location = range, message = formattedMessage)

  method preferredMethod*(self: Detect): void =
    config.forCop("Style/CollectionMethods")["PreferredMethods"]["detect"] or
        "detect"

  method isLazy*(self: Detect; node: Node): void =
    if node:
    else:
      return false
    method == "lazy" and receiver.isNil().!

