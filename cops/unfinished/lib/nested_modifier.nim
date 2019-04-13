
import
  rangeHelp

cop :
  type
    NestedModifier* = ref object of Cop
    ##  This cop checks for nested use of if, unless, while and until in their
    ##  modifier form.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    something if a if b
    ## 
    ##    # good
    ##    something if b && a
  const
    MSG = "Avoid using nested modifiers."
  method onWhile*(self: NestedModifier; node: Node): void =
    check(node)

  method onUntil*(self: NestedModifier; node: Node): void =
    check(node)

  method onIf*(self: NestedModifier; node: Node): void =
    check(node)

  method check*(self: NestedModifier; node: Node): void =
    if isPartOfIgnoredNode(node):
      return
    if isModifier(node) and isModifier(node.parent):
    addOffense(node, location = "keyword")
    ignoreNode(node)

  method isModifier*(self: NestedModifier; node: Node): void =
    node and node.isBasicConditional and node.isModifierForm

  method autocorrect*(self: NestedModifier; node: Node): void =
    if node.isIfType() and node.parent.isIfType():
    var range = rangeBetween(node.loc.keyword.beginPos,
                          node.parent.condition.sourceRange.endPos)
    lambda(proc (corrector: Corrector): void =
      corrector.replace(range, newExpression(node.parent, node)))

  method newExpression*(self: NestedModifier; outerNode: Node; innerNode: Node): void =
    var
      operator = replacementOperator(outerNode.keyword)
      lhOperand = leftHandOperand(outerNode, operator)
      rhOperand = rightHandOperand(innerNode, outerNode.keyword)
    """(send
  (lvar :outer_node) :keyword) (lvar :lh_operand) (lvar :operator) (lvar :rh_operand)"""

  method replacementOperator*(self: NestedModifier; keyword: string): void =
    if keyword == "if".freeze:
      "&&".freeze
    else:
      "||".freeze
  
  method leftHandOperand*(self: NestedModifier; node: Node; operator: string): void =
    var expr = node.condition.source
    if node.condition.isOrType() and operator == "&&".freeze:
      expr = """((lvar :expr))"""
    expr

  method rightHandOperand*(self: NestedModifier; node: Node; leftHandKeyword: string): void =
    var expr = node.condition.source
    if isRequiresParens(node.condition):
      expr = """((lvar :expr))"""
    if leftHandKeyword == node.keyword:
    else:
      expr = """!(lvar :expr)"""
    expr

  method isRequiresParens*(self: NestedModifier; node: Node): void =
    node.isOrType() or
      COMPARISONOPERATORS.&(node.children).isEmpty.!

