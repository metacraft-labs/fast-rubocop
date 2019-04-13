
import
  rangeHelp

cop :
  type
    RedundantSortBy* = ref object of Cop
  const
    MSG = "Use `sort` instead of `sort_by { |%<var>s| %<var>s }`."
  nodeMatcher redundantSortBy, "          (block $(send _ :sort_by) (args (arg $_x)) (lvar _x))\n"
  method onBlock*(self: RedundantSortBy; node: Node): void =
    redundantSortBy node:
      var range = sortByRange(send, node)
      addOffense(node, location = range, message = format(MSG, var = varName))

  method autocorrect*(self: RedundantSortBy; node: Node): void =
    var send = node[0]
    lambda(proc (corrector: Corrector): void =
      corrector.replace(sortByRange(send, node), "sort"))

  method sortByRange*(self: RedundantSortBy; send: Node; node: Node): void =
    rangeBetween(send.loc.selector.beginPos, node.loc.end.endPos)

