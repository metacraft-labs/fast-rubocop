
import
  rangeHelp

cop :
  type
    StderrPuts* = ref object of Cop
    ##  This cop identifies places where `$stderr.puts` can be replaced by
    ##  `warn`. The latter has the advantage of easily being disabled by,
    ##  the `-W0` interpreter flag or setting `$VERBOSE` to `nil`.
    ## 
    ##  @example
    ##    # bad
    ##    $stderr.puts('hello')
    ## 
    ##    # good
    ##    warn('hello')
    ## 
  const
    MSG = """Use `warn` instead of `$stderr.puts` to allow such output to be disabled."""
  nodeMatcher isStderrPuts, """          (send
            (gvar #stderr_gvar?) :puts
            ...)
"""
  method onSend*(self: StderrPuts; node: Node): void =
    if isStderrPuts node:
    addOffense(node, location = stderrPutsRange(node))

  method autocorrect*(self: StderrPuts; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(stderrPutsRange(node), "warn"))

  method isStderrGvar*(self: StderrPuts; sym: Symbol): void =
    sym == "$stderr"

  method stderrPutsRange*(self: StderrPuts; send: Node): void =
    rangeBetween(send.loc.expression.beginPos, send.loc.selector.endPos)

