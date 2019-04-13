
import
  types

import
  classishLength

cop ClassLength:
  ##  This cop checks if the length a class exceeds some maximum value.
  ##  Comment lines can optionally be ignored.
  ##  The maximum allowed length is configurable.
  nodeMatcher isClassDefinition, "(casgn nil? _ (block (send (const nil? :Class) :new) ...))"
  
  method onClass*(self; node) =
    self.checkCodeLength(node)

  method onCasgn*(self; node) =
    isClassDefinition node:
      self.checkCodeLength(node)

  method message*(self; length: int; maxLength: int): string =
    format("Class has too many lines. [%<length>d/%<max>d]", length = length,
           max = maxLength)

