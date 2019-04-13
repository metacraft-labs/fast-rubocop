
import
  configurableEnforcedStyle

cop :
  type
    MultilineMemoization* = ref object of Cop
    ##  This cop checks expressions wrapping styles for multiline memoization.
    ## 
    ##  @example EnforcedStyle: keyword (default)
    ##    # bad
    ##    foo ||= (
    ##      bar
    ##      baz
    ##    )
    ## 
    ##    # good
    ##    foo ||= begin
    ##      bar
    ##      baz
    ##    end
    ## 
    ##  @example EnforcedStyle: braces
    ##    # bad
    ##    foo ||= begin
    ##      bar
    ##      baz
    ##    end
    ## 
    ##    # good
    ##    foo ||= (
    ##      bar
    ##      baz
    ##    )
  const
    MSG = "Wrap multiline memoization blocks in `begin` and `end`."
  method onOrAsgn*(self: MultilineMemoization; node: Node): void =
    if isBadRhs(rhs):
    addOffense(rhs, location = node.sourceRange)

  method autocorrect*(self: MultilineMemoization; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      if style == "keyword":
        keywordAutocorrect(node, corrector)
      else:
        corrector.replace(node.loc.begin, "(")
        corrector.replace(node.loc.end, ")"))

  method isBadRhs*(self: MultilineMemoization; rhs: Node): void =
    if rhs.isMultiline:
    else:
      return false
    if style == "keyword":
      rhs.isBeginType()
    else:
      rhs.isKwbeginType()
  
  method keywordAutocorrect*(self: MultilineMemoization; node: Node;
                            corrector: Corrector): void =
    var nodeBuf = node.sourceRange.sourceBuffer
    corrector.replace(node.loc.begin, keywordBeginStr(node, nodeBuf))
    corrector.replace(node.loc.end, keywordEndStr(node, nodeBuf))

  method keywordBeginStr*(self: MultilineMemoization; node: Node; nodeBuf: Buffer): void =
    var indent = config.forCop("IndentationWidth")["Width"] or 2
    if nodeBuf.source[node.loc.begin.endPos] == "\n":
      "begin"
    else:
      "begin\n" &
        " " *
          node.loc.column & indent
  
  method keywordEndStr*(self: MultilineMemoization; node: Node; nodeBuf: Buffer): void =
    if nodeBuf.sourceLine(node.loc.end.line).=~():
      "\n" &
        " " * node.loc.column & "end"
  
