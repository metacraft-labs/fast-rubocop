
import
  sequtils

cop :
  type
    DuplicateCaseCondition* = ref object of Cop
  const
    MSG = "Duplicate `when` condition detected."
  method onCase*(self: DuplicateCaseCondition; caseNode: Node): void =
    caseNode.whenBranches.eachWithObject(@[], proc (whenNode: Node; previous: Array): void =
      whenNode.eachCondition(proc (condition: Node): void =
        if isRepeatedCondition(previous, condition):
        addOffense(condition))
      previous.add(whenNode.conditions))

  method isRepeatedCondition*(self: DuplicateCaseCondition; previous: Array;
                             condition: Node): void =
    previous.anyIt:
      it.isInclude(condition)

