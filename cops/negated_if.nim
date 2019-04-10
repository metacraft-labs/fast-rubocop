
import
  configurableEnforcedStyle

import
  negativeConditional

cop :
  type
    NegatedIf* = ref object of Cop
    ##  Checks for uses of if with a negated condition. Only ifs
    ##  without else are considered. There are three different styles:
    ## 
    ##    - both
    ##    - prefix
    ##    - postfix
    ## 
    ##  @example EnforcedStyle: both (default)
    ##    # enforces `unless` for `prefix` and `postfix` conditionals
    ## 
    ##    # bad
    ## 
    ##    if !foo
    ##      bar
    ##    end
    ## 
    ##    # good
    ## 
    ##    unless foo
    ##      bar
    ##    end
    ## 
    ##    # bad
    ## 
    ##    bar if !foo
    ## 
    ##    # good
    ## 
    ##    bar unless foo
    ## 
    ##  @example EnforcedStyle: prefix
    ##    # enforces `unless` for just `prefix` conditionals
    ## 
    ##    # bad
    ## 
    ##    if !foo
    ##      bar
    ##    end
    ## 
    ##    # good
    ## 
    ##    unless foo
    ##      bar
    ##    end
    ## 
    ##    # good
    ## 
    ##    bar if !foo
    ## 
    ##  @example EnforcedStyle: postfix
    ##    # enforces `unless` for just `postfix` conditionals
    ## 
    ##    # bad
    ## 
    ##    bar if !foo
    ## 
    ##    # good
    ## 
    ##    bar unless foo
    ## 
    ##    # good
    ## 
    ##    if !foo
    ##      bar
    ##    end
  method onIf*(self: NegatedIf; node: Node): void =
    if node.isElsif or node.isTernary:
      return
    if isCorrectStyle(node):
      return
    checkNegativeConditional(node)

  method autocorrect*(self: NegatedIf; node: Node): void =
    ConditionCorrector.correctNegativeCondition(node)

  method message*(self: NegatedIf; node: Node): void =
    format(MSG, inverse = node.inverseKeyword, current = node.keyword)

  method isCorrectStyle*(self: NegatedIf; node: Node): void =
    style == "prefix" and node.isModifierForm or
        style == "postfix" and node.isModifierForm.!

