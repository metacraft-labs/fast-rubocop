
import
  rangeHelp

cop :
  type
    MultilineBlockChain* = ref object of Cop
    ##  This cop checks for chaining of a block after another block that spans
    ##  multiple lines.
    ## 
    ##  @example
    ## 
    ##    Thread.list.find_all do |t|
    ##      t.alive?
    ##    end.map do |t|
    ##      t.object_id
    ##    end
  const
    MSG = "Avoid multi-line chains of blocks."
  method onBlock*(self: MultilineBlockChain; node: Node): void =
    node.sendNode.eachNode("send", proc (sendNode: Node): void =
      var receiver = sendNode.receiver
      if receiver and receiver.isBlockType() and receiver.isMultiline:
      var range = rangeBetween(receiver.loc.end.beginPos,
                            node.sendNode.sourceRange.endPos)
      addOffense(location = range)
      break )

