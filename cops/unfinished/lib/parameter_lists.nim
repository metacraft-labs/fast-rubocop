
import
  configurableMax

cop :
  type
    ParameterLists* = ref object of Cop
    ##  This cop checks for methods with too many parameters.
    ##  The maximum number of parameters is configurable.
    ##  Keyword arguments can optionally be excluded from the total count.
  const
    MSG = """Avoid parameter lists longer than %<max>d parameters. [%<count>d/%<max>d]"""
  nodeMatcher isArgumentToLambdaOrProc, "          ^lambda_or_proc?\n"
  method onArgs*(self: ParameterLists; node: Node): void =
    var count = argsCount(node)
    if count > maxParams:
    if isArgumentToLambdaOrProc node:
      return
    addOffense(node, proc (): void =
      self.max=(count))

  method message*(self: ParameterLists; node: Node): void =
    format(MSG, max = maxParams, count = argsCount(node))

  method argsCount*(self: ParameterLists; node: Node): void =
    if isCountKeywordArgs:
      node.children.size
    else:
      node.children.count(proc (a: Node): void =
        @["kwoptarg", "kwarg"].isInclude(a.type).!)
  
  method maxParams*(self: ParameterLists): void =
    copConfig["Max"]

  method isCountKeywordArgs*(self: ParameterLists): void =
    copConfig["CountKeywordArgs"]

