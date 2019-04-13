
import
  alignment

import
  trailingBody

cop :
  type
    TrailingBodyOnModule* = ref object of Cop
    ##  This cop checks for trailing code after the module definition.
    ## 
    ##  @example
    ##    # bad
    ##    module Foo extend self
    ##    end
    ## 
    ##    # good
    ##    module Foo
    ##      extend self
    ##    end
    ## 
  const
    MSG = "Place the first line of module body on its own line."
  method onModule*(self: TrailingBodyOnModule; node: Node): void =
    if isTrailingBody(node):
    addOffense(node, location = firstPartOf(node.toA.last()))

  method autocorrect*(self: TrailingBodyOnModule; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      LineBreakCorrector.correctTrailingBody(
          configuredWidth = configuredIndentationWidth, corrector = corrector,
          node = node, processedSource = processedSource))

