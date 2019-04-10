
import
  trailingComma

cop :
  type
    TrailingCommaInArrayLiteral* = ref object of Cop
    ##  This cop checks for trailing comma in array literals.
    ## 
    ##  @example EnforcedStyleForMultiline: consistent_comma
    ##    # bad
    ##    a = [1, 2,]
    ## 
    ##    # good
    ##    a = [
    ##      1, 2,
    ##      3,
    ##    ]
    ## 
    ##    # good
    ##    a = [
    ##      1,
    ##      2,
    ##    ]
    ## 
    ##  @example EnforcedStyleForMultiline: comma
    ##    # bad
    ##    a = [1, 2,]
    ## 
    ##    # good
    ##    a = [
    ##      1,
    ##      2,
    ##    ]
    ## 
    ##  @example EnforcedStyleForMultiline: no_comma (default)
    ##    # bad
    ##    a = [1, 2,]
    ## 
    ##    # good
    ##    a = [
    ##      1,
    ##      2
    ##    ]
  method onArray*(self: TrailingCommaInArrayLiteral; node: Node): void =
    if node.isSquareBrackets:
    checkLiteral(node, "item of %<article>s array")

  method autocorrect*(self: TrailingCommaInArrayLiteral; range: Range): void =
    PunctuationCorrector.swapComma(range)

