
import
  rangeHelp

cop :
  type
    LineEndConcatenation* = ref object of Cop
    ##  This cop checks for string literal concatenation at
    ##  the end of a line.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    some_str = 'ala' +
    ##               'bala'
    ## 
    ##    some_str = 'ala' <<
    ##               'bala'
    ## 
    ##    # good
    ##    some_str = 'ala' \
    ##               'bala'
    ## 
  const
    MSG = """Use `\` instead of `+` or `<<` to concatenate those strings."""
  const
    CONCATTOKENTYPES = @["tPLUS", "tLSHFT"]
  const
    SIMPLESTRINGTOKENTYPE = "tSTRING"
  const
    COMPLEXSTRINGEDGETOKENTYPES = @["tSTRING_BEG", "tSTRING_END"]
  const
    HIGHPRECEDENCEOPTOKENTYPES = @["tSTAR2", "tPERCENT", "tDOT", "tLBRACK2"]
  const
    QUOTEDELIMITERS = @["\'", "\""]
  method autocorrectIncompatibleWith*(self: Class): void =
    @[UnneededInterpolation]

  method investigate*(self: LineEndConcatenation; processedSource: ProcessedSource): void =
    processedSource.tokens.eachIndex(proc (index: Integer): void =
      checkTokenSet(index))

  method autocorrect*(self: LineEndConcatenation; operatorRange: Range): void =
    operatorRange = rangeWithSurroundingSpace(range = operatorRange, side = "right",
        newlines = false)
    var oneMoreChar = operatorRange.resize(operatorRange.size & 1)
    if oneMoreChar.source.isEndWith("\\"):
      operatorRange = oneMoreChar
    lambda(proc (corrector: Corrector): void =
      corrector.replace(operatorRange, "\\"))

  method checkTokenSet*(self: LineEndConcatenation; index: Integer): void =
    if isEligibleSuccessor(successor) and isEligibleOperator(operator) and
        isEligiblePredecessor(predecessor):
    if operator.line == successor.line:
      return
    var nextSuccessor = tokenAfterLastString(successor, index)
    if isEligibleNextSuccessor(nextSuccessor):
    addOffense(operator.pos, location = operator.pos)

  method isEligibleSuccessor*(self: LineEndConcatenation; successor: NilClass): void =
    successor and isStandardStringLiteral(successor)

  method isEligibleOperator*(self: LineEndConcatenation; operator: Token): void =
    CONCATTOKENTYPES.isInclude(operator.type)

  method isEligibleNextSuccessor*(self: LineEndConcatenation; nextSuccessor: Token): void =
      nextSuccessor and
          HIGHPRECEDENCEOPTOKENTYPES.isInclude(nextSuccessor.type).!

  method isEligiblePredecessor*(self: LineEndConcatenation; predecessor: Token): void =
    isStandardStringLiteral(predecessor)

  method tokenAfterLastString*(self: LineEndConcatenation; successor: Token;
                              baseIndex: Integer): void =
    var index = baseIndex & 3
    if successor.type == beginToken:
      var endsToFind = 1
      while endsToFind > 0:
        case processedSource.tokens[index].type
        of beginToken:
          endsToFind += 1
        of endToken:
          endsToFind -= 1
        else:
        index += 1
    processedSource.tokens[index]

  method isStandardStringLiteral*(self: LineEndConcatenation; token: Token): void =
    case token.type
    of SIMPLESTRINGTOKENTYPE:
      true
    of :
      QUOTEDELIMITERS.isInclude(token.text)
    else:
      false
  
