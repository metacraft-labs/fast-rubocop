
cop :
  type
    ArrayJoin* = ref object of Cop
    ##  This cop checks for uses of "*" as a substitute for *join*.
    ## 
    ##  Not all cases can reliably checked, due to Ruby's dynamic
    ##  types, so we consider only cases when the first argument is an
    ##  array literal or the second is a string literal.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    %w(foo bar baz) * ","
    ## 
    ##    # good
    ##    %w(foo bar baz).join(",")
    ## 
  const
    MSG = "Favor `Array#join` over `Array#*`."
  nodeMatcher isJoinCandidate, "(send $array :* $str)"
  method onSend*(self: ArrayJoin; node: Node): void =
    isJoinCandidate node:
      addOffense(node, location = "selector")

  method autocorrect*(self: ArrayJoin; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange,
                        """(lvar :array).join((lvar :join_arg))"""))

