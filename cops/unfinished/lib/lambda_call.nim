
import
  configurableEnforcedStyle

cop :
  type
    LambdaCall* = ref object
    ##  This cop checks for use of the lambda.(args) syntax.
    ## 
    ##  @example EnforcedStyle: call (default)
    ##   # bad
    ##   lambda.(x, y)
    ## 
    ##   # good
    ##   lambda.call(x, y)
    ## 
    ##  @example EnforcedStyle: braces
    ##   # bad
    ##   lambda.call(x, y)
    ## 
    ##   # good
    ##   lambda.(x, y)
  method onSend*(self: void; node: void): void =
    if node.receiver and node.isMethod("call"):
    if isOffense(node):
      addOffense(node, proc (): void =
        oppositeStyleDetected)
  
  method autocorrect*(self: void; node: void): void =
    lambda(proc (corrector: void): void =
      if isExplicitStyle:
        var
          receiver = node.receiver.source
          replacement = node.source.sub("""(lvar :receiver).""",
                                      """(lvar :receiver).call""")
        corrector.replace(node.sourceRange, replacement)
      else:
        if node.isParenthesized:
        else:
          addParentheses(node, corrector)
        corrector.remove(node.loc.selector))

  method isOffense*(self: void; node: void): void =
    isExplicitStyle and node.isImplicitCall or
        isImplicitStyle and node.isImplicitCall.!

  method addParentheses*(self: void; node: void; corrector: void): void =
    if node.arguments.isEmpty:
      corrector.insertAfter(node.sourceRange, "()")
    else:
      corrector.replace(argsBegin(node), "(")
      corrector.insertAfter(argsEnd(node), ")")

  method argsBegin*(self: void; node: void): void =
    var
      loc = node.loc
      selector = if node.isSuperType or node.isYieldType:
        loc.keyword
      else:
        loc.selector
    selector.end.resize(1)

  method argsEnd*(self: void; node: void): void =
    node.loc.expression.end

  method message*(self: void; _node: void): void =
    if isExplicitStyle:
      "Prefer the use of `lambda.call(...)` over `lambda.(...)`."
  
  method isImplicitStyle*(self: void): void =
    style == "braces"

  method isExplicitStyle*(self: void): void =
    style == "call"

