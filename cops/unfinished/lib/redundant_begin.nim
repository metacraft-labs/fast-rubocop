
cop :
  type
    RedundantBegin* = ref object of Cop
    ##  This cop checks for redundant `begin` blocks.
    ## 
    ##  Currently it checks for code like this:
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    def redundant
    ##      begin
    ##        ala
    ##        bala
    ##      rescue StandardError => e
    ##        something
    ##      end
    ##    end
    ## 
    ##    # good
    ##    def preferred
    ##      ala
    ##      bala
    ##    rescue StandardError => e
    ##      something
    ##    end
    ## 
    ##    # bad
    ##    # When using Ruby 2.5 or later.
    ##    do_something do
    ##      begin
    ##        something
    ##      rescue => ex
    ##        anything
    ##      end
    ##    end
    ## 
    ##    # good
    ##    # In Ruby 2.5 or later, you can omit `begin` in `do-end` block.
    ##    do_something do
    ##      something
    ##    rescue => ex
    ##      anything
    ##    end
    ## 
    ##    # good
    ##    # Stabby lambdas don't support implicit `begin` in `do-end` blocks.
    ##    -> do
    ##      begin
    ##        foo
    ##      rescue Bar
    ##        baz
    ##      end
    ##    end
  const
    MSG = "Redundant `begin` block detected."
  method onDef*(self: RedundantBegin; node: Node): void =
    check(node)

  method onBlock*(self: RedundantBegin; node: Node): void =
    if targetRubyVersion < 0.0:
      return
    if node.sendNode.isLambdaLiteral:
      return
    if node.isBraces:
      return
    check(node)

  method autocorrect*(self: RedundantBegin; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.remove(node.loc.begin)
      corrector.remove(node.loc.end))

  method check*(self: RedundantBegin; node: Node): void =
    if node.body and node.body.isKwbeginType():
    addOffense(node.body, location = "begin")

