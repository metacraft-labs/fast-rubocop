
import
  statementModifier

cop :
  type
    WhileUntilModifier* = ref object of Cop
    ##  Checks for while and until statements that would fit on one line
    ##  if written as a modifier while/until. The maximum line length is
    ##  configured in the `Metrics/LineLength` cop.
    ## 
    ##  @example
    ##    # bad
    ##    while x < 10
    ##      x += 1
    ##    end
    ## 
    ##    # good
    ##    x += 1 while x < 10
    ## 
    ##  @example
    ##    # bad
    ##    until x > 10
    ##      x += 1
    ##    end
    ## 
    ##    # good
    ##    x += 1 until x > 10
  const
    MSG = """Favor modifier `%<keyword>s` usage when having a single-line body."""
  method onWhile*(self: WhileUntilModifier; node: Node): void =
    check(node)

  method onUntil*(self: WhileUntilModifier; node: Node): void =
    check(node)

  method autocorrect*(self: WhileUntilModifier; node: Node): void =
    var oneline = """(begin
  (send
    (send
      (lvar :node) :body) :source))(begin
  (send
    (send
      (lvar :node) :condition) :source))"""
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, oneline))

  method check*(self: WhileUntilModifier; node: Node): void =
    if node.isMultiline and isSingleLineAsModifier(node):
    addOffense(node, location = "keyword",
               message = format(MSG, keyword = node.keyword))

