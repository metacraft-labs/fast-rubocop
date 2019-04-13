
import
  tables, sequtils

import
  percentLiteral

cop :
  type
    PercentSymbolArray* = ref object
  const
    MSG = """Within `%i`/`%I`, ':' and ',' are unnecessary and may be unwanted in the resulting symbols."""
  method onArray*(self: void; node: void): void =
    process(node, "%i", "%I")

  method onPercentLiteral*(self: void; node: void): void =
    if isContainsColonsOrCommas(node):
    addOffense(node)

  method autocorrect*(self: void; node: void): void =
    lambda(proc (corrector: void): void =
      for child in node.children:
        var range = child.loc.expression
        if range.source.isEndWith(","):
          corrector.removeTrailing(range, 1)
        if range.source.isStartWith(":"):
          corrector.removeLeading(range, 1)
    )

  method isContainsColonsOrCommas*(self: void; node: void): void =
    node.children.anyIt:
      var literal = it.children.first.toS
      if isNonAlphanumericLiteral(literal):
        continue
      literal.isStartWith(":") or literal.isEndWith(",")

  method isNonAlphanumericLiteral*(self: void; literal: void): void =
    literal.!~()

