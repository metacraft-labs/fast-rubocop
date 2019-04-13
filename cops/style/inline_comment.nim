
import
  types

cop InlineComment:
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
  method investigate*(self; processedSource: ProcessedSource) =
    processedSource.eachComment(proc (comment: Comment) =
      if isCommentLine(processedSource[comment.loc.line - 1]) and
          comment.text.match():
        continue
      addOffense(comment))

