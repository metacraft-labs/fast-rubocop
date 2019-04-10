
import
  alignment

import
  trailingBody

cop :
  type
    TrailingBodyOnClass* = ref object of Cop
    ##  This cop checks for trailing code after the class definition.
    ## 
    ##  @example
    ##    # bad
    ##    class Foo; def foo; end
    ##    end
    ## 
    ##    # good
    ##    class Foo
    ##      def foo; end
    ##    end
    ## 
  const
    MSG = "Place the first line of class body on its own line."
  method onClass*(self: TrailingBodyOnClass; node: Node): void =
    if isTrailingBody(node):
    addOffense(node, location = firstPartOf(node.toA.last()))

  method autocorrect*(self: TrailingBodyOnClass; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      LineBreakCorrector.correctTrailingBody(
          configuredWidth = configuredIndentationWidth, corrector = corrector,
          node = node, processedSource = processedSource))

