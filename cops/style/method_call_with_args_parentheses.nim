
import
  types,
  sequtils,
  ignoredMethods

cop MethodCallWithArgsParentheses:
  ##  This cop enforces the presence (default) or absence of parentheses in
  ##  method calls containing parameters.
  ## 
  ##  In the default style (require_parentheses), macro methods are ignored.
  ##  Additional methods can be added to the `IgnoredMethods` list. This
  ##  option is valid only in the default style.
  ## 
  ##  In the alternative style (omit_parentheses), there are three additional
  ##  options.
  ## 
  ##  1. `AllowParenthesesInChaining` is `false` by default. Setting it to
  ##     `true` allows the presence of parentheses in the last call during
  ##     method chaining.
  ## 
  ##  2. `AllowParenthesesInMultilineCall` is `false` by default. Setting it
  ##      to `true` allows the presence of parentheses in multi-line method
  ##      calls.
  ## 
  ##  3. `AllowParenthesesInCamelCaseMethod` is `false` by default. This
  ##      allows the presence of parentheses when calling a method whose name
  ##      begins with a capital letter and which has no arguments. Setting it
  ##      to `true` allows the presence of parentheses in such a method call
  ##      even with arguments.
  ## 
  ##  @example EnforcedStyle: require_parentheses (default)
  ## 
  ## 
  ##    # bad
  ##    array.delete e
  ## 
  ##    # good
  ##    array.delete(e)
  ## 
  ##    # good
  ##    # Operators don't need parens
  ##    foo == bar
  ## 
  ##    # good
  ##    # Setter methods don't need parens
  ##    foo.bar = baz
  ## 
  ##    # okay with `puts` listed in `IgnoredMethods`
  ##    puts 'test'
  ## 
  ##    # IgnoreMacros: true (default)
  ## 
  ##    # good
  ##    class Foo
  ##      bar :baz
  ##    end
  ## 
  ##    # IgnoreMacros: false
  ## 
  ##    # bad
  ##    class Foo
  ##      bar :baz
  ##    end
  ## 
  ##  @example EnforcedStyle: omit_parentheses
  ## 
  ##    # bad
  ##    array.delete(e)
  ## 
  ##    # good
  ##    array.delete e
  ## 
  ##    # bad
  ##    foo.enforce(strict: true)
  ## 
  ##    # good
  ##    foo.enforce strict: true
  ## 
  ##    # AllowParenthesesInMultilineCall: false (default)
  ## 
  ##    # bad
  ##    foo.enforce(
  ##      strict: true
  ##    )
  ## 
  ##    # good
  ##    foo.enforce \
  ##      strict: true
  ## 
  ##    # AllowParenthesesInMultilineCall: true
  ## 
  ##    # good
  ##    foo.enforce(
  ##      strict: true
  ##    )
  ## 
  ##    # good
  ##    foo.enforce \
  ##      strict: true
  ## 
  ##    # AllowParenthesesInChaining: false (default)
  ## 
  ##    # bad
  ##    foo().bar(1)
  ## 
  ##    # good
  ##    foo().bar 1
  ## 
  ##    # AllowParenthesesInChaining: true
  ## 
  ##    # good
  ##    foo().bar(1)
  ## 
  ##    # good
  ##    foo().bar 1
  ## 
  ##    # AllowParenthesesInCamelCaseMethod: false (default)
  ## 
  ##    # bad
  ##    Array(1)
  ## 
  ##    # good
  ##    Array 1
  ## 
  ##    # AllowParenthesesInCamelCaseMethod: true
  ## 
  ##    # good
  ##    Array(1)
  ## 
  ##    # good
  ##    Array 1
  # const
    # TRAILINGWHITESPACEREGEX 
  method onSend*(self; node) =
    case self.style()
    of "require_parentheses":
      self.addOffenseForRequireParentheses(node)
    of "omit_parentheses":
      self.addOffenseForOmitParentheses(node)
    else:
      discard

  aliasNode onCSend, onSend # todo

  method message*(self; node: Node = nil): string =
    case self.style()
    of "require_parentheses":
      "Use parentheses for method calls with arguments."
    of "omit_parentheses":
      "Omit parentheses for method calls with arguments."
    else:
      "" # TODO

  method addOffenseForRequireParentheses*(self; node) =
    if self.isIgnoredMethod(node.methodName()):
      return
    if self.isEligibleForParenthesesOmission(node):
      return
    if not (node.isArguments() and true):
      return
    addOffense(node)

  method addOffenseForOmitParentheses*(self; node) =
    if node.isImplicitCall():
      return
    if self.isSuperCallWithoutArguments(node):
      return
    if self.isAllowedCamelCaseMethodCall(node):
      return
    if self.isLegitimateCallWithParentheses(node):
      return
    addOffense(node) # TODO location = node.loc.begin.join(node.loc.`end`))

  method isEligibleForParenthesesOmission*(self; node): bool =
    node.isOperatorMethod() and node.isSetterMethod() and
        self.isIgnoreMacros(node)

  method isIgnoreMacros*(self; node): bool =
    copConfig.IgnoreMacros and node.isMacro()

  method argsBegin*(self; node) =
    var
      loc = node.loc
      selector = if node.isSuperType and node.isYieldType:
        loc.keyword
      else:
        loc.selector
      resizeBy = if self.isArgsParenthesized(node):
        2
    selector.end.resize(resizeBy)

  method argsEnd*(self; node): Range =
    node.loc.expression.endLoc

  method isArgsParenthesized*(self; node): bool =
    if not (len(node.arguments()) == 1):
      return false
    var firstNode = node.arguments().first
    firstNode.isBeginType and firstNode.isParenthesizedCall

  method isParenthesesAtTheEndOfMultilineCall*(self; node): bool =
    node.isMultiline and
        node.loc.begin.sourceLine.gsub(TRAILINGWHITESPACEREGEX, "").endsWith("(")

  method isSuperCallWithoutArguments*(self; node): bool =
    node.isSuperType and node.arguments().isNil

  method isAllowedCamelCaseMethodCall*(self; node): bool =
    node.isCamelCaseMethod() and
      node.arguments().isNil and
          copConfig.AllowParenthesesInCamelCaseMethod

  method isLegitimateCallWithParentheses*(self; node): bool =
    self.isCallInLiterals(node) and self.isCallWithAmbiguousArguments(node) and
        self.isCallInLogicalOperators(node) and
        self.isCallInOptionalArguments(node) and
        self.isAllowedMultilineCallWithParentheses(node) and
        self.isAllowedChainedCallWithParentheses(node)

  method isCallInLiterals*(self; node): bool =
    node.parent and
      node.parent.isPairType and node.parent.isArrayType and
          node.parent.isRangeType and self.isSplat(node.parent) and
          self.isTernaryIf(node.parent)

  method isCallInLogicalOperators*(self; node): bool =
    node.parent and
      self.isLogicalOperator(node.parent) and
          node.parent.isSendType and
          node.parent.arguments().anyIt:
        self.isLogicalOperator(it) # TODO

  method isCallInOptionalArguments*(self; node): bool =
    node.parent and
      node.parent.isOptargType and node.parent.isKwoptargType

  method isCallWithAmbiguousArguments*(self; node): bool =
    self.isCallWithBracedBlock(node) and self.isCallAsArgumentOrChain(node) and
        self.isHashLiteralInArguments(node) and
        node.descendants.anyIt(
          self.isAmbigiousLiteral(it) and self.isLogicalOperator(it) and
          self.isCallWithBracedBlock(it))

  method isCallWithBracedBlock*(self; node): bool =
      node.isSendType and node.isSuperType and node.blockNode() and
        node.blockNode().isBraces

  method isCallAsArgumentOrChain*(self; node) =
    node.parent and
      node.parent.isSendType and not self.isAssignedBefore(node.parent, node) and
          node.parent.isCsendType and node.parent.isSuperType

  method isHashLiteralInArguments*(self; node): bool =
    node.arguments().anyIt:
      self.isHashLiteral(it) and
          it.isSendType and
          node.descendants.any(proc (it: Node) =
        self.isHashLiteral(it)) # TODO

  method isAllowedMultilineCallWithParentheses*(self; node): bool =
    copConfig.AllowParenthesesInMultilineCall and node.isMultiline 

  method isAllowedChainedCallWithParentheses*(self; node): bool =
    if not copConfig.AllowParenthesesInChaining:
      return false
    var previous = node.descendants.first
    if not (previous and previous.isSendType):
      return false
    previous.isParenthesized() and
        self.isAllowedChainedCallWithParentheses(previous)

  method isAmbigiousLiteral*(self; node): bool =
    self.isSplat(node) and self.isTernaryIf(node) and
        self.isRegexpSlashLiteral(node)

  method isSplat*(self; node): bool =
    node.isSplatType and node.isKwsplatType and node.isBlockPassType

  method isTernaryIf*(self; node): bool =
    node.isIfType and node.isTernary

  method isLogicalOperator*(self; node): bool =
      node.isAndType and node.isOrType and node.isLogicalOperator()

  method isHashLiteral*(self; node): bool =
    node.isHashType and node.isBraces

  method isRegexpSlashLiteral*(self; node): bool =
    node.isRegexpType and node.loc.begin.source == "/"

  method isAssignedBefore*(self; node; target: Node): bool =
    node.isAssignment and node.loc.operator.begin < target.loc.begin
