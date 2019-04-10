
import
  multilineLiteralBraceLayout

cop :
  type
    MultilineMethodCallBraceLayout* = ref object of Cop
  const
    SAMELINEMESSAGE = """Closing method call brace must be on the same line as the last argument when opening brace is on the same line as the first argument."""
  const
    NEWLINEMESSAGE = """Closing method call brace must be on the line after the last argument when opening brace is on a separate line from the first argument."""
  const
    ALWAYSNEWLINEMESSAGE = """Closing method call brace must be on the line after the last argument."""
  const
    ALWAYSSAMELINEMESSAGE = """Closing method call brace must be on the same line as the last argument."""
  method onSend*(self: MultilineMethodCallBraceLayout; node: Node): void =
    checkBraceLayout(node)

  method autocorrect*(self: MultilineMethodCallBraceLayout; node: Node): void =
    MultilineLiteralBraceCorrector.new(node, processedSource)

  method children*(self: MultilineMethodCallBraceLayout; node: Node): void =
    node.arguments

  method isIgnoredLiteral*(self: MultilineMethodCallBraceLayout; node: Node): void =
    isSingleLineIgnoringReceiver(node) or super

  method isSingleLineIgnoringReceiver*(self: MultilineMethodCallBraceLayout;
                                      node: Node): void =
    if node.loc.begin and node.loc.end:
    else:
      return false
    node.loc.begin.line == node.loc.end.line

