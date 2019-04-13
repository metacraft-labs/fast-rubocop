
cop :
  type
    Caller* = ref object of Cop
  const
    MSGBRACE = """Use `%<method>s(%<n>d..%<n>d).first` instead of `%<method>s[%<m>d]`."""
  const
    MSGFIRST = """Use `%<method>s(%<n>d..%<n>d).first` instead of `%<method>s.first`."""
  nodeMatcher isSlowCaller, """          {
            (send nil? {:caller :caller_locations})
            (send nil? {:caller :caller_locations} int)
          }
"""
  nodeMatcher isCallerWithScopeMethod, """          {
            (send #slow_caller? :first)
            (send #slow_caller? :[] int)
          }
"""
  method onSend*(self: Caller; node: Node): void =
    if isCallerWithScopeMethod node:
    addOffense(node)

  method message*(self: Caller; node: Node): void =
    var
      methodName = node.receiver.methodName
      callerArg = node.receiver.firstArgument
      n = if callerArg:
        intValue(callerArg)
    if node.methodName == "[]":
      var m = intValue(node.firstArgument)
      n += m
      format(MSGBRACE, n = n, m = m, method = methodName)
    else:
      format(MSGFIRST, n = n, method = methodName)
  
  method intValue*(self: Caller; node: Node): void =
    node.children[0]

