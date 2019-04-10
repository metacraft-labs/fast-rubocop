
cop :
  type
    RandomWithOffset* = ref object of Cop
    ##  This cop checks for the use of randomly generated numbers,
    ##  added/subtracted with integer literals, as well as those with
    ##  Integer#succ and Integer#pred methods. Prefer using ranges instead,
    ##  as it clearly states the intentions.
    ## 
    ##  @example
    ##    # bad
    ##    rand(6) + 1
    ##    1 + rand(6)
    ##    rand(6) - 1
    ##    1 - rand(6)
    ##    rand(6).succ
    ##    rand(6).pred
    ##    Random.rand(6) + 1
    ##    Kernel.rand(6) + 1
    ##    rand(0..5) + 1
    ## 
    ##    # good
    ##    rand(1..6)
    ##    rand(1...7)
  const
    MSG = """Prefer ranges when generating random numbers instead of integers with offsets."""
  nodeMatcher isIntegerOpRand, """          (send
            int {:+ :-}
            (send
              {nil? (const nil? :Random) (const nil? :Kernel)}
              :rand
              {int irange erange}))
"""
  nodeMatcher isRandOpInteger, """          (send
            (send
              {nil? (const nil? :Random) (const nil? :Kernel)}
              :rand
              {int irange erange})
            {:+ :-}
            int)
"""
  nodeMatcher isRandModified, """          (send
            (send
              {nil? (const nil? :Random) (const nil? :Kernel)}
              :rand
              {int irange erange})
            {:succ :pred :next})
"""
  method onSend*(self: RandomWithOffset; node: Node): void =
    if isIntegerOpRand node or isRandOpInteger node or isRandModified node:
    addOffense(node)

  method autocorrect*(self: RandomWithOffset; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      if isIntegerOpRand node:
        corrector.replace(node.sourceRange, correctedIntegerOpRand(node))
      elif isRandOpInteger node:
        corrector.replace(node.sourceRange, correctedRandOpInteger(node))
      elif isRandModified node:
        corrector.replace(node.sourceRange, correctedRandModified(node))
    )

  method correctedIntegerOpRand*(self: RandomWithOffset; node: Node): void =
    var offset = intFromIntNode(left)
    var prefix = prefixFromPrefixNode(prefixNode)
    if operator == "+":
      """(lvar :prefix)((send
  (lvar :offset) :+
  (lvar :left_int))..(send
  (lvar :offset) :+
  (lvar :right_int)))"""
  
  method correctedRandOpInteger*(self: RandomWithOffset; node: Node): void =
    var
      offset = intFromIntNode(right)
      prefix = prefixFromPrefixNode(prefixNode)
    if operator == "+":
      """(lvar :prefix)((send
  (lvar :left_int) :+
  (lvar :offset))..(send
  (lvar :right_int) :+
  (lvar :offset)))"""
  
  method correctedRandModified*(self: RandomWithOffset; node: Node): void =
    var prefix = prefixFromPrefixNode(prefixNode)
    if @["succ", "next"].isInclude(method):
      """(lvar :prefix)((send
  (lvar :left_int) :+
  (int 1))..(send
  (lvar :right_int) :+
  (int 1)))"""
    elif method == "pred":
      """(lvar :prefix)((send
  (lvar :left_int) :-
  (int 1))..(send
  (lvar :right_int) :-
  (int 1)))"""
  
  method prefixFromPrefixNode*(self: RandomWithOffset; node: NilClass): void =
    if node.isNil():
      "rand"
    else:
      """(lvar :prefix).rand"""

  method boundariesFromRandomNode*(self: RandomWithOffset; randomNode: Node): void =
    var children = randomNode.children
    case randomNode.type
    of "int":
      (0, intFromIntNode(randomNode) - 1)
    of "irange":
      @[intFromIntNode(children[0]), intFromIntNode(children[1])]
    of "erange":
      (intFromIntNode(children[0]), intFromIntNode(children[1]) - 1)
    else:

  method intFromIntNode*(self: RandomWithOffset; node: Node): void =
    node.children[0]

