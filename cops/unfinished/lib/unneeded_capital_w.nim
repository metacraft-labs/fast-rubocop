
import
  sequtils

import
  percentLiteral

cop :
  type
    UnneededCapitalW* = ref object of Cop
    ##  This cop checks for usage of the %W() syntax when %w() would do.
    ## 
    ##  @example
    ##    # bad
    ##    %W(cat dog pig)
    ##    %W[door wall floor]
    ## 
    ##    # good
    ##    %w/swim run bike/
    ##    %w[shirt pants shoes]
    ##    %W(apple #{fruit} grape)
  const
    MSG = """Do not use `%W` unless interpolation is needed. If not, use `%w`."""
  method onArray*(self: UnneededCapitalW; node: Node): void =
    process(node, "%W")

  method autocorrect*(self: UnneededCapitalW; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var src = node.loc.begin.source
      corrector.replace(node.loc.begin, src.tr("W", "w")))

  method onPercentLiteral*(self: UnneededCapitalW; node: Node): void =
    if isRequiresInterpolation(node):
      return
    addOffense(node)

  method isRequiresInterpolation*(self: UnneededCapitalW; node: Node): void =
    node.childNodes.anyIt:
      it.isDstrType() or isDoubleQuotesRequired(it.source)

