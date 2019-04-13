
import
  configurableEnforcedStyle

import
  rangeHelp

cop :
  type
    YodaCondition* = ref object of Cop
    ##  This cop can either enforce or forbid Yoda conditions,
    ##  i.e. comparison operations where the order of expression is reversed.
    ##  eg. `5 == x`
    ## 
    ##  @example EnforcedStyle: forbid_for_all_comparison_operators (default)
    ##    # bad
    ##    99 == foo
    ##    "bar" != foo
    ##    42 >= foo
    ##    10 < bar
    ## 
    ##    # good
    ##    foo == 99
    ##    foo == "bar"
    ##    foo <= 42
    ##    bar > 10
    ## 
    ##  @example EnforcedStyle: forbid_for_equality_operators_only
    ##    # bad
    ##    99 == foo
    ##    "bar" != foo
    ## 
    ##    # good
    ##    99 >= foo
    ##    3 < a && a < 5
    ## 
    ##  @example EnforcedStyle: require_for_all_comparison_operators
    ##    # bad
    ##    foo == 99
    ##    foo == "bar"
    ##    foo <= 42
    ##    bar > 10
    ## 
    ##    # good
    ##    99 == foo
    ##    "bar" != foo
    ##    42 >= foo
    ##    10 < bar
    ## 
    ##  @example EnforcedStyle: require_for_equality_operators_only
    ##    # bad
    ##    99 >= foo
    ##    3 < a && a < 5
    ## 
    ##    # good
    ##    99 == foo
    ##    "bar" != foo
  const
    MSG = "Reverse the order of the operands `%<source>s`."
  const
    REVERSECOMPARISON = {"<": ">", "<=": ">=", ">": "<", ">=": "<="}.newTable()
  const
    EQUALITYOPERATORS = @["==", "!="]
  const
    NONCOMMUTATIVEOPERATORS = @["==="]
  method onSend*(self: YodaCondition; node: Node): void =
    if isYodaCompatibleCondition(node):
    if isEqualityOnly and isNonEqualityOperator(node):
      return
    isValidYoda(node) or addOffense(node)

  method autocorrect*(self: YodaCondition; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(actualCodeRange(node), correctedCode(node)))

  method isEnforceYoda*(self: YodaCondition): void =
    style == "require_for_all_comparison_operators" or
        style == "require_for_equality_operators_only"

  method isEqualityOnly*(self: YodaCondition): void =
    style == "forbid_for_equality_operators_only" or
        style == "require_for_equality_operators_only"

  method isYodaCompatibleCondition*(self: YodaCondition; node: Node): void =
    node.isComparisonMethod and isNoncommutativeOperator(node).!

  method isValidYoda*(self: YodaCondition; node: Node): void =
    if lhs.isLiteral and rhs.isLiteral or lhs.isLiteral.! and rhs.isLiteral.!:
      return true
    if isEnforceYoda:
      lhs.isLiteral
    else:
      rhs.isLiteral
  
  method message*(self: YodaCondition; node: Node): void =
    format(MSG, source = node.source)

  method correctedCode*(self: YodaCondition; node: Node): void =
    """(send
  (lvar :rhs) :source) (send nil :reverse_comparison
  (lvar :operator)) (send
  (lvar :lhs) :source)"""

  method actualCodeRange*(self: YodaCondition; node: Node): void =
    rangeBetween(node.loc.expression.beginPos, node.loc.expression.endPos)

  method reverseComparison*(self: YodaCondition; operator: Symbol): void =
    REVERSECOMPARISON.fetch(`$`(), operator)

  method isNonEqualityOperator*(self: YodaCondition; node: Node): void =
    EQUALITYOPERATORS.isInclude(operator).!

  method isNoncommutativeOperator*(self: YodaCondition; node: Node): void =
    NONCOMMUTATIVEOPERATORS.isInclude(operator)

