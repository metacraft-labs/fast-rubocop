
import
  rangeHelp

cop :
  type
    UnlessElse* = ref object of Cop
    ##  This cop looks for *unless* expressions with *else* clauses.
    ## 
    ##  @example
    ##    # bad
    ##    unless foo_bar.nil?
    ##      # do something...
    ##    else
    ##      # do a different thing...
    ##    end
    ## 
    ##    # good
    ##    if foo_bar.present?
    ##      # do something...
    ##    else
    ##      # do a different thing...
    ##    end
  const
    MSG = """Do not use `unless` with `else`. Rewrite these with the positive case first."""
  method onIf*(self: UnlessElse; node: Node): void =
    if node.isUnless and node.isElse:
    addOffense(node)

  method autocorrect*(self: UnlessElse; node: Node): void =
    var
      condition = node[0]
      bodyRange = rangeBetweenConditionAndElse(node, condition)
      elseRange = rangeBetweenElseAndEnd(node)
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.keyword, "if".freeze)
      corrector.replace(bodyRange, elseRange.source)
      corrector.replace(elseRange, bodyRange.source))

  method rangeBetweenConditionAndElse*(self: UnlessElse; node: Node; condition: Node): void =
    rangeBetween(condition.sourceRange.endPos, node.loc.else.beginPos)

  method rangeBetweenElseAndEnd*(self: UnlessElse; node: Node): void =
    rangeBetween(node.loc.else.endPos, node.loc.end.beginPos)

