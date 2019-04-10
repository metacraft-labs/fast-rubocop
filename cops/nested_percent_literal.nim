
import
  sequtils

import
  percentLiteral

cop :
  type
    NestedPercentLiteral* = ref object of Cop
  const
    MSG = """Within percent literals, nested percent literals do not function and may be unwanted in the result."""
  const
    PERCENTLITERALTYPES = PERCENTLITERALTYPES
  const
    REGEXES = PERCENTLITERALTYPES.mapIt:
  method onArray*(self: NestedPercentLiteral; node: Node): void =
    process(node, )

  method onPercentLiteral*(self: NestedPercentLiteral; node: Node): void =
    if isContainsPercentLiterals(node):
      addOffense(node)
  
  method isContainsPercentLiterals*(self: NestedPercentLiteral; node: Node): void =
    node.eachChildNode.anyIt:
      var literal = `$`().scrub()
      REGEXES.anyIt:
        literal.match(it)

