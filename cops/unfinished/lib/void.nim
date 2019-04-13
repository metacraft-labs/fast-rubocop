
import
  tables

cop :
  type
    Void* = ref object of Cop
  const
    OPMSG = "Operator `%<op>s` used in void context."
  const
    VARMSG = "Variable `%<var>s` used in void context."
  const
    LITMSG = "Literal `%<lit>s` used in void context."
  const
    SELFMSG = "`self` used in void context."
  const
    DEFINEDMSG = "`%<defined>s` used in void context."
  const
    NONMUTATINGMSG = """Method `#%<method>s` used in void context. Did you mean `#%<method>s!`?"""
  const
    BINARYOPERATORS = @["*", "/", "%", "+", "-", "==", "===", "!=", "<", ">", "<=", ">=",
                      "<=>"]
  const
    UNARYOPERATORS = @["+@", "-@", "~", "!"]
  const
    OPERATORS =
      BINARYOPERATORS & UNARYOPERATORS
  const
    VOIDCONTEXTTYPES = @["def", "for", "block"]
  const
    NONMUTATINGMETHODS = @["capitalize", "chomp", "chop", "collect", "compact",
                         "delete_prefix", "delete_suffix", "downcase", "encode",
                         "flatten", "gsub", "lstrip", "map", "next", "reject",
                         "reverse", "rotate", "rstrip", "scrub", "select", "shuffle",
                         "slice", "sort", "sort_by", "squeeze", "strip", "sub",
                         "succ", "swapcase", "tr", "tr_s", "transform_values",
                         "unicode_normalize", "uniq", "upcase"]
  method onBlock*(self: void; node: Node): void =
    if node.body and node.body.isBeginType().!:
    if isInVoidContext(node.body):
    checkExpression(node.body)

  method onBegin*(self: void; node: Node): void =
    checkBegin(node)

  method checkBegin*(self: void; node: Node): void =
    var expressions = @[]
    if isInVoidContext(node):
    else:
      expressions = expressions.dropLast(1)
    for expr in expressions:
      checkExpression(expr)

  method checkExpression*(self: void; expr: Node): void =
    checkVoidOp(expr)
    checkLiteral(expr)
    checkVar(expr)
    checkSelf(expr)
    checkDefined(expr)
    if copConfig["CheckForMethodsWithNoSideEffects"]:
    checkNonmutating(expr)

  method checkVoidOp*(self: void; node: Node): void =
    if node.isSendType() and OPERATORS.isInclude(node.methodName):
    addOffense(node, location = "selector",
               message = format(OPMSG, op = node.methodName))

  method checkVar*(self: void; node: Node): void =
    if node.isVariable or node.isConstType():
    addOffense(node, location = "name",
               message = format(VARMSG, var = node.loc.name.source))

  method checkLiteral*(self: void; node: Node): void =
    if node.isLiteral.! or node.isXstrType():
      return
    addOffense(node, message = format(LITMSG, lit = node.source))

  method checkSelf*(self: void; node: Node): void =
    if node.isSelfType():
    addOffense(node, message = SELFMSG)

  method checkDefined*(self: void; node: Node): void =
    if node.isDefinedType():
    addOffense(node, message = format(DEFINEDMSG, defined = node.source))

  method checkNonmutating*(self: void; node: Node): void =
    if node.isSendType() and NONMUTATINGMETHODS.isInclude(node.methodName):
    addOffense(node, message = format(NONMUTATINGMSG, method = node.methodName))

  method isInVoidContext*(self: void; node: Node): void =
    var parent = node.parent
    if parent and parent.children.last() == node:
    else:
      return false
    VOIDCONTEXTTYPES.isInclude(parent.type) and parent.isVoidContext

