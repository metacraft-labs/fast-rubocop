
import
  sequtils

import
  configurableEnforcedStyle

import
  stringLiteralsHelp

cop :
  type
    StringLiterals* = ref object of Cop
    ##  Checks if uses of quotes match the configured preference.
    ## 
    ##  @example EnforcedStyle: single_quotes (default)
    ##    # bad
    ##    "No special symbols"
    ##    "No string interpolation"
    ##    "Just text"
    ## 
    ##    # good
    ##    'No special symbols'
    ##    'No string interpolation'
    ##    'Just text'
    ##    "Wait! What's #{this}!"
    ## 
    ##  @example EnforcedStyle: double_quotes
    ##    # bad
    ##    'Just some text'
    ##    'No special chars or interpolation'
    ## 
    ##    # good
    ##    "Just some text"
    ##    "No special chars or interpolation"
    ##    "Every string in #{project} uses double_quotes"
  const
    MSGINCONSISTENT = "Inconsistent quote style."
  method onDstr*(self: StringLiterals; node: Node): void =
    if isConsistentMultiline:
    if node.isHeredoc:
      return
    var children = node.children
    if isAllStringLiterals(children):
    var quoteStyles = detectQuoteStyles(node)
    if quoteStyles.size > 1:
      addOffense(node, message = MSGINCONSISTENT)
    else:
      checkMultilineQuoteStyle(node, quoteStyles[0])
    ignoreNode(node)

  method autocorrect*(self: StringLiterals; node: Node): void =
    StringLiteralCorrector.correct(node, style)

  method isAllStringLiterals*(self: StringLiterals; nodes: Array): void =
    nodes.allIt:
      it.isStrType() or it.isDstrType()

  method detectQuoteStyles*(self: StringLiterals; node: Node): void =
    var styles = node.children.mapIt:
      it.loc.begin
    if styles.allIt:
      it.isIl:
      return @[node.loc.begin.source]
    styles.mapIt:
      it.ource.uniq()

  method message*(self: StringLiterals; _node: Node): void =
    if style == "single_quotes":
      """Prefer single-quoted strings when you don't need string interpolation or special symbols."""
  
  method isOffense*(self: StringLiterals; node: Node): void =
    if isInsideInterpolation(node):
      return false
    isWrongQuotes(node)

  method isConsistentMultiline*(self: StringLiterals): void =
    copConfig["ConsistentQuotesInMultiline"]

  method checkMultilineQuoteStyle*(self: StringLiterals; node: Node; quote: string): void =
    var
      range = node.sourceRange
      children = node.children
    if isUnexpectedSingleQuotes(quote):
      var allChildrenWithQuotes = children.allIt:
        isWrongQuotes(it)
      if allChildrenWithQuotes:
        addOffense(node, location = range)
    elif isUnexpectedDoubleQuotes(quote) and
        isAcceptChildDoubleQuotes(children).!:
      addOffense(node, location = range)
  
  method isUnexpectedSingleQuotes*(self: StringLiterals; quote: string): void =
    quote == "\'" and style == "double_quotes"

  method isUnexpectedDoubleQuotes*(self: StringLiterals; quote: string): void =
    quote == "\"" and style == "single_quotes"

  method isAcceptChildDoubleQuotes*(self: StringLiterals; nodes: Array): void =
    nodes.anyIt:
      it.isDstrType() or isDoubleQuotesRequired(it.source)

