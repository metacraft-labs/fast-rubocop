
import
  rangeHelp

cop :
  type
    AsciiIdentifiers* = ref object of Cop
    ##  This cop checks for non-ascii characters in identifier names.
    ## 
    ##  @example
    ##    # bad
    ##    def καλημερα # Greek alphabet (non-ascii)
    ##    end
    ## 
    ##    # bad
    ##    def こんにちはと言う # Japanese character (non-ascii)
    ##    end
    ## 
    ##    # bad
    ##    def hello_🍣 # Emoji (non-ascii)
    ##    end
    ## 
    ##    # good
    ##    def say_hello
    ##    end
    ## 
    ##    # bad
    ##    신장 = 10 # Hangul character (non-ascii)
    ## 
    ##    # good
    ##    height = 10
    ## 
    ##    # bad
    ##    params[:عرض_gteq] # Arabic character (non-ascii)
    ## 
    ##    # good
    ##    params[:width_gteq]
    ## 
  const
    MSG = "Use only ascii symbols in identifiers."
  method investigate*(self: AsciiIdentifiers; processedSource: ProcessedSource): void =
    processedSource.eachToken(proc (token: Token): void =
      if token.type == "tIDENTIFIER" and token.text.isAsciiOnly().!:
      addOffense(token, location = firstOffenseRange(token)))

  method firstOffenseRange*(self: AsciiIdentifiers; identifier: Token): void =
    var
      expression = identifier.pos
      firstOffense = firstNonAsciiChars(identifier.text)
      startPosition = expression.beginPos & identifier.text.index(firstOffense)
      endPosition = startPosition & firstOffense.length
    rangeBetween(startPosition, endPosition)

  method firstNonAsciiChars*(self: AsciiIdentifiers; string: string): void =
    `$`()

