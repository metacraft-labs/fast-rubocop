
import
  frozenStringLiteral

import
  rangeHelp

cop :
  type
    EmptyLiteral* = ref object of Cop
    ##  This cop checks for the use of a method, the result of which
    ##  would be a literal, like an empty array, hash, or string.
    ## 
    ##  @example
    ##    # bad
    ##    a = Array.new
    ##    h = Hash.new
    ##    s = String.new
    ## 
    ##    # good
    ##    a = []
    ##    h = {}
    ##    s = ''
  const
    ARRMSG = "Use array literal `[]` instead of `Array.new`."
  const
    HASHMSG = "Use hash literal `{}` instead of `Hash.new`."
  const
    STRMSG = """Use string literal `%<prefer>s` instead of `String.new`."""
  nodeMatcher arrayNode, "(send (const nil? :Array) :new)"
  nodeMatcher hashNode, "(send (const nil? :Hash) :new)"
  nodeMatcher strNode, "(send (const nil? :String) :new)"
  nodeMatcher arrayWithBlock, "(block (send (const nil? :Array) :new) args _)"
  nodeMatcher hashWithBlock, "(block (send (const nil? :Hash) :new) args _)"
  method onSend*(self: EmptyLiteral; node: Node): void =
    if isOffenseArrayNode(node):
      addOffense(node, message = ARRMSG)
    if isOffenseHashNode(node):
      addOffense(node, message = HASHMSG)
    strNode node:
      if isFrozenStringLiteralsEnabled:
        return
      addOffense(node, message = format(STRMSG, prefer = preferredStringLiteral))

  method autocorrect*(self: EmptyLiteral; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(replacementRange(node), correction(node)))

  method preferredStringLiteral*(self: EmptyLiteral): void =
    if isEnforceDoubleQuotes:
      "\"\""
  
  method isEnforceDoubleQuotes*(self: EmptyLiteral): void =
    stringLiteralsConfig["EnforcedStyle"] == "double_quotes"

  method stringLiteralsConfig*(self: EmptyLiteral): void =
    config.forCop("Style/StringLiterals")

  method isFirstArgumentUnparenthesized*(self: EmptyLiteral; node: Node): void =
    var parent = node.parent
    if parent and @["send", "super", "zsuper"].isInclude(parent.type):
    else:
      return false
    node.objectId() == parent.arguments[0].objectId() and
        isParentheses(node.parent).!

  method replacementRange*(self: EmptyLiteral; node: Node): void =
    if hashNode node and isFirstArgumentUnparenthesized(node):
      var args = node.parent.arguments
      rangeBetween(args[0].loc.expression.beginPos - 1,
                   args[-1].loc.expression.endPos)
    else:
      node.sourceRange
  
  method isOffenseArrayNode*(self: EmptyLiteral; node: Node): void =
    arrayNode node and arrayWithBlock node.parent.!

  method isOffenseHashNode*(self: EmptyLiteral; node: Node): void =
    hashNode node and hashWithBlock node.parent.!

  method correction*(self: EmptyLiteral; node: Node): void =
    if isOffenseArrayNode(node):
      "[]"
    elif strNode node:
      preferredStringLiteral
    elif isOffenseHashNode(node):
      if isFirstArgumentUnparenthesized(node):
        var args = node.parent.arguments
        """((send
  (send
    (send
      (send
        (lvar :args) :[]
        (irange
          (int 1)
          (int -1))) :map
      (block-pass
        (sym :source))) :unshift
    (str "{}")) :join
  (str ", ")))"""
  
