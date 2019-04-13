
import
  classishLength

cop :
  type
    ModuleLength* = ref object of Cop
    ##  This cop checks if the length a module exceeds some maximum value.
    ##  Comment lines can optionally be ignored.
    ##  The maximum allowed length is configurable.
  nodeMatcher isModuleDefinition, "          (casgn nil? _ (block (send (const nil? :Module) :new) ...))\n"
  method onModule*(self: ModuleLength; node: Node): void =
    checkCodeLength(node)

  method onCasgn*(self: ModuleLength; node: Node): void =
    isModuleDefinition node:
      checkCodeLength(node)

  method message*(self: ModuleLength; length: Integer; maxLength: Integer): void =
    format("Module has too many lines. [%<length>d/%<max>d]", length = length,
           max = maxLength)

