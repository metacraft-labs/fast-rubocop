
import
  alignment

cop :
  type
    TrailingMethodEndStatement* = ref object of Cop
    ##  This cop checks for trailing code after the method definition.
    ## 
    ##  @example
    ##    # bad
    ##    def some_method
    ##    do_stuff; end
    ## 
    ##    def do_this(x)
    ##      baz.map { |b| b.this(x) } end
    ## 
    ##    def foo
    ##      block do
    ##        bar
    ##      end end
    ## 
    ##    # good
    ##    def some_method
    ##      do_stuff
    ##    end
    ## 
    ##    def do_this(x)
    ##      baz.map { |b| b.this(x) }
    ##    end
    ## 
    ##    def foo
    ##      block do
    ##        bar
    ##      end
    ##    end
    ## 
  const
    MSG = """Place the end statement of a multi-line method on its own line."""
  method onDef*(self: TrailingMethodEndStatement; node: Node): void =
    if isTrailingEnd(node):
    addOffense(node.toA.last(), location = endToken(node).pos)

  method autocorrect*(self: TrailingMethodEndStatement; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      breakLineBeforeEnd(node, corrector)
      removeSemicolon(node, corrector))

  method isTrailingEnd*(self: TrailingMethodEndStatement; node: Node): void =
    node.body and node.isMultiline and isBodyAndEndOnSameLine(node)

  method endToken*(self: TrailingMethodEndStatement; node: Node): void =
    var @endToken = @endToken
        tokens(node).reverse().find(proc (it: void): void =
      it.isNd)

  method isBodyAndEndOnSameLine*(self: TrailingMethodEndStatement; node: Node): void =
    endToken(node).line == tokenBeforeEnd(node).line

  method tokenBeforeEnd*(self: TrailingMethodEndStatement; node: Node): void =
    var @tokenBeforeEnd = @tokenBeforeEnd
        try:
      var i = tokens(node).index(endToken(node))
    tokens(node)i - 1

  method breakLineBeforeEnd*(self: TrailingMethodEndStatement; node: Node;
                            corrector: Corrector): void =
    corrector.insertBefore(endToken(node).pos,
                           "\n" & " " * configuredIndentationWidth)

  method removeSemicolon*(self: TrailingMethodEndStatement; node: Node;
                         corrector: Corrector): void =
    if tokenBeforeEnd(node).isSemicolon:
    corrector.remove(tokenBeforeEnd(node).pos)

