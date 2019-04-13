
cop :
  type
    InlineComment* = ref object of Cop
    ##  This cop checks for trailing inline comments.
    ## 
    ##  @example
    ## 
    ##    # good
    ##    foo.each do |f|
    ##      # Standalone comment
    ##      f.bar
    ##    end
    ## 
    ##    # bad
    ##    foo.each do |f|
    ##      f.bar # Trailing inline comment
    ##    end
  const
    MSG = "Avoid trailing inline comments."
  method investigate*(self: InlineComment; processedSource: ProcessedSource): void =
    processedSource.eachComment(proc (comment: Comment): void =
      if isCommentLine(processedSource[comment.loc.line - 1]) or
          comment.text.match():
        continue
      addOffense(comment))

