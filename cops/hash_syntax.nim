
import
  tables, sequtils

import
  configurableEnforcedStyle

import
  rangeHelp

cop :
  type
    HashSyntax* = ref object of Cop
    ##  This cop checks hash literal syntax.
    ## 
    ##  It can enforce either the use of the class hash rocket syntax or
    ##  the use of the newer Ruby 1.9 syntax (when applicable).
    ## 
    ##  A separate offense is registered for each problematic pair.
    ## 
    ##  The supported styles are:
    ## 
    ##  * ruby19 - forces use of the 1.9 syntax (e.g. `{a: 1}`) when hashes have
    ##    all symbols for keys
    ##  * hash_rockets - forces use of hash rockets for all hashes
    ##  * no_mixed_keys - simply checks for hashes with mixed syntaxes
    ##  * ruby19_no_mixed_keys - forces use of ruby 1.9 syntax and forbids mixed
    ##    syntax hashes
    ## 
    ##  @example EnforcedStyle: ruby19 (default)
    ##    # bad
    ##    {:a => 2}
    ##    {b: 1, :c => 2}
    ## 
    ##    # good
    ##    {a: 2, b: 1}
    ##    {:c => 2, 'd' => 2} # acceptable since 'd' isn't a symbol
    ##    {d: 1, 'e' => 2} # technically not forbidden
    ## 
    ##  @example EnforcedStyle: hash_rockets
    ##    # bad
    ##    {a: 1, b: 2}
    ##    {c: 1, 'd' => 5}
    ## 
    ##    # good
    ##    {:a => 1, :b => 2}
    ## 
    ##  @example EnforcedStyle: no_mixed_keys
    ##    # bad
    ##    {:a => 1, b: 2}
    ##    {c: 1, 'd' => 2}
    ## 
    ##    # good
    ##    {:a => 1, :b => 2}
    ##    {c: 1, d: 2}
    ## 
    ##  @example EnforcedStyle: ruby19_no_mixed_keys
    ##    # bad
    ##    {:a => 1, :b => 2}
    ##    {c: 2, 'd' => 3} # should just use hash rockets
    ## 
    ##    # good
    ##    {a: 1, b: 2}
    ##    {:c => 3, 'd' => 4}
  const
    MSG19 = "Use the new Ruby 1.9 hash syntax."
  const
    MSGNOMIXEDKEYS = "Don\'t mix styles in the same hash."
  const
    MSGHASHROCKETS = "Use hash rockets syntax."
  method onHash*(self: HashSyntax; node: Node): void =
    var pairs = node.pairs
    if pairs.isEmpty:
      return
    if style == "hash_rockets" or isForceHashRockets(pairs):
      hashRocketsCheck(pairs)
    elif style == "ruby19_no_mixed_keys":
      ruby19NoMixedKeysCheck(pairs)
    elif style == "no_mixed_keys":
      noMixedKeysCheck(pairs)
    else:
      ruby19Check(pairs)
  
  method ruby19Check*(self: HashSyntax; pairs: Array): void =
    if isSymIndices(pairs):
      check(pairs, "=>", MSG19)
  
  method hashRocketsCheck*(self: HashSyntax; pairs: Array): void =
    check(pairs, ":", MSGHASHROCKETS)

  method ruby19NoMixedKeysCheck*(self: HashSyntax; pairs: Array): void =
    if isForceHashRockets(pairs):
      check(pairs, ":", MSGHASHROCKETS)
    elif isSymIndices(pairs):
      check(pairs, "=>", MSG19)
    else:
      check(pairs, ":", MSGNOMIXEDKEYS)
  
  method noMixedKeysCheck*(self: HashSyntax; pairs: Array): void =
    if isSymIndices(pairs).!:
      check(pairs, ":", MSGNOMIXEDKEYS)
    else:
      check(pairs, pairs[0].inverseDelimiter, MSGNOMIXEDKEYS)
  
  method autocorrect*(self: HashSyntax; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      if style == "hash_rockets" or isForceHashRockets(node.parent.pairs):
        autocorrectHashRockets(corrector, node)
      elif style == "ruby19_no_mixed_keys" or style == "no_mixed_keys":
        autocorrectNoMixedKeys(corrector, node)
      else:
        autocorrectRuby19(corrector, node)
    )

  method alternativeStyle*(self: HashSyntax): void =
    case style
    of "hash_rockets":
      "ruby19"
    of "ruby19":
      "ruby19_no_mixed_keys"
    else:

  method isSymIndices*(self: HashSyntax; pairs: Array): void =
    pairs.allIt:
      isWordSymbolPair(it)

  method isWordSymbolPair*(self: HashSyntax; pair: Node): void =
    if pair.key.isSymType():
    else:
      return false
    isAcceptable19SyntaxSymbol(pair.key.source)

  method isAcceptable19SyntaxSymbol*(self: HashSyntax; symName: string): void =
    symName.sub!("")
    if copConfig["PreferHashRocketsForNonAlnumEndingSymbols"]:
      if symName.=~():
      else:
        return false
    if symName.=~():
      return true
    parse("""{ (lvar :sym_name): :foo }""").isValidSyntax

  method check*(self: HashSyntax; pairs: Array; delim: string; msg: string): void =
    for pair in pairs:
      if pair.delimiter == delim:
        var location = pair.sourceRange.begin.join(pair.loc.operator)
        addOffense(pair, location = location, message = msg, proc (): void =
          oppositeStyleDetected)

  method autocorrectRuby19*(self: HashSyntax; corrector: Corrector; pairNode: Node): void =
    var
      key = pairNode.key
      op = pairNode.loc.operator
      range = rangeBetween(key.sourceRange.beginPos, op.endPos)
    range = rangeWithSurroundingSpace(range = range, side = "right")
    var space = if isArgumentWithoutSpace(pairNode.parent):
      " "
    corrector.replace(range, range.source.sub(`$`() & "\\1: "))

  method isArgumentWithoutSpace*(self: HashSyntax; node: Node): void =
    node.isArgument and
        node.loc.expression.beginPos == node.parent.loc.selector.endPos

  method autocorrectHashRockets*(self: HashSyntax; corrector: Corrector;
                                pairNode: Node): void =
    var
      key = pairNode.key.sourceRange
      op = pairNode.loc.operator
    corrector.insertAfter(key, pairNode.inverseDelimiter(true))
    corrector.insertBefore(key, ":")
    corrector.remove(rangeWithSurroundingSpace(range = op))

  method autocorrectNoMixedKeys*(self: HashSyntax; corrector: Corrector;
                                pairNode: Node): void =
    if pairNode.isColon:
      autocorrectHashRockets(corrector, pairNode)
    else:
      autocorrectRuby19(corrector, pairNode)
  
  method isForceHashRockets*(self: HashSyntax; pairs: Array): void =
    copConfig["UseHashRocketsWithSymbolValues"] and
        pairs.mapIt:
      it.alue.anyIt:
      it.isYmType

