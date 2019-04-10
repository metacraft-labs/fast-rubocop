
import
  statementModifier

cop :
  type
    IfUnlessModifier* = ref object of Cop
    ##  Checks for if and unless statements that would fit on one line
    ##  if written as a modifier if/unless. The maximum line length is
    ##  configured in the `Metrics/LineLength` cop. The tab size is configured
    ##  in the `IndentationWidth` of the `Layout/Tab` cop.
    ## 
    ##  @example
    ##    # bad
    ##    if condition
    ##      do_stuff(bar)
    ##    end
    ## 
    ##    unless qux.empty?
    ##      Foo.do_something
    ##    end
    ## 
    ##    # good
    ##    do_stuff(bar) if condition
    ##    Foo.do_something unless qux.empty?
  const
    MSG = """Favor modifier `%<keyword>s` usage when having a single-line body. Another good alternative is the usage of control flow `&&`/`||`."""
  const
    ASSIGNMENTTYPES = @["lvasgn", "casgn", "cvasgn", "gvasgn", "ivasgn", "masgn"]
  method onIf*(self: IfUnlessModifier; node: Node): void =
    if isEligibleNode(node):
    if isNamedCaptureInCondition(node):
      return
    addOffense(node, location = "keyword",
               message = format(MSG, keyword = node.keyword))

  method autocorrect*(self: IfUnlessModifier; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, toModifierForm(node)))

  method isNamedCaptureInCondition*(self: IfUnlessModifier; node: Node): void =
    node.condition.isMatchWithLvasgnType()

  method isEligibleNode*(self: IfUnlessModifier; node: Node): void =
    isNonEligibleIf(node).! and node.isChained.! and node.isNestedConditional.! and
        isSingleLineAsModifier(node)

  method isNonEligibleIf*(self: IfUnlessModifier; node: Node): void =
    node.isTernary or node.isModifierForm or node.isElsif or node.isElse

  method isParenthesize*(self: IfUnlessModifier; node: Node): void =
    if node.parent.isNil():
      return false
    if ASSIGNMENTTYPES.isInclude(node.parent.type):
      return true
    node.parent.isSendType() and node.parent.isParenthesized.!

  method toModifierForm*(self: IfUnlessModifier; node: Node): void =
    var expression = (node.body.source, node.keyword, node.condition.source,
                   firstLineComment(node)).compact.join(" ")
    if isParenthesize(node):
      """((lvar :expression))"""
  
  method firstLineComment*(self: IfUnlessModifier; node: Node): void =
    var comment = processedSource.findComment(proc (c: Comment): void =
      c.loc.line == node.loc.line)
    if comment:
      comment.loc.expression.source
  
