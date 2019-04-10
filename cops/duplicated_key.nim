
import
  tables, sequtils

import
  duplication

cop :
  type
    DuplicatedKey* = ref object of Cop
  const
    MSG = "Duplicated key in hash literal."
  method onHash*(self: DuplicatedKey; node: Node): void =
    var keys = node.keys.filterIt:
      it.isEcursiveBasicLiteral
    if isDuplicates(keys):
    for key in consecutiveDuplicates(keys):
      addOffense(key)

