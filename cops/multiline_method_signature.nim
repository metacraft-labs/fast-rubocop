
cop :
  type
    MultilineMethodSignature* = ref object of Cop
    ##  This cop checks for method signatures that span multiple lines.
    ## 
    ##  @example
    ## 
    ##    # good
    ## 
    ##    def foo(bar, baz)
    ##    end
    ## 
    ##    # bad
    ## 
    ##    def foo(bar,
    ##            baz)
    ##    end
    ## 
  const
    MSG = "Avoid multi-line method signatures."
  method onDef*(self: MultilineMethodSignature; node: Node): void =
    if node.isArguments:
    if openingLine(node) == closingLine(node):
      return
    if isCorrectionExceedsMaxLineLength(node):
      return
    addOffense(node)

  method openingLine*(self: MultilineMethodSignature; node: Node): void =
    node.firstLine

  method closingLine*(self: MultilineMethodSignature; node: Node): void =
    node.arguments.lastLine

  method isCorrectionExceedsMaxLineLength*(self: MultilineMethodSignature;
      node: Node): void =
    indentationWidth(node) & definitionWidth(node) > maxLineLength

  method indentationWidth*(self: MultilineMethodSignature; node: Node): void =
    processedSource.lineIndentation(node.loc.expression.line)

  method definitionWidth*(self: MultilineMethodSignature; node: Node): void =
    node.sourceRange.begin.join(node.arguments.sourceRange.end).length

  method maxLineLength*(self: MultilineMethodSignature): void =
    config.forCop("Metrics/LineLength")["Max"] or 80

