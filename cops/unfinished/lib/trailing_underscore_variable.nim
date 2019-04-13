
import
  tables, sequtils

import
  surroundingSpace

import
  rangeHelp

cop :
  type
    TrailingUnderscoreVariable* = ref object of Cop
    ##  This cop checks for extra underscores in variable assignment.
    ## 
    ##  @example
    ##    # bad
    ##    a, b, _ = foo()
    ##    a, b, _, = foo()
    ##    a, _, _ = foo()
    ##    a, _, _, = foo()
    ## 
    ##    # good
    ##    a, b, = foo()
    ##    a, = foo()
    ##    *a, b, _ = foo()
    ##    # => We need to know to not include 2 variables in a
    ##    a, *b, _ = foo()
    ##    # => The correction `a, *b, = foo()` is a syntax error
    ## 
    ##    # good if AllowNamedUnderscoreVariables is true
    ##    a, b, _something = foo()
  const
    MSG = """Do not use trailing `_`s in parallel assignment. Prefer `%<code>s`."""
  const
    UNDERSCORE = "_"
  method onMasgn*(self: TrailingUnderscoreVariable; node: Node): void =
    var ranges = unneededRanges(node)
    for range in ranges:
      var
        goodCode = node.source
        offset = range.beginPos - node.sourceRange.beginPos
      goodCode.[]=(offset, range.size, "")
      addOffense(node, location = range, message = format(MSG, code = goodCode))

  method autocorrect*(self: TrailingUnderscoreVariable; node: Node): void =
    var ranges = unneededRanges(node)
    lambda(proc (corrector: Corrector): void =
      for range in ranges:
        if range:
          corrector.remove(range)
    )

  method findFirstOffense*(self: TrailingUnderscoreVariable; variables: Array): void =
    var firstOffense = findFirstPossibleOffense(variables.reverse())
    if firstOffense:
    if isSplatVariableBefore(firstOffense, variables):
      return
    firstOffense

  method findFirstPossibleOffense*(self: TrailingUnderscoreVariable;
                                  variables: Array): void =
    variables.reduce(proc (offense: Node; variable: Node): void =
      if @["lvasgn", "splat"].isInclude(variable.type):
      else:
        break
      var var = variable[0]
      var = var[0]
      if allowNamedUnderscoreVariables:
        if var == "_":
        else:
          break
      elif `$`().isStartWith(UNDERSCORE):
      else:
        break
      variable)

  method isSplatVariableBefore*(self: TrailingUnderscoreVariable;
                               firstOffense: Node; variables: Array): void =
    var firstOffenseIndex = reverseIndex(variables, firstOffense)
    variables[].anyIt:
      it.isPlatType

  method reverseIndex*(self: TrailingUnderscoreVariable; collection: Array;
                      item: Node): void =
    collection.size - 1 - collection.reverse().index(item)

  method allowNamedUnderscoreVariables*(self: TrailingUnderscoreVariable): void =
    var @allowNamedUnderscoreVariables = @allowNamedUnderscoreVariables
        copConfig["AllowNamedUnderscoreVariables"]

  method unneededRanges*(self: TrailingUnderscoreVariable; node: Node): void =
    if node.isMasgnType():
      var mlhsNode = node[0]
    else:
      mlhsNode = node
    var
      variables = @[]
      mainOffense = mainNodeOffense(node)
    if mainOffense.isNil():
      childrenOffenses(variables)
    else:
      childrenOffenses(variables).<<(mainOffense)
  
  method mainNodeOffense*(self: TrailingUnderscoreVariable; node: Node): void =
    if node.isMasgnType():
    else:
      var mlhsNode = node
    var
      variables = @[]
      firstOffense = findFirstOffense(variables)
    if firstOffense:
    if isUnusedVariablesOnly(firstOffense, variables):
      return unusedRange(node.type, mlhsNode, right)
    if Util.isParentheses(mlhsNode):
      return rangeForParentheses(firstOffense, mlhsNode)
    rangeBetween(firstOffense.sourceRange.beginPos, node.loc.operator.beginPos)

  method childrenOffenses*(self: TrailingUnderscoreVariable; variables: Array): void =
    variables.filterIt:
      it.isLhsType.flatMap(proc (v: Node): void =
      unneededRanges(v))

  method isUnusedVariablesOnly*(self: TrailingUnderscoreVariable; offense: Node;
                               variables: Array): void =
    offense.sourceRange == variables[0].sourceRange

  method unusedRange*(self: TrailingUnderscoreVariable; nodeType: Symbol;
                     mlhsNode: Node; right: Node): void =
    var
      startRange = mlhsNode.sourceRange.beginPos
      endRange = case nodeType
      of "masgn":
        right.sourceRange.beginPos
      of "mlhs":
        mlhsNode.sourceRange.endPos
      else:
    rangeBetween(startRange, endRange)

  method rangeForParentheses*(self: TrailingUnderscoreVariable; offense: Node;
                             left: Node): void =
    rangeBetween(offense.sourceRange.beginPos - 1, left.loc.expression.endPos - 1)

