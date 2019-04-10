
import
  classishLength

cop :
  type
    ClassLength* = ref object of Cop
    ##  This cop checks if the length a class exceeds some maximum value.
    ##  Comment lines can optionally be ignored.
    ##  The maximum allowed length is configurable.
  nodeMatcher isClassDefinition, "          (casgn nil? _ (block (send (const nil? :Class) :new) ...))\n"
  
  method onClass*(self: ClassLength; node: Node): void =
    checkCodeLength(node)

  method onCasgn*(self: ClassLength; node: Node): void =
    isClassDefinition node:
      checkCodeLength(node)

  method message*(self: ClassLength; length: Integer; maxLength: Integer): void =
    format("Class has too many lines. [%<length>d/%<max>d]", length = length,
           max = maxLength)

