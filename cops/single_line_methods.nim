
import
  alignment

cop :
  type
    SingleLineMethods* = ref object of Cop
    ##  This cop checks for single-line method definitions that contain a body.
    ##  It will accept single-line methods with no body.
    ## 
    ##  @example
    ##    # bad
    ##    def some_method; body end
    ##    def link_to(url); {:name => url}; end
    ##    def @table.columns; super; end
    ## 
    ##    # good
    ##    def no_op; end
    ##    def self.resource_class=(klass); end
    ##    def @table.columns; end
    ## 
  const
    MSG = "Avoid single-line method definitions."
  method onDef*(self: SingleLineMethods; node: Node): void =
    if node.isSingleLine:
    if isAllowEmpty and node.body.!:
      return
    addOffense(node)

  method autocorrect*(self: SingleLineMethods; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      eachPart(node.body, proc (part: Range): void =
        LineBreakCorrector.breakLineBefore(range = part, node = node,
            corrector = corrector, configuredWidth = configuredIndentationWidth))
      LineBreakCorrector.breakLineBefore(range = node.loc.end, node = node,
          corrector = corrector, indentSteps = 0,
          configuredWidth = configuredIndentationWidth)
      moveComment(node, corrector))

  method isAllowEmpty*(self: SingleLineMethods): void =
    copConfig["AllowIfMethodIsEmpty"]

  iterator eachPart*(self: SingleLineMethods; body: NilClass): void =
    if body:
    if body.isBeginType():
      body.eachChildNode(proc (part: Node): void =
        yield part.sourceRange)
    else:
      yield body.sourceRange
  
  method moveComment*(self: SingleLineMethods; node: Node; corrector: Corrector): void =
    LineBreakCorrector.moveComment(eolComment = endOfLineComment(
        node.sourceRange.line), node = node, corrector = corrector)

