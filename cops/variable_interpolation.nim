
import
  tables, sequtils

cop :
  type
    VariableInterpolation* = ref object of Cop
    ##  This cop checks for variable interpolation (like "#@ivar").
    ## 
    ##  @example
    ##    # bad
    ##    "His name is #$name"
    ##    /check #$pattern/
    ##    "Let's go to the #@store"
    ## 
    ##    # good
    ##    "His name is #{$name}"
    ##    /check #{$pattern}/
    ##    "Let's go to the #{@store}"
  const
    MSG = """Replace interpolated variable `%<variable>s` with expression `#{%<variable>s}`."""
  method onDstr*(self: VariableInterpolation; node: Node): void =
    checkForInterpolation(node)

  method onRegexp*(self: VariableInterpolation; node: Node): void =
    checkForInterpolation(node)

  method onXstr*(self: VariableInterpolation; node: Node): void =
    checkForInterpolation(node)

  method autocorrect*(self: VariableInterpolation; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, """{(send
  (lvar :node) :source)}"""))

  method checkForInterpolation*(self: VariableInterpolation; node: Node): void =
    for varNode in varNodes(node.children):
      addOffense(varNode)

  method message*(self: VariableInterpolation; node: Node): void =
    format(MSG, variable = node.source)

  method varNodes*(self: VariableInterpolation; nodes: Array): void =
    nodes.filterIt:
      it.isVariable or it.isReference

