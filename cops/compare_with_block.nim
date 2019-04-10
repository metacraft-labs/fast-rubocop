
import
  rangeHelp

cop :
  type
    CompareWithBlock* = ref object of Cop
  const
    MSG = """Use `%<compare_method>s_by%<instead>s` instead of `%<compare_method>s { |%<var_a>s, %<var_b>s| %<str_a>s <=> %<str_b>s }`."""
  nodeMatcher isCompare, """          (block
            $(send _ {:sort :min :max})
            (args (arg $_a) (arg $_b))
            $send)
"""
  nodeMatcher isReplaceableBody, """          (send
            (send (lvar %1) $_method $...)
            :<=>
            (send (lvar %2) _method $...))
"""
  method onBlock*(self: CompareWithBlock; node: Node): void =
    isCompare node:
      isReplaceableBody body,varA,varB:
        if isSlowCompare(method, argsA, argsB):
        var range = compareRange(send, node)
        addOffense(node, location = range,
                   message = message(send, method, varA, varB, argsA))

  method autocorrect*(self: CompareWithBlock; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var replacement = if method == "[]":
        """(send
  (lvar :send) :method_name)_by { |a| a[(send
  (send
    (lvar :arg) :first) :source)] }"""
      corrector.replace(compareRange(send, node), replacement))

  method isSlowCompare*(self: CompareWithBlock; method: Symbol; argsA: Array;
                       argsB: Array): void =
    if argsA == argsB:
    else:
      return false
    if method == "[]":
      if argsA.size == 1:
      else:
        return false
      var key = argsA[0]
      if @["sym", "str", "int"].isInclude(key.type):
      else:
        return false
    elif argsA.isEmpty:
    else:
      return false
    true

  method message*(self: CompareWithBlock; send: Node; method: Symbol; varA: Symbol;
                 varB: Symbol; args: Array): void =
    var compareMethod = send.methodName
    if method == "[]":
      var
        key = args[0]
        instead = """ { |a| a[(send
  (lvar :key) :source)] }"""
        strA = """(lvar :var_a)[(send
  (lvar :key) :source)]"""
        strB = """(lvar :var_b)[(send
  (lvar :key) :source)]"""
    else:
      instead = """(&:(lvar :method))"""
      strA = """(lvar :var_a).(lvar :method)"""
      strB = """(lvar :var_b).(lvar :method)"""
    format(MSG, compareMethod = compareMethod, instead = instead, varA = varA,
           varB = varB, strA = strA, strB = strB)

  method compareRange*(self: CompareWithBlock; send: Node; node: Node): void =
    rangeBetween(send.loc.selector.beginPos, node.loc.end.endPos)

