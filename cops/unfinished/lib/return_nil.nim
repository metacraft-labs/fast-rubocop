
import
  configurableEnforcedStyle

cop :
  type
    ReturnNil* = ref object of Cop
    ##  This cop enforces consistency between 'return nil' and 'return'.
    ## 
    ##  Supported styles are: return, return_nil.
    ## 
    ##  @example EnforcedStyle: return (default)
    ##    # bad
    ##    def foo(arg)
    ##      return nil if arg
    ##    end
    ## 
    ##    # good
    ##    def foo(arg)
    ##      return if arg
    ##    end
    ## 
    ##  @example EnforcedStyle: return_nil
    ##    # bad
    ##    def foo(arg)
    ##      return if arg
    ##    end
    ## 
    ##    # good
    ##    def foo(arg)
    ##      return nil if arg
    ##    end
  const
    RETURNMSG = "Use `return` instead of `return nil`."
  const
    RETURNNILMSG = "Use `return nil` instead of `return`."
  nodeMatcher isReturnNode, "(return)"
  nodeMatcher isReturnNilNode, "(return nil)"
  nodeMatcher isChainedSend, "(send !nil? ...)"
  nodeMatcher isDefineMethod,
             "          (send _ {:define_method :define_singleton_method} _)\n"
  method onReturn*(self: ReturnNil; node: Node): void =
    node.eachAncestor("block", "def", "defs", proc (n: Node): void =
      if isScopedNode(n):
        break
      if isDefineMethod sendNode:
        break
      if argsNode.children.isEmpty:
        continue
      if isChainedSend sendNode:
        return
    )
    if isCorrectStyle(node):
    else:
      addOffense(node)
  
  method autocorrect*(self: ReturnNil; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var corrected = if style == "return":
        "return"
      corrector.replace(node.sourceRange, corrected))

  method message*(self: ReturnNil; _node: Node): void =
    if style == "return":
      RETURNMSG
  
  method isCorrectStyle*(self: ReturnNil; node: Node): void =
    style == "return" and isReturnNilNode node.! or
        style == "return_nil" and isReturnNode node.!

  method isScopedNode*(self: ReturnNil; node: Node): void =
    node.isDefType() or node.isDefsType() or node.isLambda

