
import
  sequtils

cop :
  type
    MultipleComparison* = ref object of Cop
    ##  This cop checks against comparing a variable with multiple items, where
    ##  `Array#include?` could be used instead to avoid code repetition.
    ## 
    ##  @example
    ##    # bad
    ##    a = 'a'
    ##    foo if a == 'a' || a == 'b' || a == 'c'
    ## 
    ##    # good
    ##    a = 'a'
    ##    foo if ['a', 'b', 'c'].include?(a)
  const
    MSG = """Avoid comparing a variable with multiple items in a conditional, use `Array#include?` instead."""
  nodeMatcher isSimpleDoubleComparison, "(send $lvar :== $lvar)"
  nodeMatcher isSimpleComparison, """          {(send $lvar :== _)
           (send _ :== $lvar)}
"""
  method onOr*(self: MultipleComparison; node: Node): void =
    var rootOfOrNode = rootOfOrNode(node)
    if node == rootOfOrNode:
    if isNestedVariableComparison(rootOfOrNode):
    addOffense(node)

  method isNestedVariableComparison*(self: MultipleComparison; node: Node): void =
    if isNestedComparison(node):
    else:
      return false
    variablesInNode(node).count() == 1

  method variablesInNode*(self: MultipleComparison; node: Node): void =
    if node.isOrType():
      node.nodeParts.flatMap(proc (nodePart: void): void =
        variablesInNode(nodePart)).uniq
    else:
      variablesInSimpleNode(node)
  
  method variablesInSimpleNode*(self: MultipleComparison; node: Node): void =
    isSimpleDoubleComparison node:
      return @[variableName(var1), variableName(var2)]
    isSimpleComparison node:
      return @[variableName(var)]
    @[]

  method variableName*(self: MultipleComparison; node: Node): void =
    node.children[0]

  method isNestedComparison*(self: MultipleComparison; node: Node): void =
    if node.isOrType():
      node.nodeParts.allIt:
        isComparison(it)
  
  method isComparison*(self: MultipleComparison; node: Node): void =
    isSimpleComparison node or isNestedComparison(node)

  method rootOfOrNode*(self: MultipleComparison; orNode: Node): void =
    if orNode.parent:
    else:
      return orNode
    if orNode.parent.isOrType():
      rootOfOrNode(orNode.parent)
  
