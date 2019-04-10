
import
  sequtils

import
  statementModifier

import
  alignment

cop :
  type
    MultilineIfModifier* = ref object of Cop
    ##  Checks for uses of if/unless modifiers with multiple-lines bodies.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    {
    ##      result: 'this should not happen'
    ##    } unless cond
    ## 
    ##    # good
    ##    { result: 'ok' } if cond
  const
    MSG = """Favor a normal %<keyword>s-statement over a modifier clause in a multiline statement."""
  method onIf*(self: MultilineIfModifier; node: Node): void =
    if node.isModifierForm and node.body.isMultiline:
    addOffense(node)

  method autocorrect*(self: MultilineIfModifier; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, toNormalIf(node)))

  method message*(self: MultilineIfModifier; node: Node): void =
    format(MSG, keyword = node.keyword)

  method toNormalIf*(self: MultilineIfModifier; node: Node): void =
    var
      indentedBody = indentedBody(node.body, node)
      condition = """(send
  (lvar :node) :keyword) (send
  (send
    (lvar :node) :condition) :source)"""
      indentedEnd = """(send nil :offset
  (lvar :node))end"""
    @[condition, indentedBody, indentedEnd].join("\n")

  method configuredIndentationWidth*(self: MultilineIfModifier): void =
    super or 2

  method indentedBody*(self: MultilineIfModifier; body: Node; node: Node): void =
    var bodySource = """(send nil :offset
  (lvar :node))(send
  (lvar :body) :source)"""
    bodySource.eachLine().mapIt:
      if it == "\n":
        it
      else:
        it.sub(indentation(node))
    .join

