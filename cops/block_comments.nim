
import
  rangeHelp

cop :
  type
    BlockComments* = ref object of Cop
    ##  This cop looks for uses of block comments (=begin...=end).
    ## 
    ##  @example
    ##    # bad
    ##    =begin
    ##    Multiple lines
    ##    of comments...
    ##    =end
    ## 
    ##    # good
    ##    # Multiple lines
    ##    # of comments...
    ## 
  const
    MSG = "Do not use block comments."
  const
    BEGINLENGTH = "=begin\n".length
  const
    ENDLENGTH = "\n=end".length
  method investigate*(self: BlockComments; processedSource: ProcessedSource): void =
    processedSource.eachComment(proc (comment: Comment): void =
      if comment.isDocument:
      addOffense(comment))

  method autocorrect*(self: BlockComments; comment: Comment): void =
    lambda(proc (corrector: Corrector): void =
      corrector.remove(eqBegin)
      if contents.length.isZero():
      else:
        corrector.replace(contents, contents.source.gsub("# ").gsub("\n#\n").gsub(
            "\n# "))
      corrector.remove(eqEnd))

  method parts*(self: BlockComments; comment: Comment): void =
    var
      expr = comment.loc.expression
      eqBegin = expr.resize(BEGINLENGTH)
      eqEnd = rangeBetween(expr.endPos - ENDLENGTH, expr.endPos)
      contents = rangeBetween(eqBegin.endPos, eqEnd.beginPos)
    @[eqBegin, eqEnd, contents]

