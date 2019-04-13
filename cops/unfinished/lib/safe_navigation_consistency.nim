
import
  tables, sequtils

import
  ignoredNode

import
  nilMethods

cop :
  type
    SafeNavigationConsistency* = ref object
    ##  This cop check to make sure that if safe navigation is used for a method
    ##  call in an `&&` or `||` condition that safe navigation is used for all
    ##  method calls on that same object.
    ## 
    ##  @example
    ##    # bad
    ##    foo&.bar && foo.baz
    ## 
    ##    # bad
    ##    foo.bar || foo&.baz
    ## 
    ##    # bad
    ##    foo&.bar && (foobar.baz || foo.baz)
    ## 
    ##    # good
    ##    foo.bar && foo.baz
    ## 
    ##    # good
    ##    foo&.bar || foo&.baz
    ## 
    ##    # good
    ##    foo&.bar && (foobar.baz || foo&.baz)
    ## 
  const
    MSG = """Ensure that safe navigation is used consistently inside of `&&` and `||`."""
  method onCsend*(self: void; node: void): void =
    if node.parent and node.parent.isOperatorKeyword:
    check(node)

  method check*(self: void; node: void): void =
    var
      ancestor = topConditionalAncestor(node)
      conditions = ancestor.conditions
      safeNavReceiver = node.receiver
      methodCalls = conditions.filterIt:
        it.isEndType
      unsafeMethodCalls = unsafeMethodCalls(methodCalls, safeNavReceiver)
    for unsafeMethodCall in unsafeMethodCalls:
      var location = node.loc.expression.join(unsafeMethodCall.loc.expression)
      addOffense(unsafeMethodCall, location = location)
      ignoreNode(unsafeMethodCall)

  method autocorrect*(self: void; node: void): void =
    if node.isDot:
    lambda(proc (corrector: void): void =
      corrector.insertBefore(node.loc.dot, "&"))

  method topConditionalAncestor*(self: void; node: void): void =
    var parent = node.parent
    if parent and
      parent.isOperatorKeyword or
        parent.isBeginType and parent.parent and parent.parent.isOperatorKeyword:
    else:
      return node
    topConditionalAncestor(parent)

  method unsafeMethodCalls*(self: void; methodCalls: void; safeNavReceiver: void): void =
    methodCalls.filterIt:
      safeNavReceiver == it.receiver and nilMethods.isInclude(it.methodName).! and
          isIgnoredNode(it).!

