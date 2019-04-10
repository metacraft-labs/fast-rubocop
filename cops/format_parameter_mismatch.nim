
import
  sequtils

cop :
  type
    FormatParameterMismatch* = ref object of Cop
  const
    MSG = """Number of arguments (%<arg_num>i) to `%<method>s` doesn't match the number of fields (%<field_num>i)."""
  const
    FIELDREGEX
  const
    NAMEDFIELDREGEX
  const
    KERNEL = "Kernel"
  const
    SHOVEL = "<<"
  const
    PERCENT = "%"
  const
    PERCENTPERCENT = "%%"
  const
    DIGITDOLLARFLAG
  const
    STRINGTYPES = @["str", "dstr"]
  const
    NAMEDINTERPOLATION
  method onSend*(self: FormatParameterMismatch; node: Node): void =
    if isOffendingNode(node):
    addOffense(node, location = "selector")

  method isOffendingNode*(self: FormatParameterMismatch; node: Node): void =
    if isCalledOnString(node):
    else:
      return false
    if isMethodWithFormatArgs(node):
    else:
      return false
    if isNamedMode(node) or isSplatArgs(node):
      return false
    if numOfFormatArgs == "unknown":
      return false
    isMatchedArgumentsCount(numOfExpectedFields, numOfFormatArgs)

  method isMatchedArgumentsCount*(self: FormatParameterMismatch; expected: Integer;
                                 passed: Integer): void =
    if passed < 0:
      expected < passed.abs
    else:
      expected != passed
  
  method isCalledOnString*(self: FormatParameterMismatch; node: Node): void =
    if receiverNode.isNil() or receiverNode.isConstType():
      formatString and formatString.isStrType()
    else:
      receiverNode.isStrType()
  
  method isMethodWithFormatArgs*(self: FormatParameterMismatch; node: Node): void =
    isSprintf(node) or isFormat(node) or isPercent(node)

  method isNamedMode*(self: FormatParameterMismatch; node: Node): void =
    var relevantNode = if isSprintf(node) or isFormat(node):
      node.firstArgument
    elif isPercent(node):
      node.receiver
    relevantNode.source.scan(NAMEDFIELDREGEX).isEmpty.!

  method isSplatArgs*(self: FormatParameterMismatch; node: Node): void =
    if isPercent(node):
      return false
    node.arguments.butfirst.anyIt:
      it.isPlatType

  method isHeredoc*(self: FormatParameterMismatch; node: Node): void =
    node.firstArgument.source[0] == SHOVEL

  method countMatches*(self: FormatParameterMismatch; node: Node): void =
    if isCountableFormat(node):
      countFormatMatches(node)
    elif isCountablePercent(node):
      countPercentMatches(node)
    else:
      @["unknown"] * 2
  
  method isCountableFormat*(self: FormatParameterMismatch; node: Node): void =
      isSprintf(node) or isFormat(node) and isHeredoc(node).!

  method isCountablePercent*(self: FormatParameterMismatch; node: Node): void =
    isPercent(node) and node.firstArgument.isArrayType()

  method countFormatMatches*(self: FormatParameterMismatch; node: Node): void =
    (node.arguments.count() - 1, expectedFieldsCount(node.firstArgument))

  method countPercentMatches*(self: FormatParameterMismatch; node: Node): void =
    (node.firstArgument.childNodes.count(), expectedFieldsCount(node.receiver))

  method isFormatMethod*(self: FormatParameterMismatch; name: Symbol; node: Node): void =
    if node.isConstReceiver and node.receiver.loc.name.isIs(KERNEL).!:
      return false
    if node.isMethod(name):
    else:
      return false
    node.arguments.size > 1 and node.firstArgument.isStrType()

  method expectedFieldsCount*(self: FormatParameterMismatch; node: Node): void =
    if node.isStrType():
    else:
      return "unknown"
    if node.source.=~(NAMEDINTERPOLATION):
      return 1
    var maxDigitDollarNum = maxDigitDollarNum(node)
    if maxDigitDollarNum and maxDigitDollarNum.isNonzero():
      return maxDigitDollarNum
    node.source.scan(FIELDREGEX).reject(proc (x: void): void =
      x[0] == PERCENTPERCENT).reduce(0, proc (acc: void; elem: void): void =
      acc & argumentsCount(elem[2]))

  method maxDigitDollarNum*(self: FormatParameterMismatch; node: Node): void =
    node.source.scan(DIGITDOLLARFLAG).mapIt:
      it[0].toI().max

  method argumentsCount*(self: FormatParameterMismatch; format: string): void =
    format.scan("*").count() & 1

  method isFormat*(self: FormatParameterMismatch; node: Node): void =
    isFormatMethod("format", node)

  method isSprintf*(self: FormatParameterMismatch; node: Node): void =
    isFormatMethod("sprintf", node)

  method isPercent*(self: FormatParameterMismatch; node: Node): void =
    var
      receiver = node.receiver
      percent = node.isMethod("%") and
        STRINGTYPES.isInclude(receiver.type) or node.firstArgument.isArrayType
    if percent and STRINGTYPES.isInclude(receiver.type) and isHeredoc(node):
      return false
    percent

  method message*(self: FormatParameterMismatch; node: Node): void =
    var methodName = if node.isMethod("%"):
      "String#%"
    else:
      node.methodName
    format(MSG, argNum = numArgsForFormat, method = methodName,
           fieldNum = numExpectedFields)

