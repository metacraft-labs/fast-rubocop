
cop :
  type
    Casecmp* = ref object of Cop
  const
    MSG = "Use `%<good>s` instead of `%<bad>s`."
  const
    CASEMETHODS = @["downcase", "upcase"]
  nodeMatcher downcaseEq, """          (send
            $(send _ ${:downcase :upcase})
            ${:== :eql? :!=}
            ${str (send _ {:downcase :upcase} ...) (begin str)})
"""
  nodeMatcher eqDowncase, """          (send
            {str (send _ {:downcase :upcase} ...) (begin str)}
            ${:== :eql? :!=}
            $(send _ ${:downcase :upcase}))
"""
  nodeMatcher downcaseDowncase, """          (send
            $(send _ ${:downcase :upcase})
            ${:== :eql? :!=}
            $(send _ ${:downcase :upcase}))
"""
  method onSend*(self: Casecmp; node: Node): void =
    if downcaseEq node or eqDowncase node:
    if
      var parts = takeMethodApart(node):
    var goodMethod = buildGoodMethod(arg, variable)
    addOffense(node, message = format(MSG, good = goodMethod, bad = node.source))

  method autocorrect*(self: Casecmp; node: Node): void =
    if
      var parts = takeMethodApart(node):
    correction(node, receiver, method, arg, variable)

  method takeMethodApart*(self: Casecmp; node: Node): void =
    if downcaseDowncase node:
      var arg = rhs[0]
    elif downcaseEq node:
    elif eqDowncase node:
    var variable = receiver[0]
    @[receiver, method, arg, variable]

  method correction*(self: Casecmp; node: Node; _receiver: Node; method: Symbol;
                    arg: Node; variable: Node): void =
    lambda(proc (corrector: Corrector): void =
      if method == "!=":
        corrector.insertBefore(node.loc.expression, "!")
      var replacement = buildGoodMethod(arg, variable)
      corrector.replace(node.loc.expression, replacement))

  method buildGoodMethod*(self: Casecmp; arg: Node; variable: Node): void =
    if arg.isSendType() or isParentheses(arg).!:
      """(send
  (lvar :variable) :source).casecmp((send
  (lvar :arg) :source)).zero?"""
  
