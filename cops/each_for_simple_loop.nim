
cop :
  type
    EachForSimpleLoop* = ref object of Cop
    ##  This cop checks for loops which iterate a constant number of times,
    ##  using a Range literal and `#each`. This can be done more readably using
    ##  `Integer#times`.
    ## 
    ##  This check only applies if the block takes no parameters.
    ## 
    ##  @example
    ##    # bad
    ##    (1..5).each { }
    ## 
    ##    # good
    ##    5.times { }
    ## 
    ##  @example
    ##    # bad
    ##    (0...10).each {}
    ## 
    ##    # good
    ##    10.times {}
  const
    MSG = """Use `Integer#times` for a simple loop which iterates a fixed number of times."""
  nodeMatcher offendingEachRange, "          (block (send (begin (${irange erange} (int $_) (int $_))) :each) (args) ...)\n"
  method onBlock*(self: EachForSimpleLoop; node: Node): void =
    if offendingEachRange node:
    var
      sendNode = node.sendNode
      range = sendNode.receiver.sourceRange.join(sendNode.loc.selector)
    addOffense(node, location = range)

  method autocorrect*(self: EachForSimpleLoop; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      if rangeType == "irange":
        max += 1
      corrector.replace(node.sendNode.sourceRange, """(send
  (lvar :max) :-
  (lvar :min)).times"""))

