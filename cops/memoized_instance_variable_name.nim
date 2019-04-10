
import
  configurableEnforcedStyle

cop :
  type
    MemoizedInstanceVariableName* = ref object of Cop
  const
    MSG = """Memoized variable `%<var>s` does not match method name `%<method>s`. Use `@%<suggested_var>s` instead."""
  const
    UNDERSCOREREQUIRED = """Memoized variable `%<var>s` does not start with `_`. Use `@%<suggested_var>s` instead."""
  nodeMatcher isMemoized, nodePattern
  method nodePattern*(self: Class): void =
    var
      memoAssign = "(or_asgn $(ivasgn _) _)"
      memoizedAtEndOfMethod = """(begin ... (lvar :memo_assign))"""
      instanceMethod = """(def $_ _ {(lvar :memo_assign) (lvar :memoized_at_end_of_method)})"""
      classMethod = """(defs self $_ _ {(lvar :memo_assign) (lvar :memoized_at_end_of_method)})"""
    """{(lvar :instance_method) (lvar :class_method)}"""

  method onDef*(self: MemoizedInstanceVariableName; node: Node): void =
    if isMatches(methodName, ivarAssign):
      return
    var msg = format(message(`$`()), var = `$`(),
                  suggestedVar = suggestedVar(methodName), method = methodName)
    addOffense(node, location = ivarAssign.sourceRange, message = msg)

  method styleParameterName*(self: MemoizedInstanceVariableName): void =
    "EnforcedStyleForLeadingUnderscores"

  method isMatches*(self: MemoizedInstanceVariableName; methodName: Symbol;
                   ivarAssign: Node): void =
    if ivarAssign.isNil() or methodName == "initialize":
      return true
    methodName = `$`().delete("!?")
    var
      variable = ivarAssign.children[0]
      variableName = `$`().sub("@", "")
    variableNameCandidates(methodName).isInclude(variableName)

  method message*(self: MemoizedInstanceVariableName; variable: string): void =
    var variableName = `$`().sub("@", "")
    if style == "required" and variableName.isStartWith("_").!:
      return UNDERSCOREREQUIRED
    MSG

  method suggestedVar*(self: MemoizedInstanceVariableName; methodName: Symbol): void =
    var suggestion = `$`().delete("!?")
    if style == "required":
      """_(lvar :suggestion)"""
  
  method variableNameCandidates*(self: MemoizedInstanceVariableName;
                                methodName: string): void =
    var
      noUnderscore = methodName.sub("")
      withUnderscore = """_(lvar :method_name)"""
    case style
    of "required":
      (withUnderscore, if methodName.isStartWith("_"):
        methodName
      ).compact
    of "disallowed":
      @[methodName, noUnderscore]
    of "optional":
      @[methodName, withUnderscore, noUnderscore]
    else:
      raise("Unreachable")
  
  privateClassMethod("node_pattern")
