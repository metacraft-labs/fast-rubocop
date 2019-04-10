
import
  alignment

cop :
  type
    BlockEndNewline* = ref object of Cop
  const
    MSG = "Expression at %<line>d, %<column>d should be on its own line."
  method onBlock*(self: BlockEndNewline; node: Node): void =
    if node.isSingleLine:
      return
    if isBeginsItsLine(node.loc.end):
      return
    addOffense(node, location = "end")

  method autocorrect*(self: BlockEndNewline; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(delimiterRange(node), """
(send
  (send
    (send
      (lvar :node) :loc) :end) :source)(send nil :offset
  (lvar :node))"""))

  method message*(self: BlockEndNewline; node: Node): void =
    format(MSG, line = node.loc.end.line, column = node.loc.end.column & 1)

  method delimiterRange*(self: BlockEndNewline; node: Node): void =
    Range.new(node.loc.expression.sourceBuffer,
              node.children.last().loc.expression.endPos,
              node.loc.expression.endPos)

