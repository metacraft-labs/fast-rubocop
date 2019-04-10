
import
  tables, sequtils

cop :
  type
    RedundantBlockCall* = ref object of Cop
  const
    MSG = "Use `yield` instead of `%<argname>s.call`."
  const
    YIELD = "yield"
  const
    OPENPAREN = "("
  const
    CLOSEPAREN = ")"
  const
    SPACE = " "
  nodeMatcher blockargDef, """          {(def  _   (args ... (blockarg $_)) $_)
           (defs _ _ (args ... (blockarg $_)) $_)}
"""
  method onDef*(self: RedundantBlockCall; node: Node): void =
    blockargDef node:
      if body:
      for blockcall in callsToReport(argname, body):
        addOffense(blockcall, message = format(MSG, argname = argname))

  method autocorrect*(self: RedundantBlockCall; node: Node): void =
    var newSource = String.new(YIELD)
    if args.isEmpty:
    else:
      newSource +=
          if isParentheses(node):
        OPENPAREN
      newSource.<<(args.mapIt:
        it.ource.join(", "))
    if isParentheses(node) and args.isEmpty.!:
      newSource.<<(CLOSEPAREN)
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, newSource))

  method callsToReport*(self: RedundantBlockCall; argname: Symbol; body: Node): void =
    if isBlockargAssigned(body, argname):
      return @[]
    var calls = toEnum("blockarg_calls", body, argname)
    if calls.anyIt:
      isArgsIncludeBlockPass(it):
      return @[]
    calls

  method isArgsIncludeBlockPass*(self: RedundantBlockCall; blockcall: Node): void =
    args.anyIt:
      it.isLockPassType

  defNodeSearch("blockarg_calls", "          (send (lvar %1) :call ...)\n")
  defNodeSearch("blockarg_assigned?", "          (lvasgn %1 ...)\n")
