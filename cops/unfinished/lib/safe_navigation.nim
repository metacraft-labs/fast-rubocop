
import
  sequtils

import
  rangeHelp

cop :
  type
    SafeNavigation* = ref object of Cop
    ##  This cop converts usages of `try!` to `&.`. It can also be configured
    ##  to convert `try`. It will convert code to use safe navigation if the
    ##  target Ruby version is set to 2.3+
    ## 
    ##  @example
    ##    # ConvertTry: false
    ##      # bad
    ##      foo.try!(:bar)
    ##      foo.try!(:bar, baz)
    ##      foo.try!(:bar) { |e| e.baz }
    ## 
    ##      foo.try!(:[], 0)
    ## 
    ##      # good
    ##      foo.try(:bar)
    ##      foo.try(:bar, baz)
    ##      foo.try(:bar) { |e| e.baz }
    ## 
    ##      foo&.bar
    ##      foo&.bar(baz)
    ##      foo&.bar { |e| e.baz }
    ## 
    ## 
    ##    # ConvertTry: true
    ##      # bad
    ##      foo.try!(:bar)
    ##      foo.try!(:bar, baz)
    ##      foo.try!(:bar) { |e| e.baz }
    ##      foo.try(:bar)
    ##      foo.try(:bar, baz)
    ##      foo.try(:bar) { |e| e.baz }
    ## 
    ##      # good
    ##      foo&.bar
    ##      foo&.bar(baz)
    ##      foo&.bar { |e| e.baz }
  const
    MSG = "Use safe navigation (`&.`) instead of `%<try>s`."
  nodeMatcher tryCall, "          (send !nil? ${:try :try!} $_ ...)\n"
  method onSend*(self: void; node: void): void =
    tryCall node:
      if tryMethod == "try" and copConfig["ConvertTry"].!:
        return
      if dispatch.isSymType and dispatch.value.=~():
      addOffense(node, message = format(MSG, try = tryMethod))

  method autocorrect*(self: void; node: void): void =
    var
      method = methodNode.source[]
      range = rangeBetween(node.loc.dot.beginPos, node.loc.expression.endPos)
    lambda(proc (corrector: void): void =
      corrector.replace(range, replacement(method, params)))

  method replacement*(self: void; method: void; params: void): void =
    var newParams = params.mapIt:
      it.ource.join(", ")
    if method.isEndWith("="):
      """&.(send
  (lvar :method) :[]
  (erange
    (int 0)
    (int -1))) = (lvar :new_params)"""
    elif params.isEmpty:
      """&.(lvar :method)"""
  
  extend(TargetRubyVersion)
  minimumTargetRubyVersion(0.0)
