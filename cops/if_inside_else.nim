
cop :
  type
    IfInsideElse* = ref object of Cop
    ##  If the `else` branch of a conditional consists solely of an `if` node,
    ##  it can be combined with the `else` to become an `elsif`.
    ##  This helps to keep the nesting level from getting too deep.
    ## 
    ##  @example
    ##    # bad
    ##    if condition_a
    ##      action_a
    ##    else
    ##      if condition_b
    ##        action_b
    ##      else
    ##        action_c
    ##      end
    ##    end
    ## 
    ##    # good
    ##    if condition_a
    ##      action_a
    ##    elsif condition_b
    ##      action_b
    ##    else
    ##      action_c
    ##    end
  const
    MSG = "Convert `if` nested inside `else` to `elsif`."
  method onIf*(self: IfInsideElse; node: Node): void =
    if node.isTernary or node.isUnless:
      return
    var elseBranch = node.elseBranch
    if elseBranch and elseBranch.isIfType() and elseBranch.isIf:
    addOffense(elseBranch, location = "keyword")

