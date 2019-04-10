
import
  sequtils

import
  configurableEnforcedStyle

cop :
  type
    EmptyMethod* = ref object of Cop
    ##  This cop checks for the formatting of empty method definitions.
    ##  By default it enforces empty method definitions to go on a single
    ##  line (compact style), but it can be configured to enforce the `end`
    ##  to go on its own line (expanded style).
    ## 
    ##  Note: A method definition is not considered empty if it contains
    ##        comments.
    ## 
    ##  @example EnforcedStyle: compact (default)
    ##    # bad
    ##    def foo(bar)
    ##    end
    ## 
    ##    def self.foo(bar)
    ##    end
    ## 
    ##    # good
    ##    def foo(bar); end
    ## 
    ##    def foo(bar)
    ##      # baz
    ##    end
    ## 
    ##    def self.foo(bar); end
    ## 
    ##  @example EnforcedStyle: expanded
    ##    # bad
    ##    def foo(bar); end
    ## 
    ##    def self.foo(bar); end
    ## 
    ##    # good
    ##    def foo(bar)
    ##    end
    ## 
    ##    def self.foo(bar)
    ##    end
  const
    MSGCOMPACT = "Put empty method definitions on a single line."
  const
    MSGEXPANDED = """Put the `end` of empty method definitions on the next line."""
  method onDef*(self: EmptyMethod; node: Node): void =
    if node.body or isCommentLines(node):
      return
    if isCorrectStyle(node):
      return
    addOffense(node)

  method autocorrect*(self: EmptyMethod; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, corrected(node)))

  method message*(self: EmptyMethod; _node: Node): void =
    if isCompactStyle:
      MSGCOMPACT
  
  method isCorrectStyle*(self: EmptyMethod; node: Node): void =
    isCompactStyle and isCompact(node) or isExpandedStyle and isExpanded(node)

  method corrected*(self: EmptyMethod; node: Node): void =
    var
      hasParentheses = isParentheses(node.arguments)
      arguments = if node.isArguments:
        node.arguments.source
      extraSpace = if node.isArguments and hasParentheses.!:
        " "
      scope = if node.receiver:
        """(send
  (send
    (lvar :node) :receiver) :source)."""
      signature = (scope, node.methodName, extraSpace, arguments).join()
    ("""def (lvar :signature)""", "end").join(joint(node))

  method joint*(self: EmptyMethod; node: Node): void =
    var indent = " " * node.loc.column
    if isCompactStyle:
      "; "
  
  method isCommentLines*(self: EmptyMethod; node: Node): void =
    processedSource[lineRange(node)].anyIt:
      isCommentLine(it)

  method isCompact*(self: EmptyMethod; node: Node): void =
    node.isSingleLine

  method isExpanded*(self: EmptyMethod; node: Node): void =
    node.isMultiline

  method isCompactStyle*(self: EmptyMethod): void =
    style == "compact"

  method isExpandedStyle*(self: EmptyMethod): void =
    style == "expanded"

