
cop :
  type
    MinMax* = ref object of Cop
    ##  This cop checks for potential uses of `Enumerable#minmax`.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    bar = [foo.min, foo.max]
    ##    return foo.min, foo.max
    ## 
    ##    # good
    ##    bar = foo.minmax
    ##    return foo.minmax
  const
    MSG = "Use `%<receiver>s.minmax` instead of `%<offender>s`."
  nodeMatcher minMaxCandidate, "          ({array return} (send [$_receiver !nil?] :min) (send [$_receiver !nil?] :max))\n"
  method onArray*(self: MinMax; node: Node): void =
    minMaxCandidate node:
      var offender = offendingRange(node)
      addOffense(node, location = offender, message = message(offender, receiver))

  method autocorrect*(self: MinMax; node: Node): void =
    var receiver = node.children[0].receiver
    lambda(proc (corrector: Corrector): void =
      corrector.replace(offendingRange(node), """(send
  (lvar :receiver) :source).minmax"""))

  method message*(self: MinMax; offender: Range; receiver: Node): void =
    format(MSG, offender = offender.source, receiver = receiver.source)

  method offendingRange*(self: MinMax; node: Node): void =
    case node.type
    of "return":
      argumentRange(node)
    else:
      node.loc.expression
  
  method argumentRange*(self: MinMax; node: Node): void =
    var
      firstArgumentRange = node.children[0].loc.expression
      lastArgumentRange = node.children.last().loc.expression
    firstArgumentRange.join(lastArgumentRange)

