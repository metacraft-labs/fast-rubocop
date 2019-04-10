
import
  sequtils

import
  percentLiteral

cop :
  type
    PercentLiteralDelimiters* = ref object of Cop
    ##  This cop enforces the consistent usage of `%`-literal delimiters.
    ## 
    ##  Specify the 'default' key to set all preferred delimiters at once. You
    ##  can continue to specify individual preferred delimiters to override the
    ##  default.
    ## 
    ##  @example
    ##    # Style/PercentLiteralDelimiters:
    ##    #   PreferredDelimiters:
    ##    #     default: '[]'
    ##    #     '%i':    '()'
    ## 
    ##    # good
    ##    %w[alpha beta] + %i(gamma delta)
    ## 
    ##    # bad
    ##    %W(alpha #{beta})
    ## 
    ##    # bad
    ##    %I(alpha beta)
  method onArray*(self: PercentLiteralDelimiters; node: Node): void =
    process(node, "%w", "%W", "%i", "%I")

  method onRegexp*(self: PercentLiteralDelimiters; node: Node): void =
    process(node, "%r")

  method onStr*(self: PercentLiteralDelimiters; node: Node): void =
    process(node, "%", "%Q", "%q")

  method onSym*(self: PercentLiteralDelimiters; node: Node): void =
    process(node, "%s")

  method onXstr*(self: PercentLiteralDelimiters; node: Node): void =
    process(node, "%x")

  method message*(self: PercentLiteralDelimiters; node: Node): void =
    var
      type = type(node)
      delimiters = preferredDelimitersFor(type)
    """(str "`")(str "`")"""

  method autocorrect*(self: PercentLiteralDelimiters; node: Node): void =
    var type = type(node)
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.begin,
                        """(lvar :type)(lvar :opening_delimiter)""")
      corrector.replace(node.loc.end, closingDelimiter))

  method onPercentLiteral*(self: PercentLiteralDelimiters; node: Node): void =
    var type = type(node)
    if isUsesPreferredDelimiter(node, type) or
        isContainsPreferredDelimiter(node, type) or
        isIncludeSameCharacterAsUsedForDelimiter(node, type):
      return
    addOffense(node)

  method preferredDelimitersFor*(self: PercentLiteralDelimiters; type: string): void =
    PreferredDelimiters.new(type, self.config, ).delimiters

  method isUsesPreferredDelimiter*(self: PercentLiteralDelimiters; node: Node;
                                  type: string): void =
    preferredDelimitersFor(type)[0] == beginSource(node)[-1]

  method isContainsPreferredDelimiter*(self: PercentLiteralDelimiters; node: Node;
                                      type: string): void =
    var preferredDelimiters = preferredDelimitersFor(type)
    node.children.mapIt:
      stringSource(it).compact.anyIt:
      preferredDelimiters.anyIt:
        s.isInclude(it)

  method isIncludeSameCharacterAsUsedForDelimiter*(
      self: PercentLiteralDelimiters; node: Node; type: string): void =
    if @["%w", "%i"].isInclude(type):
    else:
      return false
    var
      usedDelimiters = matchpairs(beginSource(node)[-1])
      escapedDelimiters = usedDelimiters.mapIt:
        """\(lvar :d)""".join("|")
    node.children.mapIt:
      stringSource(it).compact.anyIt:
      Regexp.new(escapedDelimiters).=~(it)

  method stringSource*(self: PercentLiteralDelimiters; node: Node): void =
    if node.isIsA(String):
      node
    elif node.isRespondTo("type") and node.isStrType():
      node.source
  
  method matchpairs*(self: PercentLiteralDelimiters; beginDelimiter: string): void =
    {"(": @["(", ")"], "[": @["[", "]"], "{": @["{", "}"], "<": @["<", ">"]}.newTable().fetch(
        beginDelimiter, @[beginDelimiter])

