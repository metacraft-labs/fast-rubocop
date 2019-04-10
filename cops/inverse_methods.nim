
import
  ignoredNode

cop :
  type
    InverseMethods* = ref object of Cop
    ##  This cop check for usages of not (`not` or `!`) called on a method
    ##  when an inverse of that method can be used instead.
    ##  Methods that can be inverted by a not (`not` or `!`) should be defined
    ##  in `InverseMethods`
    ##  Methods that are inverted by inverting the return
    ##  of the block that is passed to the method should be defined in
    ##  `InverseBlocks`
    ## 
    ##  @example
    ##    # bad
    ##    !foo.none?
    ##    !foo.any? { |f| f.even? }
    ##    !foo.blank?
    ##    !(foo == bar)
    ##    foo.select { |f| !f.even? }
    ##    foo.reject { |f| f != 7 }
    ## 
    ##    # good
    ##    foo.none?
    ##    foo.blank?
    ##    foo.any? { |f| f.even? }
    ##    foo != bar
    ##    foo == bar
    ##    !!('foo' =~ /^\w+$/)
    ##    !(foo.class < Numeric) # Checking class hierarchy is allowed
  const
    MSG = "Use `%<inverse>s` instead of inverting `%<method>s`."
  const
    CLASSCOMPARISONMETHODS = @["<=", ">=", "<", ">"]
  const
    EQUALITYMETHODS = @["==", "!=", "=~", "!~", "<=", ">=", "<", ">"]
  const
    NEGATEDEQUALITYMETHODS = @["!=", "!~"]
  const
    CAMELCASE
  nodeMatcher isInverseCandidate, """          {
            (send $(send $(...) $_ $...) :!)
            (send (block $(send $(...) $_) $...) :!)
            (send (begin $(send $(...) $_ $...)) :!)
          }
"""
  nodeMatcher isInverseBlock, """          (block $(send (...) $_) ... { $(send ... :!)
                                        $(send (...) {:!= :!~} ...)
                                        (begin ... $(send ... :!))
                                        (begin ... $(send (...) {:!= :!~} ...))
                                      })
"""
  method onSend*(self: InverseMethods; node: Node): void =
    if isPartOfIgnoredNode(node):
      return
    isInverseCandidate node:
      if inverseMethods.isKey(method):
      if isPossibleClassHierarchyCheck(lhs, rhs, method):
        return
      if isNegated(node):
        return
      addOffense(node, message = format(MSG, method = method,
                                     inverse = inverseMethods[method]))

  method onBlock*(self: InverseMethods; node: Node): void =
    isInverseBlock node:
      if inverseBlocks.isKey(method):
      if isNegated(node) and isNegated(node.parent):
        return
      ignoreNode(block)
      addOffense(node, message = format(MSG, method = method,
                                     inverse = inverseBlocks[method]))

  method autocorrect*(self: InverseMethods; node: Node): void =
    if methodCall and method:
      lambda(proc (corrector: Corrector): void =
        corrector.remove(notToReceiver(node, methodCall))
        corrector.replace(methodCall.loc.selector, `$`())
        if EQUALITYMETHODS.isInclude(method):
          corrector.remove(endParentheses(node, methodCall))
      )
    else:
      correctInverseBlock(node)
  
  method correctInverseBlock*(self: InverseMethods; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(methodCall.loc.selector, `$`())
      correctInverseSelector(block, corrector))

  method correctInverseSelector*(self: InverseMethods; block: Node;
                                corrector: Corrector): void =
    var selector = block.loc.selector.source
    if NEGATEDEQUALITYMETHODS.isInclude(selector.toSym()):
      selector.[]=(0, "=")
      corrector.replace(block.loc.selector, selector)
    else:
      corrector.remove(block.loc.selector)
  
  method inverseMethods*(self: InverseMethods): void =
    var @inverseMethods = @inverseMethods
        copConfig["InverseMethods"].merge(copConfig["InverseMethods"].invert())

  method inverseBlocks*(self: InverseMethods): void =
    var @inverseBlocks = @inverseBlocks
        copConfig["InverseBlocks"].merge(copConfig["InverseBlocks"].invert())

  method isNegated*(self: InverseMethods; node: Node): void =
    node.parent.isRespondTo("method?") and node.parent.isMethod("!")

  method notToReceiver*(self: InverseMethods; node: Node; methodCall: Node): void =
    Range.new(node.loc.expression.sourceBuffer, node.loc.selector.beginPos,
              methodCall.loc.expression.beginPos)

  method endParentheses*(self: InverseMethods; node: Node; methodCall: Node): void =
    Range.new(node.loc.expression.sourceBuffer, methodCall.loc.expression.endPos,
              node.loc.expression.endPos)

  method isPossibleClassHierarchyCheck*(self: InverseMethods; lhs: Node; rhs: Array;
                                       method: Symbol): void =
    ##  When comparing classes, `!(Integer < Numeric)` is not the same as
    ##  `Integer > Numeric`.
    CLASSCOMPARISONMETHODS.isInclude(method) and
      isCamelCaseConstant(lhs) or
        rhs.size == 1 and isCamelCaseConstant(rhs[0])

  method isCamelCaseConstant*(self: InverseMethods; node: Node): void =
    node.isConstType() and node.source.=~(CAMELCASE)

