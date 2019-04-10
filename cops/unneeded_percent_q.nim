
import
  sequtils

cop :
  type
    UnneededPercentQ* = ref object of Cop
    ##  This cop checks for usage of the %q/%Q syntax when '' or "" would do.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    name = %q(Bruce Wayne)
    ##    time = %q(8 o'clock)
    ##    question = %q("What did you say?")
    ## 
    ##    # good
    ##    name = 'Bruce Wayne'
    ##    time = "8 o'clock"
    ##    question = '"What did you say?"'
    ## 
  const
    MSG = """Use `%<q_type>s` only for strings that contain both single quotes and double quotes%<extra>s."""
  const
    DYNAMICMSG = """, or for dynamic strings that contain double quotes"""
  const
    SINGLEQUOTE = "\'"
  const
    QUOTE = "\""
  const
    EMPTY = ""
  const
    PERCENTQ = "%q"
  const
    PERCENTCAPITALQ = "%Q"
  const
    STRINGINTERPOLATIONREGEXP
  const
    ESCAPEDNONBACKSLASH
  method onDstr*(self: UnneededPercentQ; node: Node): void =
    if isStringLiteral(node):
    check(node)

  method onStr*(self: UnneededPercentQ; node: Node): void =
    if isStringLiteral(node):
    check(node)

  method autocorrect*(self: UnneededPercentQ; node: Node): void =
    var delimiter = if node.source.=~():
      QUOTE
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.begin, delimiter)
      corrector.replace(node.loc.end, delimiter))

  method check*(self: UnneededPercentQ; node: Node): void =
    if isStartWithPercentQVariant(node):
    if isInterpolatedQuotes(node) or isAllowedPercentQ(node):
      return
    addOffense(node)

  method isInterpolatedQuotes*(self: UnneededPercentQ; node: Node): void =
    node.source.isInclude(SINGLEQUOTE) and node.source.isInclude(QUOTE)

  method isAllowedPercentQ*(self: UnneededPercentQ; node: Node): void =
    node.source.isStartWith(PERCENTQ) and isAcceptableQ(node) or
        node.source.isStartWith(PERCENTCAPITALQ) and
        isAcceptableCapitalQ(node)

  method message*(self: UnneededPercentQ; node: Node): void =
    var
      src = node.source
      extra = if src.isStartWith(PERCENTCAPITALQ):
        DYNAMICMSG
    format(MSG, qType = src[0], extra = extra)

  method isStringLiteral*(self: UnneededPercentQ; node: Node): void =
    node.loc.isRespondTo("begin") and node.loc.isRespondTo("end") and
        node.loc.begin and node.loc.end

  method isStartWithPercentQVariant*(self: UnneededPercentQ; string: Node): void =
    string.source.isStartWith(PERCENTQ, PERCENTCAPITALQ)

  method isAcceptableQ*(self: UnneededPercentQ; node: Node): void =
    var src = node.source
    if src.=~(STRINGINTERPOLATIONREGEXP):
      return true
    src.scan().anyIt:
      it.=~(ESCAPEDNONBACKSLASH)

  method isAcceptableCapitalQ*(self: UnneededPercentQ; node: Node): void =
    var src = node.source
    src.isInclude(QUOTE) and
      src.=~(STRINGINTERPOLATIONREGEXP) or
        node.isStrType() and isDoubleQuotesRequired(src)

