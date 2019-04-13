
import
  sequtils

cop :
  type
    LiteralAsCondition* = ref object of Cop
  const
    MSG = "Literal `%<literal>s` appeared as a condition."
  method onIf*(self: LiteralAsCondition; node: Node): void =
    checkForLiteral(node)

  method onWhile*(self: LiteralAsCondition; node: Node): void =
    checkForLiteral(node)

  method onWhilePost*(self: LiteralAsCondition; node: Node): void =
    checkForLiteral(node)

  method onUntil*(self: LiteralAsCondition; node: Node): void =
    checkForLiteral(node)

  method onUntilPost*(self: LiteralAsCondition; node: Node): void =
    checkForLiteral(node)

  method onCase*(self: LiteralAsCondition; caseNode: Node): void =
    if caseNode.condition:
      checkCase(caseNode)
    else:
      caseNode.eachWhen(proc (whenNode: Node): void =
        if whenNode.conditions.allIt:
          it.isIteral:
        addOffense(whenNode))
  
  method onSend*(self: LiteralAsCondition; node: Node): void =
    if node.isNegationMethod:
    checkForLiteral(node)

  method message*(self: LiteralAsCondition; node: Node): void =
    format(MSG, literal = node.source)

  method checkForLiteral*(self: LiteralAsCondition; node: Node): void =
    var cond = condition(node)
    if cond.isLiteral:
      addOffense(cond)
    else:
      checkNode(cond)
  
  method isBasicLiteral*(self: LiteralAsCondition; node: Node): void =
    if node.isArrayType():
      isPrimitiveArray(node)
    else:
      node.isBasicLiteral
  
  method isPrimitiveArray*(self: LiteralAsCondition; node: Node): void =
    node.children.allIt:
      isBasicLiteral(it)

  method checkNode*(self: LiteralAsCondition; node: Node): void =
    if node.isSendType() and node.isPrefixBang:
      handleNode(node.receiver)
    elif node.isOperatorKeyword:
      node.eachChildNode(proc (op: Node): void =
        handleNode(op))
    elif node.isBeginType() and node.children.isOne():
      handleNode(node.children[0])
  
  method handleNode*(self: LiteralAsCondition; node: Node): void =
    if node.isLiteral:
      addOffense(node)
    elif @["send", "and", "or", "begin"].isInclude(node.type):
      checkNode(node)
  
  method checkCase*(self: LiteralAsCondition; caseNode: Node): void =
    var condition = caseNode.condition
    if condition.isArrayType() and isPrimitiveArray(condition).!:
      return
    if condition.isDstrType():
      return
    handleNode(condition)

  method condition*(self: LiteralAsCondition; node: Node): void =
    if node.isSendType():
      node.receiver
    else:
      node.condition
  
