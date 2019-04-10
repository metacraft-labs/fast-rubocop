
import
  trailingComma

cop :
  type
    TrailingCommaInArguments* = ref object of Cop
    ##  This cop checks for trailing comma in argument lists.
    ## 
    ##  @example EnforcedStyleForMultiline: consistent_comma
    ##    # bad
    ##    method(1, 2,)
    ## 
    ##    # good
    ##    method(1, 2)
    ## 
    ##    # good
    ##    method(
    ##      1, 2,
    ##      3,
    ##    )
    ## 
    ##    # good
    ##    method(
    ##      1,
    ##      2,
    ##    )
    ## 
    ##  @example EnforcedStyleForMultiline: comma
    ##    # bad
    ##    method(1, 2,)
    ## 
    ##    # good
    ##    method(1, 2)
    ## 
    ##    # good
    ##    method(
    ##      1,
    ##      2,
    ##    )
    ## 
    ##  @example EnforcedStyleForMultiline: no_comma (default)
    ##    # bad
    ##    method(1, 2,)
    ## 
    ##    # good
    ##    method(1, 2)
    ## 
    ##    # good
    ##    method(
    ##      1,
    ##      2
    ##    )
  method onSend*(self: TrailingCommaInArguments; node: Node): void =
    if node.isArguments and node.isParenthesized:
    check(node, node.arguments, "parameter of %<article>s method call",
          node.lastArgument.sourceRange.endPos, node.sourceRange.endPos)

  method autocorrect*(self: TrailingCommaInArguments; range: Range): void =
    PunctuationCorrector.swapComma(range)

  method isAvoidAutocorrect*(self: TrailingCommaInArguments; args: Array): void =
    args.last().isHashType() and args.last().isBraces and
        isBracesWillBeRemoved(args)

  method isBracesWillBeRemoved*(self: void; args: void): void =
    ##  Returns true if running with --auto-correct would remove the braces
    ##  of the last argument.
    var braceConfig = config.forCop("Style/BracesAroundHashParameters")
    if braceConfig.fetch("Enabled"):
    else:
      return false
    if braceConfig["AutoCorrect"] == false:
      return false
    var braceStyle = braceConfig["EnforcedStyle"]
    if braceStyle == "no_braces":
      return true
    if braceStyle == "context_dependent":
    else:
      return false
    args.isOne or args[-2].isHashType.!

