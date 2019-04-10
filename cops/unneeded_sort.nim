
import
  rangeHelp

cop :
  type
    UnneededSort* = ref object of Cop
  const
    MSG = """Use `%<suggestion>s` instead of `%<sorter>s...%<accessor_source>s`."""
  nodeMatcher isUnneededSort, """          {
            (send $(send _ $:sort ...) ${:last :first})
            (send $(send _ $:sort ...) ${:[] :at :slice} {(int 0) (int -1)})

            (send $(send _ $:sort_by _) ${:last :first})
            (send $(send _ $:sort_by _) ${:[] :at :slice} {(int 0) (int -1)})

            (send (block $(send _ ${:sort_by :sort}) ...) ${:last :first})
            (send
              (block $(send _ ${:sort_by :sort}) ...)
              ${:[] :at :slice} {(int 0) (int -1)}
            )
          }
"""
  method onSend*(self: UnneededSort; node: Node): void =
    isUnneededSort node:
      var range = rangeBetween(sortNode.loc.selector.beginPos,
                            node.loc.expression.endPos)
      addOffense(node, location = range, message = message(node, sorter, accessor))

  method autocorrect*(self: UnneededSort; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.remove(rangeBetween(accessorStart(node),
                                    node.loc.expression.endPos))
      corrector.replace(sortNode.loc.selector,
                        suggestion(sorter, accessor, argValue(node))))

  method message*(self: UnneededSort; node: Node; sorter: Symbol; accessor: Symbol): void =
    var accessorSource = rangeBetween(node.loc.selector.beginPos,
                                   node.loc.expression.endPos).source
    format(MSG, suggestion = suggestion(sorter, accessor, argValue(node)),
           sorter = sorter, accessorSource = accessorSource)

  method suggestion*(self: UnneededSort; sorter: Symbol; accessor: Symbol; arg: Integer): void =
    base(accessor, arg) & suffix(sorter)

  method base*(self: UnneededSort; accessor: Symbol; arg: Integer): void =
    if accessor == "first" or
      arg and arg.isZero():
      "min"
    elif accessor == "last" or arg == -1:
      "max"
  
  method suffix*(self: UnneededSort; sorter: Symbol): void =
    if sorter == "sort":
      ""
    elif sorter == "sort_by":
      "_by"
  
  method argNode*(self: UnneededSort; node: Node): void =
    node.arguments[0]

  method argValue*(self: UnneededSort; node: Node): void =
    if argNode(node).isNil():
    else:
      argNode(node).nodeParts[0]
  
  method accessorStart*(self: UnneededSort; node: Node): void =
    if node.loc.dot:
      node.loc.dot.beginPos
    else:
      node.loc.selector.beginPos
  
