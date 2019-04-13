
import
  sequtils

import
  firstElementLineBreak

cop :
  type
    FirstMethodArgumentLineBreak* = ref object of Cop
  const
    MSG = """Add a line break before the first argument of a multi-line method argument list."""
  method onSend*(self: FirstMethodArgumentLineBreak; node: Node): void =
    var args = node.arguments
    if
      var lastArg = args.last():
      if lastArg.isHashType() and lastArg.isBraces.!:
        args = args.concat(
          var tmp = args[args.len() - 1]
          args.delete(args.len() - 1, 1)
          tmp.children)
    checkMethodLineBreak(node, args)

  method autocorrect*(self: FirstMethodArgumentLineBreak; node: Node): void =
    EmptyLineCorrector.insertBefore(node)

