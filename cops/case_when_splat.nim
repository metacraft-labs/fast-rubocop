
import
  sequtils

import
  alignment

import
  rangeHelp

cop :
  type
    CaseWhenSplat* = ref object of Cop
  const
    MSG = """Reordering `when` conditions with a splat to the end of the `when` branches can improve performance."""
  const
    ARRAYMSG = """Pass the contents of array literals directly to `when` conditions."""
  method onCase*(self: CaseWhenSplat; caseNode: Node): void =
    var whenConditions = caseNode.whenBranches.flatMap(proc (it: void): void =
      it.onditions)
    splatOffenses(whenConditions).reverseEach(proc (condition: Node): void =
      var
        range = condition.parent.loc.keyword.join(condition.sourceRange)
        variable = condition[0]
        message = if variable.isArrayType():
          ARRAYMSG
      addOffense(condition.parent, location = range, message = message))

  method autocorrect*(self: CaseWhenSplat; whenNode: Node): void =
    lambda(proc (corrector: Corrector): void =
      if isNeedsReorder(whenNode):
        reorderCondition(corrector, whenNode)
      else:
        inlineFixBranch(corrector, whenNode)
    )

  method replacement*(self: CaseWhenSplat; conditions: Array): void =
    var reordered = conditions.partition(proc (it: void): void =
      it.isPlatType).reverse()
    reordered.flatten().mapIt:
      it.ource.join(", ")

  method inlineFixBranch*(self: CaseWhenSplat; corrector: Corrector; whenNode: Node): void =
    var
      conditions = whenNode.conditions
      range = rangeBetween(conditions[0].loc.expression.beginPos,
                         conditions[-1].loc.expression.endPos)
    corrector.replace(range, replacement(conditions))

  method reorderCondition*(self: CaseWhenSplat; corrector: Corrector; whenNode: Node): void =
    var whenBranches = whenNode.parent.whenBranches
    if whenBranches.isOne():
      return
    corrector.remove(whenBranchRange(whenNode))
    corrector.insertAfter(whenBranches.last().sourceRange,
                          reorderingCorrection(whenNode))

  method reorderingCorrection*(self: CaseWhenSplat; whenNode: Node): void =
    var newCondition = replacement(whenNode.conditions)
    if isSameLine(whenNode, whenNode.body):
      newConditionWithThen(whenNode, newCondition)
    else:
      newBranchWithoutThen(whenNode, newCondition)
  
  method whenBranchRange*(self: CaseWhenSplat; whenNode: Node): void =
    var nextBranch = whenNode.parent.whenBranches[whenNode.branchIndex & 1]
    rangeBetween(whenNode.sourceRange.beginPos, nextBranch.sourceRange.beginPos)

  method newConditionWithThen*(self: CaseWhenSplat; node: Node; newCondition: string): void =
    """(str "\n")(begin
  (lvar :new_condition))"""

  method newBranchWithoutThen*(self: CaseWhenSplat; node: Node; newCondition: string): void =
    """(str "\n")(str "\n")"""

  method indentFor*(self: CaseWhenSplat; node: Node): void =
    " " * node.loc.column

  method splatOffenses*(self: CaseWhenSplat; whenConditions: Array): void =
    var
      foundNonSplat = false
      offenses = whenConditions.reverse().mapIt:
        foundNonSplat or= isNonSplat(it)
        if isNonSplat(it):
          continue
        if foundNonSplat:
          it
    offenses.compact()

  method isNonSplat*(self: CaseWhenSplat; condition: Node): void =
    var variable = condition[0]
      condition.isSplatType() and variable.isArrayType() or
        condition.isSplatType().!

  method isNeedsReorder*(self: CaseWhenSplat; whenNode: Node): void =
    var followingBranches = whenNode.parent.whenBranches[]
    followingBranches.anyIt:
      it.conditions.anyIt:
        isNonSplat(it)

