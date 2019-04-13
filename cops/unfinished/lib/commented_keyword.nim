
import
  sequtils

import
  rangeHelp

cop :
  type
    CommentedKeyword* = ref object of Cop
    ##  This cop checks for comments put on the same line as some keywords.
    ##  These keywords are: `begin`, `class`, `def`, `end`, `module`.
    ## 
    ##  Note that some comments (`:nodoc:`, `:yields:, and `rubocop:disable`)
    ##  are allowed.
    ## 
    ##  @example
    ##    # bad
    ##    if condition
    ##      statement
    ##    end # end if
    ## 
    ##    # bad
    ##    class X # comment
    ##      statement
    ##    end
    ## 
    ##    # bad
    ##    def x; end # comment
    ## 
    ##    # good
    ##    if condition
    ##      statement
    ##    end
    ## 
    ##    # good
    ##    class X # :nodoc:
    ##      y
    ##    end
  const
    MSG = """Do not place comments on the same line as the `%<keyword>s` keyword."""
  const
    KEYWORDS = @["begin", "class", "def", "end", "module"]
  const
    ALLOWEDCOMMENTS = @[":nodoc:", ":yields:", "rubocop:disable"]
  method investigate*(self: CommentedKeyword; processedSource: ProcessedSource): void =
    var heredocLines = extractHeredocLines(processedSource.ast)
    processedSource.eachComment(proc (comment: Comment): void =
      var
        location = comment.location
        linePosition = location.line
        line = processedSource.lines[linePosition - 1]
      if heredocLines.anyIt:
        it.isInclude(linePosition):
        continue
      if isOffensive(line):
      var range = sourceRange(processedSource.buffer, linePosition, )
      addOffense(range, location = range))

  method isOffensive*(self: CommentedKeyword; line: string): void =
    line = line.lstrip()
    KEYWORDS.anyIt:
      line.=~() and
        ALLOWEDCOMMENTS.isNone(proc (c: string): void =
      line.=~())

  method message*(self: CommentedKeyword; node: Range): void =
    var
      line = node.sourceLine
      keyword = .match(line)[1]
    format(MSG, keyword = keyword)

  method extractHeredocLines*(self: CommentedKeyword; ast: Node): void =
    if ast:
    else:
      return @[]
    ast.eachNode("str", "dstr", "xstr").filterIt:
      it.isEredoc.mapIt:
      var body = it.location.heredocBody
  
