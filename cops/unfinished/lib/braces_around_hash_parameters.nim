
import
  strutils

import
  configurableEnforcedStyle

import
  rangeHelp

cop :
  type
    BracesAroundHashParameters* = ref object of Cop
    ##  This cop checks for braces around the last parameter in a method call
    ##  if the last parameter is a hash.
    ##  It supports `braces`, `no_braces` and `context_dependent` styles.
    ## 
    ##  @example EnforcedStyle: braces
    ##    # The `braces` style enforces braces around all method
    ##    # parameters that are hashes.
    ## 
    ##    # bad
    ##    some_method(x, y, a: 1, b: 2)
    ## 
    ##    # good
    ##    some_method(x, y, {a: 1, b: 2})
    ## 
    ##  @example EnforcedStyle: no_braces (default)
    ##    # The `no_braces` style checks that the last parameter doesn't
    ##    # have braces around it.
    ## 
    ##    # bad
    ##    some_method(x, y, {a: 1, b: 2})
    ## 
    ##    # good
    ##    some_method(x, y, a: 1, b: 2)
    ## 
    ##  @example EnforcedStyle: context_dependent
    ##    # The `context_dependent` style checks that the last parameter
    ##    # doesn't have braces around it, but requires braces if the
    ##    # second to last parameter is also a hash literal.
    ## 
    ##    # bad
    ##    some_method(x, y, {a: 1, b: 2})
    ##    some_method(x, y, {a: 1, b: 2}, a: 1, b: 2)
    ## 
    ##    # good
    ##    some_method(x, y, a: 1, b: 2)
    ##    some_method(x, y, {a: 1, b: 2}, {a: 1, b: 2})
  const
    MSG = "%<type>s curly braces around a hash parameter."
  method onSend*(self: BracesAroundHashParameters; node: Node): void =
    if node.isAssignmentMethod or node.isOperatorMethod:
      return
    if node.isArguments and node.lastArgument.isHashType() and
        node.lastArgument.isEmpty.!:
    check(node.lastArgument, node.arguments)

  method autocorrect*(self: BracesAroundHashParameters; sendNode: Node): void =
    ##  We let AutocorrectUnlessChangingAST#autocorrect work with the send
    ##  node, because that context is needed. When parsing the code to see if
    ##  the AST has changed, a braceless hash would not be parsed as a hash
    ##  otherwise.
    var hashNode = sendNode.lastArgument
    lambda(proc (corrector: Corrector): void =
      if hashNode.isBraces:
        removeBracesWithWhitespace(corrector, hashNode, extraSpace(hashNode))
      else:
        addBraces(corrector, hashNode)
    )

  method check*(self: BracesAroundHashParameters; arg: Node; args: Array): void =
    if style == "braces" and arg.isBraces.!:
      addArgOffense(arg, "missing")
    elif style == "no_braces" and arg.isBraces:
      addArgOffense(arg, "redundant")
    elif style == "context_dependent":
      checkContextDependent(arg, args)
  
  method checkContextDependent*(self: BracesAroundHashParameters; arg: Node;
                               args: Array): void =
    var bracesAroundSecondFromEnd = args.size > 1 and args[-2].isHashType()
    if arg.isBraces:
      if bracesAroundSecondFromEnd:
      else:
        addArgOffense(arg, "redundant")
    elif bracesAroundSecondFromEnd:
      addArgOffense(arg, "missing")
  
  method addArgOffense*(self: BracesAroundHashParameters; arg: Node; type: Symbol): void =
    addOffense(arg.parent, location = arg.sourceRange,
               message = format(MSG, type = `$`().capitalizeAscii()))

  method extraSpace*(self: BracesAroundHashParameters; hashNode: Node): void =
    {"newlines": isExtraLeftSpace(hashNode) and isExtraRightSpace(hashNode),
     "left": isExtraLeftSpace(hashNode), "right": isExtraRightSpace(hashNode)}.newTable()

  method isExtraLeftSpace*(self: BracesAroundHashParameters; hashNode: Node): void =
    var @extraLeftSpace = @extraLeftSpace
        try:
      var topLine = hashNode.sourceRange.sourceLine
    topLine.delete(" ")"{"

  method isExtraRightSpace*(self: BracesAroundHashParameters; hashNode: Node): void =
    var @extraRightSpace = @extraRightSpace
        try:
      var bottomLineNumber = hashNode.sourceRange.lastLine
    bottomLineprocessedSource.lines[bottomLineNumber - 1]

  method removeBracesWithWhitespace*(self: BracesAroundHashParameters;
                                    corrector: Corrector; node: Node; space: Hash): void =
    if node.isMultiline:
      removeBracesWithRange(corrector, leftWholeLineRange(node.loc.begin),
                            rightWholeLineRange(node.loc.end))
    else:
      var
        rightBraceAndSpace = rightBraceAndSpace(node.loc.end, space)
        leftBraceAndSpace = leftBraceAndSpace(node.loc.begin, space)
      removeBracesWithRange(corrector, leftBraceAndSpace, rightBraceAndSpace)

  method removeBracesWithRange*(self: BracesAroundHashParameters;
                               corrector: Corrector; leftRange: Range;
                               rightRange: Range): void =
    corrector.remove(leftRange)
    corrector.remove(rightRange)

  method leftWholeLineRange*(self: BracesAroundHashParameters; locBegin: Range): void =
    if rangeByWholeLines(locBegin).source.strip() == "{":
      rangeByWholeLines(locBegin, includeFinalNewline = true)
  
  method rightWholeLineRange*(self: BracesAroundHashParameters; locEnd: Range): void =
    if rangeByWholeLines(locEnd).source.strip().=~():
      rangeByWholeLines(locEnd, includeFinalNewline = true)
  
  method leftBraceAndSpace*(self: BracesAroundHashParameters; locBegin: Range;
                           space: Hash): void =
    rangeWithSurroundingSpace(range = locBegin, side = "right",
                              newlines = space["newlines"],
                              whitespace = space["left"])

  method rightBraceAndSpace*(self: BracesAroundHashParameters; locEnd: Range;
                            space: Hash): void =
    var braceAndSpace = rangeWithSurroundingSpace(range = locEnd, side = "left",
        newlines = space["newlines"], whitespace = space["right"])
    rangeWithSurroundingComma(braceAndSpace, "left")

  method addBraces*(self: BracesAroundHashParameters; corrector: Corrector;
                   node: Node): void =
    corrector.insertBefore(node.sourceRange, "{")
    corrector.insertAfter(node.sourceRange, "}")

