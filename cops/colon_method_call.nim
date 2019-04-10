
cop :
  type
    ColonMethodCall* = ref object of Cop
    ##  This cop checks for methods invoked via the :: operator instead
    ##  of the . operator (like FileUtils::rmdir instead of FileUtils.rmdir).
    ## 
    ##  @example
    ##    # bad
    ##    Timeout::timeout(500) { do_something }
    ##    FileUtils::rmdir(dir)
    ##    Marshal::dump(obj)
    ## 
    ##    # good
    ##    Timeout.timeout(500) { do_something }
    ##    FileUtils.rmdir(dir)
    ##    Marshal.dump(obj)
    ## 
  const
    MSG = "Do not use `::` for method calls."
  nodeMatcher isJavaTypeNode, """          (send
            (const nil? :Java) _)
"""
  method autocorrectIncompatibleWith*(self: Class): void =
    @[RedundantSelf]

  method onSend*(self: ColonMethodCall; node: Node): void =
    if isJavaTypeNode node:
      return
    if node.receiver and node.isDoubleColon:
    if node.isCamelCaseMethod:
      return
    addOffense(node, location = "dot")

  method autocorrect*(self: ColonMethodCall; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.dot, "."))

