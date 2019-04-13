
cop :
  type
    NonNilCheck* = ref object of Cop
    ##  This cop checks for non-nil checks, which are usually redundant.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    if x != nil
    ##    end
    ## 
    ##    # good (when not allowing semantic changes)
    ##    # bad (when allowing semantic changes)
    ##    if !x.nil?
    ##    end
    ## 
    ##    # good (when allowing semantic changes)
    ##    if x
    ##    end
    ## 
    ##  Non-nil checks are allowed if they are the final nodes of predicate.
    ## 
    ##    # good
    ##    def signed_in?
    ##      !current_user.nil?
    ##    end
  nodeMatcher isNotEqualToNil, "(send _ :!= nil)"
  nodeMatcher isUnlessCheck, "(if (send _ :nil?) ...)"
  nodeMatcher isNilCheck, "(send _ :nil?)"
  nodeMatcher isNotAndNilCheck, "(send (send _ :nil?) :!)"
  method onSend*(self: NonNilCheck; node: Node): void =
    if isIgnoredNode(node):
      return
    if isNotEqualToNil node:
      addOffense(node, location = "selector")
    elif isIncludeSemanticChanges and
      isNotAndNilCheck node or isUnlessAndNilCheck(node):
      addOffense(node)
  
  method onDef*(self: NonNilCheck; node: Node): void =
    var body = node.body
    if node.isPredicateMethod and body:
    if body.isBeginType():
      ignoreNode(body.children.last())
    else:
      ignoreNode(body)
  
  method autocorrect*(self: NonNilCheck; node: Node): void =
    case node.methodName
    of "!=":
      autocorrectComparison(node)
    of "!":
      autocorrectNonNil(node, node.receiver)
    of "nil?":
      autocorrectUnlessNil(node, node.receiver)
    else:

  method isUnlessAndNilCheck*(self: NonNilCheck; sendNode: Node): void =
    var parent = sendNode.parent
    isNilCheck sendNode and isUnlessCheck parent and parent.isTernary.! and
        parent.isUnless

  method message*(self: NonNilCheck; node: Node): void =
    if node.isMethod("!="):
      "Prefer `!expression.nil?` over `expression != nil`."
  
  method isIncludeSemanticChanges*(self: NonNilCheck): void =
    copConfig["IncludeSemanticChanges"]

  method autocorrectComparison*(self: NonNilCheck; node: Node): void =
    var
      expr = node.source
      newCode = if isIncludeSemanticChanges:
        expr.sub("")
      else:
        expr.sub("!\\1.nil?")
    if expr == newCode:
      return
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, newCode))

  method autocorrectNonNil*(self: NonNilCheck; node: Node; innerNode: Node): void =
    lambda(proc (corrector: Corrector): void =
      if innerNode.receiver:
        corrector.replace(node.sourceRange, innerNode.receiver.source)
      else:
        corrector.replace(node.sourceRange, "self")
    )

  method autocorrectUnlessNil*(self: NonNilCheck; node: Node; receiver: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.parent.loc.keyword, "if")
      corrector.replace(node.sourceRange, receiver.source))

