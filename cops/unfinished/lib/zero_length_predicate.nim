
cop :
  type
    ZeroLengthPredicate* = ref object of Cop
    ##  This cop checks for numeric comparisons that can be replaced
    ##  by a predicate method, such as receiver.length == 0,
    ##  receiver.length > 0, receiver.length != 0,
    ##  receiver.length < 1 and receiver.size == 0 that can be
    ##  replaced by receiver.empty? and !receiver.empty.
    ## 
    ##  @example
    ##    # bad
    ##    [1, 2, 3].length == 0
    ##    0 == "foobar".length
    ##    array.length < 1
    ##    {a: 1, b: 2}.length != 0
    ##    string.length > 0
    ##    hash.size > 0
    ## 
    ##    # good
    ##    [1, 2, 3].empty?
    ##    "foobar".empty?
    ##    array.empty?
    ##    !{a: 1, b: 2}.empty?
    ##    !string.empty?
    ##    !hash.empty?
  const
    ZEROMSG = "Use `empty?` instead of `%<lhs>s %<opr>s %<rhs>s`."
  const
    NONZEROMSG = """Use `!empty?` instead of `%<lhs>s %<opr>s %<rhs>s`."""
  nodeMatcher zeroLengthPredicate, """          {(send (send (...) ${:length :size}) $:== (int $0))
           (send (int $0) $:== (send (...) ${:length :size}))
           (send (send (...) ${:length :size}) $:<  (int $1))
           (send (int $1) $:> (send (...) ${:length :size}))}
"""
  nodeMatcher nonzeroLengthPredicate, """          {(send (send (...) ${:length :size}) ${:> :!=} (int $0))
           (send (int $0) ${:< :!=} (send (...) ${:length :size}))}
"""
  nodeMatcher zeroLengthReceiver, """          {(send (send $_ _) :== (int 0))
           (send (int 0) :== (send $_ _))
           (send (send $_ _) :<  (int 1))
           (send (int 1) :> (send $_ _))}
"""
  nodeMatcher otherReceiver, """          {(send (send $_ _) _ _)
           (send _ _ (send $_ _))}
"""
  nodeMatcher isNonPolymorphicCollection, """          {(send (send (send (const nil? :File) :stat _) ...) ...)
           (send (send (send (const nil? {:Tempfile :StringIO}) {:new :open} ...) ...) ...)}
"""
  method onSend*(self: ZeroLengthPredicate; node: Node): void =
    checkZeroLengthPredicate(node)
    checkNonzeroLengthPredicate(node)

  method autocorrect*(self: ZeroLengthPredicate; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.expression, replacement(node)))

  method checkZeroLengthPredicate*(self: ZeroLengthPredicate; node: Node): void =
    var zeroLengthPredicate = zeroLengthPredicate node
    if zeroLengthPredicate:
    if isNonPolymorphicCollection node:
      return
    addOffense(node, message = format(ZEROMSG, lhs = lhs, opr = opr, rhs = rhs))

  method checkNonzeroLengthPredicate*(self: ZeroLengthPredicate; node: Node): void =
    var nonzeroLengthPredicate = nonzeroLengthPredicate node
    if nonzeroLengthPredicate:
    if isNonPolymorphicCollection node:
      return
    addOffense(node,
               message = format(NONZEROMSG, lhs = lhs, opr = opr, rhs = rhs))

  method replacement*(self: ZeroLengthPredicate; node: Node): void =
    var receiver = zeroLengthReceiver node
    if receiver:
      return """(send
  (lvar :receiver) :source).empty?"""
    """!(send
  (send nil :other_receiver
    (lvar :node)) :source).empty?"""

