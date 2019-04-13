
import
  surroundingSpace

import
  configurableEnforcedStyle

import
  rangeHelp

cop :
  type
    SpaceInsideHashLiteralBraces* = ref object of Cop
  const
    MSG = "Space inside %<problem>s."
  method onHash*(self: SpaceInsideHashLiteralBraces; node: Node): void =
    var tokens = processedSource.tokens
    hashLiteralWithBraces(node, proc (beginIndex: Integer; endIndex: Integer): void =
      check(tokens[beginIndex], tokens[beginIndex & 1])
      if beginIndex == endIndex - 1:
        return
      check(tokens[endIndex - 1], tokens[endIndex]))

  method autocorrect*(self: SpaceInsideHashLiteralBraces; range: Range): void =
    lambda(proc (corrector: Corrector): void =
      case range.source
      of :
        corrector.remove(range)
      of "{":
        corrector.replace(range, "{ ")
      else:
        corrector.replace(range, " }")
    )

  method hashLiteralWithBraces*(self: SpaceInsideHashLiteralBraces; node: Node): void =
    var
      tokens = processedSource.tokens
      beginIndex = indexOfFirstToken(node)
    if tokens[beginIndex].isLeftBrace:
    var endIndex = indexOfLastToken(node)
    if tokens[endIndex].isRightCurlyBrace:
    yield beginIndex

  method check*(self: SpaceInsideHashLiteralBraces; token1: Token; token2: Token): void =
    if token1.line < token2.line:
      return
    if token2.isComment:
      return
    var
      isEmptyBraces = token1.isLeftBrace and token2.isRightCurlyBrace
      expectSpace = isExpectSpace(token1, token2)
    if isOffense(token1, expectSpace):
      incorrectStyleDetected(token1, token2, expectSpace, isEmptyBraces)
  
  method isExpectSpace*(self: SpaceInsideHashLiteralBraces; token1: Token;
                       token2: Token): void =
    var
      isSameBraces = token1.type == token2.type
      isEmptyBraces = token1.isLeftBrace and token2.isRightCurlyBrace
    if isSameBraces and style == "compact":
      false
    elif isEmptyBraces:
      copConfig["EnforcedStyleForEmptyBraces"] != "no_space"
    else:
      style != "no_space"
  
  method incorrectStyleDetected*(self: SpaceInsideHashLiteralBraces; token1: Token;
                                token2: Token; expectSpace: FalseClass;
                                isEmptyBraces: FalseClass): void =
    var
      brace =
        if token1.text == "{":
          token1
      .pos
      range = if expectSpace:
        brace
      else:
        spaceRange(brace)
    addOffense(range, location = range,
               message = message(brace, isEmptyBraces, expectSpace), proc (): void =
      var style = if expectSpace:
        "no_space"
      ambiguousOrUnexpectedStyleDetected(style, token1.text == token2.text))

  method ambiguousOrUnexpectedStyleDetected*(self: SpaceInsideHashLiteralBraces;
      style: Symbol; isMatch: FalseClass): void =
    if isMatch:
      ambiguousStyleDetected(style, "compact")
    else:
      unexpectedStyleDetected(style)
  
  method isOffense*(self: SpaceInsideHashLiteralBraces; token1: Token;
                   expectSpace: TrueClass): void =
    var hasSpace = token1.isSpaceAfter
    if expectSpace:
      hasSpace.!
  
  method message*(self: SpaceInsideHashLiteralBraces; brace: Range;
                 isEmptyBraces: FalseClass; expectSpace: FalseClass): void =
    var
      insideWhat = if isEmptyBraces:
        "empty hash literal braces"
      else:
        brace.source
      problem = if expectSpace:
        "missing"
    format(MSG, problem = """(lvar :inside_what) (lvar :problem)""")

  method spaceRange*(self: SpaceInsideHashLiteralBraces; tokenRange: Range): void =
    if tokenRange.source == "{":
      rangeOfSpaceToTheRight(tokenRange)
    else:
      rangeOfSpaceToTheLeft(tokenRange)
  
  method rangeOfSpaceToTheRight*(self: SpaceInsideHashLiteralBraces; range: Range): void =
    var
      src = range.sourceBuffer.source
      endPos = range.endPos
    while src[endPos].=~():
      endPos += 1
    rangeBetween(range.beginPos & 1, endPos)

  method rangeOfSpaceToTheLeft*(self: SpaceInsideHashLiteralBraces; range: Range): void =
    var
      src = range.sourceBuffer.source
      beginPos = range.beginPos
    while src[beginPos - 1].=~():
      beginPos -= 1
    rangeBetween(beginPos, range.endPos - 1)

