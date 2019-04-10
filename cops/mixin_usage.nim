
cop :
  type
    MixinUsage* = ref object of Cop
    ##  This cop checks that `include`, `extend` and `prepend` statements appear
    ##  inside classes and modules, not at the top level, so as to not affect
    ##  the behavior of `Object`.
    ## 
    ##  @example
    ##    # bad
    ##    include M
    ## 
    ##    class C
    ##    end
    ## 
    ##    # bad
    ##    extend M
    ## 
    ##    class C
    ##    end
    ## 
    ##    # bad
    ##    prepend M
    ## 
    ##    class C
    ##    end
    ## 
    ##    # good
    ##    class C
    ##      include M
    ##    end
    ## 
    ##    # good
    ##    class C
    ##      extend M
    ##    end
    ## 
    ##    # good
    ##    class C
    ##      prepend M
    ##    end
  const
    MSG = """`%<statement>s` is used at the top level. Use inside `class` or `module`."""
  nodeMatcher includeStatement, """          (send nil? ${:include :extend :prepend}
            const)
"""
  method onSend*(self: MixinUsage; node: Node): void =
    includeStatement node:
      if node.isArgument or isAcceptedInclude(node) or
          isBelongsToClassOrModule(node):
        return
      addOffense(node, message = format(MSG, statement = statement))

  method isAcceptedInclude*(self: MixinUsage; node: Node): void =
    node.parent and node.isMacro

  method isBelongsToClassOrModule*(self: MixinUsage; node: Node): void =
    if node.parent.!:
      false
    else:
      if node.parent.isClassType() or node.parent.isModuleType():
        return true
      isBelongsToClassOrModule(node.parent)

