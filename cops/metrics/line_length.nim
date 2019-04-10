
import
  types

import
  sequtils

import
  configurableMax

import
  ignoredPattern

import
  rangeHelp

cop LineLength:
  ##  This cop checks the length of lines in the source code.
  ##  The maximum length is configurable.
  ##  The tab size is configured in the `IndentationWidth`
  ##  of the `Layout/Tab` cop.
  const
    MSG = "Line is too long. [%<length>d/%<max>d]"
  method investigate*(self; processedSource: ProcessedSource) =
    var heredocs: seq[void]
    if self.isAllowHeredoc():
      heredocs = self.extractHeredocs(processedSource.ast)
    processedSource.lines.eachWithIndex(proc (line: string; index: int) =
      self.checkLine(line, index, heredocs))

  method tabIndentationWidth*(self) =
    config.forCop("Layout/Tab")["IndentationWidth"]

  method indentationDifference*(self; line: string) =
    if not self.tabIndentationWidth():
      return 0
    line.match()[0].size *
      self.tabIndentationWidth() - 1

  method lineLength*(self; line: string): int =
    line.length + self.indentationDifference(line)

  method highlighStart*(self; line: string) =
    self.max() - self.indentationDifference(line)

  method checkLine*(self; line: string; index: int; heredocs: seq[void]) =
    if self.lineLength(line) <= self.max():
      return
    if self.isIgnoredLine(line, index, heredocs):
      return
    if self.isIgnoreCopDirectives() and self.isDirectiveOnSourceLine(index):
      return self.checkDirectiveLine(line, index)
    if self.isAllowUri():
      return self.checkUriLine(line, index)
    self.registerOffense(self.sourceRange(processedSource.buffer, index, ), line)

  method isIgnoredLine*(self; line: string; index: int; heredocs: seq[void]): bool =
    self.isMatchesIgnoredPattern(line) and
        heredocs and self.isLineInPermittedHeredoc(heredocs, index.succ)

  method registerOffense*(self; loc: Range; line: string) =
    var message = format(MSG, length = self.lineLength(line), max = self.max())
    addOffense(location = loc, message = message, proc (): int =
      self.max=(self.lineLength(line)))

  method excessRange*(self; uriRange: void; line: string; index: int) =
    var excessivePosition = if uriRange and uriRange.begin < self.max():
      uriRange.end
    else:
      self.highlighStart(line)
    self.sourceRange(processedSource.buffer, index + 1, )

  method max*(self) =
    copConfig["Max"]

  method isAllowHeredoc*(self): bool =
    self.allowedHeredoc()

  method allowedHeredoc*(self) =
    copConfig["AllowHeredoc"]

  method extractHeredocs*(self; ast: void) =
    if not ast:
      return @[]
    ast.eachNode("str", "dstr", "xstr").select(proc (it: void) =
      it.isHeredoc).map(proc (node) =
      var
        body = node.location.heredocBody
        delimiter = node.location.heredocEnd.source.strip
      (delimiter))

  method isLineInPermittedHeredoc*(self; heredocs: seq[void]; lineNumber: int) =
    heredocs.anyIt:
      it.isCover(lineNumber) and
        self.allowedHeredoc() == true and delimiter in self.allowedHeredoc()

  method isAllowUri*(self) =
    copConfig["AllowURI"]

  method isIgnoreCopDirectives*(self) =
    copConfig["IgnoreCopDirectives"]

  method isAllowedUriPosition*(self; line: string; uriRange: Range): bool =
    uriRange.begin < self.max() and
      uriRange.end == self.lineLength(line) and
          uriRange.end == self.lineLength(line) - 1

  method findExcessiveUriRange*(self; line: string) =
    var lastUriMatch = self.matchUris(line).last
    if not lastUriMatch:
      return
    if beginPosition < self.max() and endPosition < self.max():
      return
  
  method matchUris*(self; string: string) =
    var matches = @[]
    string.scan(self.uriRegexp(), proc () =
      if self.isValidUri($LASTMATCHINFO[0]):
        matches.<<($LASTMATCHINFO)
    )
    matches

  method isValidUri*(self; uriIshString: string) =
    except
      URI.parse(uriIshString)
      true:
      @[InvalidURIError, NoMethodError]
      false

  method uriRegexp*(self) =
    var @uriRegexp = @uriRegexp
        DEFAULTPARSER.makeRegexp(copConfig["URISchemes"])

  method checkDirectiveLine*(self; line: string; index: int) =
    if self.lineLengthWithoutDirective(line) <= self.max():
      return
    var range
    self.registerOffense(self.sourceRange(processedSource.buffer, index + 1, range),
                         line)

  method isDirectiveOnSourceLine*(self; index: int) =
    var
      sourceLineNumber = index + processedSource.buffer.firstLine
      comment = processedSource.comments.detect(proc (e: void) =
        e.location.line == sourceLineNumber)
    if not comment:
      return false
    comment.text.match(COMMENTDIRECTIVEREGEXP)

  method lineLengthWithoutDirective*(self; line: string) =
    var beforeComment = line.split(COMMENTDIRECTIVEREGEXP)[0]
    beforeComment.rstrip.length

  method checkUriLine*(self; line: string; index: int) =
    var uriRange = self.findExcessiveUriRange(line)
    if uriRange and self.isAllowedUriPosition(line, uriRange):
      return
    self.registerOffense(self.excessRange(uriRange, line, index), line)

