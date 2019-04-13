
cop :
  type
    WhileUntilDo* = ref object of Cop
    ##  Checks for uses of `do` in multi-line `while/until` statements.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    while x.any? do
    ##      do_something(x.pop)
    ##    end
    ## 
    ##    # good
    ##    while x.any?
    ##      do_something(x.pop)
    ##    end
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    until x.empty? do
    ##      do_something(x.pop)
    ##    end
    ## 
    ##    # good
    ##    until x.empty?
    ##      do_something(x.pop)
    ##    end
  const
    MSG = "Do not use `do` with multi-line `%<keyword>s`."
  method onWhile*(self: WhileUntilDo; node: Node): void =
    handle(node)

  method onUntil*(self: WhileUntilDo; node: Node): void =
    handle(node)

  method handle*(self: WhileUntilDo; node: Node): void =
    if node.isMultiline and node.isDo:
    addOffense(node, location = "begin",
               message = format(MSG, keyword = node.keyword))

  method autocorrect*(self: WhileUntilDo; node: Node): void =
    var doRange = node.condition.sourceRange.end.join(node.loc.begin)
    lambda(proc (corrector: Corrector): void =
      corrector.remove(doRange))

