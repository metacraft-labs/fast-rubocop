
import
  rangeHelp

import
  ignoredMethods

cop :
  type
    SymbolProc* = ref object of Cop
    ##  Use symbols as procs when possible.
    ## 
    ##  @example
    ##    # bad
    ##    something.map { |s| s.upcase }
    ## 
    ##    # good
    ##    something.map(&:upcase)
  const
    MSG = """Pass `&:%<method>s` as an argument to `%<block_method>s` instead of a block."""
  const
    SUPERTYPES = @["super", "zsuper"]
  nodeMatcher isProcNode, "(send (const nil? :Proc) :new)"
  nodeMatcher isSymbolProc, """          (block
            ${(send ...) (super ...) zsuper}
            $(args (arg _var))
            (send (lvar _var) $_))
"""
  method autocorrectIncompatibleWith*(self: Class): void =
    @[SpaceBeforeBlockBraces]

  method onBlock*(self: SymbolProc; node: Node): void =
    isSymbolProc node:
      var blockMethodName = resolveBlockMethodName(sendOrSuper)
      if isProcNode sendOrSuper:
        return
      if @["lambda", "proc"].isInclude(blockMethodName):
        return
      if isIgnoredMethod(blockMethodName):
        return
      if blockArgs.children.size == 1 and blockArgs.source.isInclude(","):
        return
      offense(node, method, blockMethodName)

  method autocorrect*(self: SymbolProc; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      if isSuper(blockSendOrSuper):
        var args = @[]
      autocorrectMethod(corrector, node, args, methodName))

  method resolveBlockMethodName*(self: SymbolProc; blockSendOrSuper: Node): void =
    if isSuper(blockSendOrSuper):
      return "super"
    methodName

  method offense*(self: SymbolProc; node: Node; methodName: Symbol;
                 blockMethodName: Symbol): void =
    var
      blockStart = node.loc.begin.beginPos
      blockEnd = node.loc.end.endPos
      range = rangeBetween(blockStart, blockEnd)
    addOffense(node, location = range, message = format(MSG, method = methodName,
        blockMethod = blockMethodName))

  method autocorrectMethod*(self: SymbolProc; corrector: Corrector; node: Node;
                           args: Array; methodName: Symbol): void =
    if args.isEmpty:
      autocorrectNoArgs(corrector, node, methodName)
    else:
      autocorrectWithArgs(corrector, node, args, methodName)
  
  method autocorrectNoArgs*(self: SymbolProc; corrector: Corrector; node: Node;
                           methodName: Symbol): void =
    corrector.replace(blockRangeWithSpace(node), """(&:(lvar :method_name))""")

  method autocorrectWithArgs*(self: SymbolProc; corrector: Corrector; node: Node;
                             args: Array; methodName: Symbol): void =
    var argRange = args.last().sourceRange
    argRange = rangeWithSurroundingComma(argRange, "right")
    var replacement = """ &:(lvar :method_name)"""
    if argRange.source.isEndWith(","):
    else:
      replacement = "," & replacement
    corrector.insertAfter(argRange, replacement)
    corrector.remove(blockRangeWithSpace(node))

  method blockRangeWithSpace*(self: SymbolProc; node: Node): void =
    var blockRange = rangeBetween(beginPosForReplacement(node), node.loc.end.endPos)
    rangeWithSurroundingSpace(range = blockRange, side = "left")

  method beginPosForReplacement*(self: SymbolProc; node: Node): void =
    var expr = blockSendOrSuper.sourceRange
    if
      var parenPos =
        expr.source.=~():
      expr.beginPos & parenPos
    else:
      node.loc.begin.beginPos
  
  method isSuper*(self: SymbolProc; node: Node): void =
    SUPERTYPES.isInclude(node.type)

