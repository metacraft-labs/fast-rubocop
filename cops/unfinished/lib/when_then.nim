
cop :
  type
    WhenThen* = ref object of Cop
    ##  This cop checks for *when;* uses in *case* expressions.
    ## 
    ##  @example
    ##    # bad
    ##    case foo
    ##    when 1; 'baz'
    ##    when 2; 'bar'
    ##    end
    ## 
    ##    # good
    ##    case foo
    ##    when 1 then 'baz'
    ##    when 2 then 'bar'
    ##    end
  const
    MSG = "Do not use `when x;`. Use `when x then` instead."
  method onWhen*(self: WhenThen; node: Node): void =
    if node.isMultiline or node.isThen or node.body.!:
      return
    addOffense(node, location = "begin")

  method autocorrect*(self: WhenThen; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.begin, " then"))

