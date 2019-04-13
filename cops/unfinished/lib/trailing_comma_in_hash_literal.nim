
import
  trailingComma

cop :
  type
    TrailingCommaInHashLiteral* = ref object of Cop
    ##  This cop checks for trailing comma in hash literals.
    ## 
    ##  @example EnforcedStyleForMultiline: consistent_comma
    ##    # bad
    ##    a = { foo: 1, bar: 2, }
    ## 
    ##    # good
    ##    a = {
    ##      foo: 1, bar: 2,
    ##      qux: 3,
    ##    }
    ## 
    ##    # good
    ##    a = {
    ##      foo: 1,
    ##      bar: 2,
    ##    }
    ## 
    ##  @example EnforcedStyleForMultiline: comma
    ##    # bad
    ##    a = { foo: 1, bar: 2, }
    ## 
    ##    # good
    ##    a = {
    ##      foo: 1,
    ##      bar: 2,
    ##    }
    ## 
    ##  @example EnforcedStyleForMultiline: no_comma (default)
    ##    # bad
    ##    a = { foo: 1, bar: 2, }
    ## 
    ##    # good
    ##    a = {
    ##      foo: 1,
    ##      bar: 2
    ##    }
  method onHash*(self: TrailingCommaInHashLiteral; node: Node): void =
    checkLiteral(node, "item of %<article>s hash")

  method autocorrect*(self: TrailingCommaInHashLiteral; range: Range): void =
    PunctuationCorrector.swapComma(range)

