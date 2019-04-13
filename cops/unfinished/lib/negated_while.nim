
import
  negativeConditional

cop :
  type
    NegatedWhile* = ref object of Cop
    ##  Checks for uses of while with a negated condition.
    ## 
    ##  @example
    ##    # bad
    ##    while !foo
    ##      bar
    ##    end
    ## 
    ##    # good
    ##    until foo
    ##      bar
    ##    end
    ## 
    ##    # bad
    ##    bar until !foo
    ## 
    ##    # good
    ##    bar while foo
    ##    bar while !foo && baz
  method onWhile*(self: NegatedWhile; node: Node): void =
    checkNegativeConditional(node)

  method onUntil*(self: NegatedWhile; node: Node): void =
    checkNegativeConditional(node)

  method autocorrect*(self: NegatedWhile; node: Node): void =
    ConditionCorrector.correctNegativeCondition(node)

  method message*(self: NegatedWhile; node: Node): void =
    format(MSG, inverse = node.inverseKeyword, current = node.keyword)

