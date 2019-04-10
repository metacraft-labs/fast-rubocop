
import
  alignment

cop :
  type
    RedundantConditional* = ref object of Cop
    ##  This cop checks for redundant returning of true/false in conditionals.
    ## 
    ##  @example
    ##    # bad
    ##    x == y ? true : false
    ## 
    ##    # bad
    ##    if x == y
    ##      true
    ##    else
    ##      false
    ##    end
    ## 
    ##    # good
    ##    x == y
    ## 
    ##    # bad
    ##    x == y ? false : true
    ## 
    ##    # good
    ##    x != y
  const
    COMPARISONOPERATORS = COMPARISONOPERATORS
  const
    MSG = """This conditional expression can just be replaced by `%<msg>s`."""
  nodeMatcher isRedundantCondition, """          (if (send _ {:(send
  (const nil :COMPARISON_OPERATORS) :join
  (str " :"))} _) true false)
"""
  nodeMatcher isRedundantConditionInverted, """          (if (send _ {:(send
  (const nil :COMPARISON_OPERATORS) :join
  (str " :"))} _) false true)
"""
  method onIf*(self: RedundantConditional; node: Node): void =
    if isOffense(node):
    addOffense(node)

  method autocorrect*(self: RedundantConditional; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.expression, replacementCondition(node)))

  method message*(self: RedundantConditional; node: Node): void =
    var
      replacement = replacementCondition(node)
      msg = if node.isElsif:
        """
(lvar :replacement)"""
    format(MSG, msg = msg)

  method isOffense*(self: RedundantConditional; node: Node): void =
    if node.isModifierForm:
      return
    isRedundantCondition node or isRedundantConditionInverted node

  method replacementCondition*(self: RedundantConditional; node: Node): void =
    var
      condition = node.condition.source
      expression = if isInvertExpression(node):
        """!((lvar :condition))"""
    if node.isElsif:
      indentedElseNode(expression, node)
  
  method isInvertExpression*(self: RedundantConditional; node: Node): void =
        node.isIf or node.isElsif or node.isTernary and
          isRedundantConditionInverted node or
      node.isUnless and isRedundantCondition node

  method indentedElseNode*(self: RedundantConditional; expression: string; node: Node): void =
    """else
(send nil :indentation
  (lvar :node))(lvar :expression)"""

  method configuredIndentationWidth*(self: RedundantConditional): void =
    super or 2

