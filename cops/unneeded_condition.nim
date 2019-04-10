
import
  rangeHelp

cop :
  type
    UnneededCondition* = ref object of Cop
    ##  This cop checks for unnecessary conditional expressions.
    ## 
    ##  @example
    ##    # bad
    ##    a = b ? b : c
    ## 
    ##    # good
    ##    a = b || c
    ## 
    ##  @example
    ##    # bad
    ##    if b
    ##      b
    ##    else
    ##      c
    ##    end
    ## 
    ##    # good
    ##    b || c
    ## 
    ##    # good
    ##    if b
    ##      b
    ##    elsif cond
    ##      c
    ##    end
    ## 
  const
    MSG = "Use double pipes `||` instead."
  const
    UNNEEDEDCONDITION = "This condition is not needed."
  method onIf*(self: UnneededCondition; node: Node): void =
    if node.isElsifConditional:
      return
    if isOffense(node):
    addOffense(node, location = rangeOfOffense(node))

  method autocorrect*(self: UnneededCondition; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      if node.isTernary:
        corrector.replace(rangeOfOffense(node), "||")
      elif node.isModifierForm or node.elseBranch.!:
        corrector.replace(node.sourceRange, node.ifBranch.source)
      else:
        var corrected = makeTernaryForm(node)
        corrector.replace(node.sourceRange, corrected))

  method message*(self: UnneededCondition; node: Node): void =
    if node.isModifierForm or node.elseBranch.!:
      UNNEEDEDCONDITION
  
  method rangeOfOffense*(self: UnneededCondition; node: Node): void =
    if node.isTernary:
    else:
      return "expression"
    rangeBetween(node.loc.question.beginPos, node.loc.colon.endPos)

  method isOffense*(self: UnneededCondition; node: Node): void =
    if isUseIfBranch(elseBranch):
      return false
    condition == ifBranch and node.isElsif.! and
      node.isTernary or elseBranch.isInstanceOf(Node).! or
          elseBranch.isSingleLine

  method isUseIfBranch*(self: UnneededCondition; elseBranch: NilClass): void =
    elseBranch and elseBranch.isIfType()

  method elseSource*(self: UnneededCondition; elseBranch: Node): void =
    var wrapElse = elseBranch.isBasicConditional and elseBranch.isModifierForm
    if wrapElse:
      """((send
  (lvar :else_branch) :source))"""
    else:
      elseBranch.source
  
  method makeTernaryForm*(self: UnneededCondition; node: Node): void =
    var ternaryForm = (ifBranch.source, elseSource(elseBranch)).join(" || ")
    if node.parent and node.parent.isSendType():
      """((lvar :ternary_form))"""
  
