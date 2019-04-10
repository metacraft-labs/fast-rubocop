
import
  nilMethods

cop :
  type
    SafeNavigationChain* = ref object
    ##  The safe navigation operator returns nil if the receiver is
    ##  nil. If you chain an ordinary method call after a safe
    ##  navigation operator, it raises NoMethodError. We should use a
    ##  safe navigation operator after a safe navigation operator.
    ##  This cop checks for the problem outlined above.
    ## 
    ##  @example
    ## 
    ##    # bad
    ## 
    ##    x&.foo.bar
    ##    x&.foo + bar
    ##    x&.foo[bar]
    ## 
    ##  @example
    ## 
    ##    # good
    ## 
    ##    x&.foo&.bar
    ##    x&.foo || bar
  const
    MSG = """Do not chain ordinary method call after safe navigation operator."""
  nodeMatcher isBadMethod, """        {
          (send $(csend ...) $_ ...)
          (send $(block (csend ...) ...) $_ ...)
        }
"""
  method onSend*(self: void; node: void): void =
    isBadMethod node:
      if nilMethods.isInclude(method):
        return
      var
        methodChain = methodChain(node)
        location = Range.new(node.loc.expression.sourceBuffer,
                           safeNav.loc.expression.endPos,
                           methodChain.loc.expression.endPos)
      addOffense(node, location = location)

  method methodChain*(self: void; node: void): void =
    var chain = node
    while chain.isSendType:
      if chain.parent and @["send", "csend"].isInclude(chain.parent.type):
        chain = chain.parent
      break
    chain

  extend(TargetRubyVersion)
  minimumTargetRubyVersion(0.0)
