
import
  tables

cop :
  type
    PredicateName* = ref object of Cop
    ##  This cop makes sure that predicates are named properly.
    ## 
    ##  @example
    ##    # bad
    ##    def is_even?(value)
    ##    end
    ## 
    ##    # good
    ##    def even?(value)
    ##    end
    ## 
    ##    # bad
    ##    def has_value?
    ##    end
    ## 
    ##    # good
    ##    def value?
    ##    end
  nodeMatcher dynamicMethodDefine, """          (send nil? #method_definition_macros
            (sym $_)
            ...)
"""
  method onSend*(self: PredicateName; node: Node): void =
    dynamicMethodDefine node:
      for prefix in predicatePrefixes:
        if isAllowedMethodName(`$`(), prefix):
          continue
        addOffense(node, location = node.firstArgument.loc.expression,
                   message = message(methodName, expectedName(`$`(), prefix)))

  method onDef*(self: PredicateName; node: Node): void =
    for prefix in predicatePrefixes:
      var methodName = `$`()
      if isAllowedMethodName(methodName, prefix):
        continue
      addOffense(node, location = "name", message = message(methodName,
          expectedName(methodName, prefix)))

  method isAllowedMethodName*(self: PredicateName; methodName: string; prefix: string): void =
    methodName.match().! or methodName == expectedName(methodName, prefix) or
        methodName.isEndWith("=") or predicateWhitelist.isInclude(methodName)

  method expectedName*(self: PredicateName; methodName: string; prefix: string): void =
    var newName = if prefixBlacklist.isInclude(prefix):
      methodName.sub(prefix, "")
    else:
      methodName.dup()
    if methodName.isEndWith("?"):
    else:
      newName.<<("?")
    newName

  method message*(self: PredicateName; methodName: string; newName: string): void =
    """Rename `(lvar :method_name)` to `(lvar :new_name)`."""

  method prefixBlacklist*(self: PredicateName): void =
    copConfig["NamePrefixBlacklist"]

  method predicatePrefixes*(self: PredicateName): void =
    copConfig["NamePrefix"]

  method predicateWhitelist*(self: PredicateName): void =
    copConfig["NameWhitelist"]

  method methodDefinitionMacros*(self: PredicateName; macroName: Symbol): void =
    copConfig["MethodDefinitionMacros"].isInclude(`$`())

