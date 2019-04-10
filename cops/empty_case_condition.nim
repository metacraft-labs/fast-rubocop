
import
  tables, sequtils

import
  rangeHelp

cop :
  type
    EmptyCaseCondition* = ref object of Cop
    ##  This cop checks for case statements with an empty condition.
    ## 
    ##  @example
    ## 
    ##    # bad:
    ##    case
    ##    when x == 0
    ##      puts 'x is 0'
    ##    when y == 0
    ##      puts 'y is 0'
    ##    else
    ##      puts 'neither is 0'
    ##    end
    ## 
    ##    # good:
    ##    if x == 0
    ##      puts 'x is 0'
    ##    elsif y == 0
    ##      puts 'y is 0'
    ##    else
    ##      puts 'neither is 0'
    ##    end
    ## 
    ##    # good: (the case condition node is not empty)
    ##    case n
    ##    when 0
    ##      puts 'zero'
    ##    when 1
    ##      puts 'one'
    ##    else
    ##      puts 'more'
    ##    end
  const
    MSG = """Do not use empty `case` condition, instead use an `if` expression."""
  method onCase*(self: EmptyCaseCondition; caseNode: Node): void =
    if caseNode.condition:
      return
    if caseNode.whenBranches.anyIt:
      it.eachDescendant.anyIt:
        it.isEturnType:
      return
    if
      var elseBranch = caseNode.elseBranch:
      if elseBranch.isReturnType() or
          elseBranch.eachDescendant.anyIt:
        it.isEturnType:
        return
    addOffense(caseNode, location = "keyword")

  method autocorrect*(self: EmptyCaseCondition; caseNode: Node): void =
    var whenBranches = caseNode.whenBranches
    lambda(proc (corrector: Corrector): void =
      correctCaseWhen(corrector, caseNode, whenBranches)
      correctWhenConditions(corrector, whenBranches))

  method correctCaseWhen*(self: EmptyCaseCondition; corrector: Corrector;
                         caseNode: Node; whenNodes: Array): void =
    var caseRange = caseNode.loc.keyword.join(whenNodes[0].loc.keyword)
    corrector.replace(caseRange, "if")
    keepFirstWhenComment(caseNode, whenNodes[0], corrector)
    for whenNode in whenNodes[]:
      corrector.replace(whenNode.loc.keyword, "elsif")

  method correctWhenConditions*(self: EmptyCaseCondition; corrector: Corrector;
                               whenNodes: Array): void =
    for whenNode in whenNodes:
      var conditions = whenNode.conditions
      if conditions.size > 1:
      var range = rangeBetween(conditions[0].loc.expression.beginPos,
                            conditions.last().loc.expression.endPos)
      corrector.replace(range, conditions.mapIt:
        it.ource.join(" || "))

  method keepFirstWhenComment*(self: EmptyCaseCondition; caseNode: Node;
                              firstWhenNode: Node; corrector: Corrector): void =
    var
      comment = processedSource.commentsBeforeLine(firstWhenNode.loc.keyword.line).mapIt:
        it.ext.join("\n")
      line = rangeByWholeLines(caseNode.sourceRange)
    if comment.isEmpty.! and caseNode.parent.!:
      corrector.insertBefore(line, """(lvar :comment)
""")
  
