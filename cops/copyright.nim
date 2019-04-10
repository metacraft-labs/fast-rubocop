
import
  rangeHelp

cop :
  type
    Copyright* = ref object of Cop
    ##  Check that a copyright notice was given in each source file.
    ## 
    ##  The default regexp for an acceptable copyright notice can be found in
    ##  config/default.yml. The default can be changed as follows:
    ## 
    ##      Style/Copyright:
    ##        Notice: '^Copyright (\(c\) )?2\d{3} Acme Inc'
    ## 
    ##  This regex string is treated as an unanchored regex. For each file
    ##  that RuboCop scans, a comment that matches this regex must be found or
    ##  an offense is reported.
    ## 
  const
    MSG = """Include a copyright notice matching /%<notice>s/ before any code."""
  const
    AUTOCORRECTEMPTYWARNING = """An AutocorrectNotice must be defined in your RuboCop config"""
  method investigate*(self: Copyright; processedSource: ProcessedSource): void =
    if notice.isEmpty:
      return
    if isNoticeFound(processedSource):
      return
    var range = sourceRange(processedSource.buffer, 1, 0)
    addOffense(insertNoticeBefore(processedSource), location = range,
               message = format(MSG, notice = notice))

  method autocorrect*(self: Copyright; token: Token): void =
    if autocorrectNotice.isEmpty:
      raise(Warning, AUTOCORRECTEMPTYWARNING)
    var regex = Regexp.new(notice)
    if autocorrectNotice.=~(regex):
    else:
      raise(Warning, """(str "AutocorrectNotice '")(str "match Notice /")""")
    lambda(proc (corrector: Corrector): void =
      var range = if token.isNil():
        rangeBetween(0, 0)
      else:
        token.pos
      corrector.insertBefore(range, """(send nil :autocorrect_notice)
"""))

  method notice*(self: Copyright): void =
    copConfig["Notice"]

  method autocorrectNotice*(self: Copyright): void =
    copConfig["AutocorrectNotice"]

  method insertNoticeBefore*(self: Copyright; processedSource: ProcessedSource): void =
    var tokenIndex = 0
    if isShebangToken(processedSource, tokenIndex):
      tokenIndex += 1
    if isEncodingToken(processedSource, tokenIndex):
      tokenIndex += 1
    processedSource.tokens[tokenIndex]

  method isShebangToken*(self: Copyright; processedSource: ProcessedSource;
                        tokenIndex: Integer): void =
    if tokenIndex >= processedSource.tokens.size:
      return false
    var token = processedSource.tokens[tokenIndex]
    token.isComment and token.text.=~()

  method isEncodingToken*(self: Copyright; processedSource: ProcessedSource;
                         tokenIndex: Integer): void =
    if tokenIndex >= processedSource.tokens.size:
      return false
    var token = processedSource.tokens[tokenIndex]
    token.isComment and token.text.=~()

  method isNoticeFound*(self: Copyright; processedSource: ProcessedSource): void =
    var
      noticeFound = false
      noticeRegexp = Regexp.new(notice)
    processedSource.eachToken(proc (token: Token): void =
      if token.isComment:
      var noticeFound =
        token.text.=~(noticeRegexp).isNil().!
      if noticeFound:
        break
    )
    noticeFound

