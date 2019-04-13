
import
  tables, sequtils

import
  rangeHelp

cop :
  type
    RedundantReturn* = ref object of Cop
    ##  This cop checks for redundant `return` expressions.
    ## 
    ##  @example
    ##    # These bad cases should be extended to handle methods whose body is
    ##    # if/else or a case expression with a default branch.
    ## 
    ##    # bad
    ##    def test
    ##      return something
    ##    end
    ## 
    ##    # bad
    ##    def test
    ##      one
    ##      two
    ##      three
    ##      return something
    ##    end
    ## 
    ##    # good
    ##    def test
    ##      return something if something_else
    ##    end
    ## 
    ##    # good
    ##    def test
    ##      if x
    ##      elsif y
    ##      else
    ##      end
    ##    end
    ## 
  const
    MSG = "Redundant `return` detected."
  const
    MULTIRETURNMSG = "To return multiple values, use an array."
  method onDef*(self: RedundantReturn; node: Node): void =
    if node.body:
    checkBranch(node.body)

  method autocorrect*(self: RedundantReturn; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      if isArguments(node.children):
      else:
        corrector.replace(node.sourceRange, "nil")
        continue
      var returnValue = node[0]
      if node.children.size > 1:
        addBrackets(corrector, node)
      elif returnValue.isHashType():
        if returnValue.isBraces:
        else:
          addBraces(corrector, returnValue)
      var returnKw = rangeWithSurroundingSpace(range = node.loc.keyword,
          side = "right")
      corrector.remove(returnKw))

  method addBrackets*(self: RedundantReturn; corrector: Corrector; node: Node): void =
    var kids = node.children.mapIt:
      it.ourceRange
    corrector.insertBefore(kids[0], "[")
    corrector.insertAfter(kids.last(), "]")

  method addBraces*(self: RedundantReturn; corrector: Corrector; node: Node): void =
    var kids = node.children.mapIt:
      it.ourceRange
    corrector.insertBefore(kids[0], "{")
    corrector.insertAfter(kids.last(), "}")

  method isArguments*(self: RedundantReturn; args: Array): void =
    if args.isEmpty:
      return false
    if args.size > 1:
      return true
    args[0].isBeginType().! or args[0].children.isEmpty.!

  method checkBranch*(self: RedundantReturn; node: Node): void =
    ##  rubocop:disable Metrics/CyclomaticComplexity
    case node.type
    of "return":
      checkReturnNode(node)
    of "case":
      checkCaseNode(node)
    of "if":
      checkIfNode(node)
    of "rescue":
      "resbody"
    of "ensure":
      checkEnsureNode(node)
    of "begin":
      "kwbegin"
    else:

  method checkReturnNode*(self: RedundantReturn; node: Node): void =
    if copConfig["AllowMultipleReturnValues"] and node.children.size > 1:
      return
    addOffense(node, location = "keyword")

  method checkCaseNode*(self: RedundantReturn; node: Node): void =
    for whenNode in whenNodes:
      checkWhenNode(whenNode)
    if elseNode:
      checkBranch(elseNode)
  
  method checkWhenNode*(self: RedundantReturn; node: Node): void =
    if node:
    if body:
      checkBranch(body)
  
  method checkIfNode*(self: RedundantReturn; node: Node): void =
    if node.isModifierForm or node.isTernary:
      return
    if ifNode:
      checkBranch(ifNode)
    if elseNode:
      checkBranch(elseNode)
  
  method checkRescueNode*(self: RedundantReturn; node: Node): void =
    for childNode in node.childNodes:
      checkBranch(childNode)

  method checkEnsureNode*(self: RedundantReturn; node: Node): void =
    var rescueNode = node.nodeParts[0]
    checkBranch(rescueNode)

  method checkBeginNode*(self: RedundantReturn; node: Node): void =
    var
      expressions = @[]
      lastExpr = expressions.last()
    if lastExpr and lastExpr.isReturnType():
    checkReturnNode(lastExpr)

  method isAllowMultipleReturnValues*(self: RedundantReturn): void =
    copConfig["AllowMultipleReturnValues"] or false

  method message*(self: RedundantReturn; node: Node): void =
    if isAllowMultipleReturnValues.! and node.children.size > 1:
      """(const nil :MSG) (const nil :MULTI_RETURN_MSG)"""
  
