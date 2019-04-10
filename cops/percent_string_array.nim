
import
  tables, sequtils

import
  percentLiteral

cop :
  type
    PercentStringArray* = ref object
  const
    QUOTESANDCOMMAS = @[]
  const
    LEADINGQUOTE
  const
    TRAILINGQUOTE
  const
    MSG = """Within `%w`/`%W`, quotes and ',' are unnecessary and may be unwanted in the resulting strings."""
  method onArray*(self: void; node: void): void =
    process(node, "%w", "%W")

  method onPercentLiteral*(self: void; node: void): void =
    if isContainsQuotesOrCommas(node):
    addOffense(node)

  method autocorrect*(self: void; node: void): void =
    lambda(proc (corrector: void): void =
      for value in node.values:
        var
          range = value.loc.expression
          match = range.source.match(TRAILINGQUOTE)
        if match:
          corrector.removeTrailing(range, match[0].length)
        if range.source.=~(LEADINGQUOTE):
          corrector.removeLeading(range, 1)
    )

  method isContainsQuotesOrCommas*(self: void; node: void): void =
    node.values.anyIt:
      var literal = it.children.first.toS.scrub
      if literal.gsub("").isEmpty:
        continue
      QUOTESANDCOMMAS.anyIt:
        literal.=~(it)

