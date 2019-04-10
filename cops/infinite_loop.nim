
import
  sequtils

cop :
  type
    InfiniteLoop* = ref object of Cop
    ##  Use `Kernel#loop` for infinite loops.
    ## 
    ##  @example
    ##    # bad
    ##    while true
    ##      work
    ##    end
    ## 
    ##    # good
    ##    loop do
    ##      work
    ##    end
  const
    LEADINGSPACE
  const
    MSG = "Use `Kernel#loop` for infinite loops."
  method isJoinForce*(self: InfiniteLoop; forceClass: Class): void =
    forceClass == VariableForce

  method afterLeavingScope*(self: InfiniteLoop; scope: Scope;
                           _variableTable: VariableTable): void =
    var @variables = @variables @[]
    self.variables.concat(scope.variables.values())

  method onWhile*(self: InfiniteLoop; node: Node): void =
    if node.condition.isTruthyLiteral:
      whileOrUntil(node)
  
  method onUntil*(self: InfiniteLoop; node: Node): void =
    if node.condition.isFalseyLiteral:
      whileOrUntil(node)
  
  method autocorrect*(self: InfiniteLoop; node: Node): void =
    if node.isWhilePostType() or node.isUntilPostType():
      replaceBeginEndWithModifier(node)
    elif node.isModifierForm:
      replaceSource(node.sourceRange, modifierReplacement(node))
    else:
      replaceSource(nonModifierRange(node), "loop do")
  
  method whileOrUntil*(self: InfiniteLoop; node: Node): void =
    var range = node.sourceRange
    if self.variables.anyIt:
      isAssignedInsideLoop(it, range) and isAssignedBeforeLoop(it, range).! and
          isReferencedAfterLoop(it, range):
      return
    addOffense(node, location = "keyword")

  method isAssignedInsideLoop*(self: InfiniteLoop; var: Variable; range: Range): void =
    var.assignments.anyIt:
      range.isContains(it.node.sourceRange)

  method isAssignedBeforeLoop*(self: InfiniteLoop; var: Variable; range: Range): void =
    var b = range.beginPos
    var.assignments.anyIt:
      it.node.sourceRange.endPos < b

  method isReferencedAfterLoop*(self: InfiniteLoop; var: Variable; range: Range): void =
    var e = range.endPos
    var.references.anyIt:
      it.node.sourceRange.beginPos > e

  method replaceBeginEndWithModifier*(self: InfiniteLoop; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.body.loc.begin, "loop do")
      corrector.remove(node.body.loc.end.end.join(node.sourceRange.end)))

  method replaceSource*(self: InfiniteLoop; range: Range; replacement: string): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(range, replacement))

  method modifierReplacement*(self: InfiniteLoop; node: Node): void =
    if node.isSingleLine:
      "loop { " & node.body.source & " }"
    else:
      var indentation = node.body.loc.expression.sourceLine[LEADINGSPACE]
      ("loop do", node.body.source.gsub(configuredIndent), "end").join("""
(lvar :indentation)""")

  method nonModifierRange*(self: InfiniteLoop; node: Node): void =
    var
      startRange = node.loc.keyword.begin
      endRange = if node.isDo:
        node.loc.begin.end
      else:
        node.condition.sourceRange.end
    startRange.join(endRange)

  method configuredIndent*(self: InfiniteLoop): void =
    " " * config.forCop("IndentationWidth")["Width"]

