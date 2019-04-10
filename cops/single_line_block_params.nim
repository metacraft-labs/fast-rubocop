
import
  sequtils

cop :
  type
    SingleLineBlockParams* = ref object of Cop
    ##  This cop checks whether the block parameters of a single-line
    ##  method accepting a block match the names specified via configuration.
    ## 
    ##  For instance one can configure `reduce`(`inject`) to use |a, e| as
    ##  parameters.
    ## 
    ##  Configuration option: Methods
    ##  Should be set to use this cop. Array of hashes, where each key is the
    ##  method name and value - array of argument names.
    ## 
    ##  @example Methods: [{reduce: %w[a b]}]
    ##    # bad
    ##    foo.reduce { |c, d| c + d }
    ##    foo.reduce { |_, _d| 1 }
    ## 
    ##    # good
    ##    foo.reduce { |a, b| a + b }
    ##    foo.reduce { |a, _b| a }
    ##    foo.reduce { |a, (id, _)| a + id }
    ##    foo.reduce { true }
    ## 
    ##    # good
    ##    foo.reduce do |c, d|
    ##      c + d
    ##    end
  const
    MSG = "Name `%<method>s` block params `|%<params>s|`."
  method onBlock*(self: SingleLineBlockParams; node: Node): void =
    if node.isSingleLine:
    if isEligibleMethod(node):
    if isEligibleArguments(node):
    if isArgsMatch(node.sendNode.methodName, node.arguments):
      return
    addOffense(node.arguments)

  method message*(self: SingleLineBlockParams; node: Node): void =
    var
      methodName = node.parent.sendNode.methodName
      arguments = targetArgs(methodName).join(", ")
    format(MSG, method = methodName, params = arguments)

  method isEligibleArguments*(self: SingleLineBlockParams; node: Node): void =
    node.isArguments and
        node.arguments.toA.allIt:
      it.isRgType

  method isEligibleMethod*(self: SingleLineBlockParams; node: Node): void =
    node.sendNode.receiver and methodNames.isInclude(node.sendNode.methodName)

  method methods*(self: SingleLineBlockParams): void =
    copConfig["Methods"]

  method methodNames*(self: SingleLineBlockParams): void =
    methods.mapIt:
      methodName(it).toSym()

  method methodName*(self: SingleLineBlockParams; method: Hash): void =
    method.keys()[0]

  method targetArgs*(self: SingleLineBlockParams; methodName: Symbol): void =
    methodName = `$`()
    var methodHash = methods.find(proc (m: Hash): void =
      methodName(m) == methodName)
    methodHash[methodName]

  method isArgsMatch*(self: SingleLineBlockParams; methodName: Symbol; args: Node): void =
    var
      actualArgs = args.toA.flatMap(proc (it: void): void =
        it.oA)
      actualArgsNoUnderscores = actualArgs.mapIt:
        `$`().sub("")
    actualArgsNoUnderscores == targetArgs(methodName)

