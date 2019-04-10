
import
  sequtils

import
  frozenStringLiteral

cop :
  type
    OrderedMagicComments* = ref object of Cop
  const
    MSG = """The encoding magic comment should precede all other magic comments."""
  method investigate*(self: OrderedMagicComments; processedSource: ProcessedSource): void =
    if processedSource.buffer.source.isEmpty:
      return
    if encodingLine and frozenStringLiteralLine:
    if encodingLine < frozenStringLiteralLine:
      return
    var range = processedSource.buffer.lineRange(encodingLine & 1)
    addOffense(range, location = range)

  method autocorrect*(self: OrderedMagicComments; _node: Range): void =
    var
      range1 = processedSource.buffer.lineRange(encodingLine & 1)
      range2 = processedSource.buffer.lineRange(frozenStringLiteralLine & 1)
    lambda(proc (corrector: Corrector): void =
      corrector.replace(range1, range2.source)
      corrector.replace(range2, range1.source))

  method magicCommentLines*(self: OrderedMagicComments): void =
    var lines = @[]
    magicComments.each().withIndex(proc (comment: SimpleComment; index: Integer): void =
      if comment.isEncodingSpecified:
        lines.[]=(0, index)
      elif comment.isFrozenStringLiteralSpecified:
        lines.[]=(1, index)
      if lines[0] and lines[1]:
        return lines
    )
    lines

  method magicComments*(self: OrderedMagicComments): void =
    leadingCommentLines.mapIt:
      MagicComment.parse(it)

