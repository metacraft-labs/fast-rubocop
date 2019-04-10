
import
  statementModifier

cop :
  type
    IfUnlessModifierOfIfUnless* = ref object of Cop
    ##  Checks for if and unless statements used as modifiers of other if or
    ##  unless statements.
    ## 
    ##  @example
    ## 
    ##   # bad
    ##   tired? ? 'stop' : 'go faster' if running?
    ## 
    ##   # bad
    ##   if tired?
    ##     "please stop"
    ##   else
    ##     "keep going"
    ##   end if running?
    ## 
    ##   # good
    ##   if running?
    ##     tired? ? 'stop' : 'go faster'
    ##   end
  const
    MSG = "Avoid modifier `%<keyword>s` after another conditional."
  method onIf*(self: IfUnlessModifierOfIfUnless; node: Node): void =
    if node.isModifierForm and node.body.isIfType():
    addOffense(node, location = "keyword",
               message = format(MSG, keyword = node.keyword))

