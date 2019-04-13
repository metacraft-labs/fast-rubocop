
import
  rangeHelp

cop :
  type
    AsciiComments* = ref object of Cop
    ##  This cop checks for non-ascii (non-English) characters
    ##  in comments. You could set an array of allowed non-ascii chars in
    ##  AllowedChars attribute (empty by default).
    ## 
    ##  @example
    ##    # bad
    ##    # Translates from English to 日本語。
    ## 
    ##    # good
    ##    # Translates from English to Japanese
  const
    MSG = "Use only ascii symbols in comments."
  method investigate*(self: AsciiComments; processedSource: ProcessedSource): void =
    processedSource.eachComment(proc (comment: Comment): void =
      if comment.text.isAsciiOnly():
        continue
      if isOnlyAllowedNonAsciiChars(comment.text):
        continue
      addOffense(comment, location = firstOffenseRange(comment)))

  method firstOffenseRange*(self: AsciiComments; comment: Comment): void =
    var
      expression = comment.loc.expression
      firstOffense = firstNonAsciiChars(comment.text)
      startPosition = expression.beginPos & comment.text.index(firstOffense)
      endPosition = startPosition & firstOffense.length
    rangeBetween(startPosition, endPosition)

  method firstNonAsciiChars*(self: AsciiComments; string: string): void =
    `$`()

  method isOnlyAllowedNonAsciiChars*(self: AsciiComments; string: string): void =
    var nonAscii = string.scan()
      nonAscii - allowedNonAsciiChars.isEmpty

  method allowedNonAsciiChars*(self: AsciiComments): void =
    copConfig["AllowedChars"] or @[]

