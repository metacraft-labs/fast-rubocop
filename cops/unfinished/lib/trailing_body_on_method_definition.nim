
import
  alignment

import
  trailingBody

cop :
  type
    TrailingBodyOnMethodDefinition* = ref object of Cop
    ##  This cop checks for trailing code after the method definition.
    ## 
    ##  @example
    ##    # bad
    ##    def some_method; do_stuff
    ##    end
    ## 
    ##    def f(x); b = foo
    ##      b[c: x]
    ##    end
    ## 
    ##    # good
    ##    def some_method
    ##      do_stuff
    ##    end
    ## 
    ##    def f(x)
    ##      b = foo
    ##      b[c: x]
    ##    end
    ## 
  const
    MSG = """Place the first line of a multi-line method definition's body on its own line."""
  method onDef*(self: TrailingBodyOnMethodDefinition; node: Node): void =
    if isTrailingBody(node):
    addOffense(node, location = firstPartOf(node.body))

  method autocorrect*(self: TrailingBodyOnMethodDefinition; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      LineBreakCorrector.correctTrailingBody(
          configuredWidth = configuredIndentationWidth, corrector = corrector,
          node = node, processedSource = processedSource))

