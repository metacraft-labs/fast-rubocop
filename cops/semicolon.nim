
import
  tables, sequtils

import
  rangeHelp

cop :
  type
    Semicolon* = ref object of Cop
    ##  This cop checks for multiple expressions placed on the same line.
    ##  It also checks for lines terminated with a semicolon.
    ## 
    ##  @example
    ##    # bad
    ##    foo = 1; bar = 2;
    ##    baz = 3;
    ## 
    ##    # good
    ##    foo = 1
    ##    bar = 2
    ##    baz = 3
  const
    MSG = "Do not use semicolons to terminate expressions."
  method investigate*(self: Semicolon; processedSource: ProcessedSource): void =
    if processedSource.isBlank:
      return
    self.processedSource = processedSource
    checkForLineTerminatorOrOpener

  method onBegin*(self: Semicolon; node: Node): void =
    if copConfig["AllowAsExpressionSeparator"]:
      return
    var exprs = node.children
    if exprs.size < 2:
      return
    var
      exprsLines = exprs.mapIt:
        it.sourceRange.line
      lines = exprsLines.groupBy(proc (i: Integer): void =
        i)
    for line, exprOnLine in lines:
      if exprOnLine.size > 1:
      var column = self.processedSource[line - 1].index(";")
      if column:
      conventionOn(line, column, false)

  method autocorrect*(self: Semicolon; range: Range): void =
    if range:
    lambda(proc (corrector: Corrector): void =
      corrector.remove(range))

  method checkForLineTerminatorOrOpener*(self: Semicolon): void =
    eachSemicolon(proc (line: Integer; column: Integer): void =
      conventionOn(line, column, true))

  iterator eachSemicolon*(self: Semicolon): void =
    for line, tokens in tokensForLines:
      if tokens.last().isSemicolon:
        yield line
      if tokens[0].isSemicolon:
        yield line
  
  method tokensForLines*(self: Semicolon): void =
    self.processedSource.tokens.groupBy(proc (it: void): void =
      it.ine)

  method conventionOn*(self: Semicolon; line: Integer; column: Integer;
                      autocorrect: TrueClass): void =
    var range = sourceRange(self.processedSource.buffer, line, column)
    addOffense(if autocorrect:
      range
    , location = range)

