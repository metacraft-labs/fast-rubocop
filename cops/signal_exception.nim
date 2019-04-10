
import
  tables

import
  configurableEnforcedStyle

cop :
  type
    SignalException* = ref object of Cop
    ##  This cop checks for uses of `fail` and `raise`.
    ## 
    ##  @example EnforcedStyle: only_raise (default)
    ##    # The `only_raise` style enforces the sole use of `raise`.
    ##    # bad
    ##    begin
    ##      fail
    ##    rescue Exception
    ##      # handle it
    ##    end
    ## 
    ##    def watch_out
    ##      fail
    ##    rescue Exception
    ##      # handle it
    ##    end
    ## 
    ##    Kernel.fail
    ## 
    ##    # good
    ##    begin
    ##      raise
    ##    rescue Exception
    ##      # handle it
    ##    end
    ## 
    ##    def watch_out
    ##      raise
    ##    rescue Exception
    ##      # handle it
    ##    end
    ## 
    ##    Kernel.raise
    ## 
    ##  @example EnforcedStyle: only_fail
    ##    # The `only_fail` style enforces the sole use of `fail`.
    ##    # bad
    ##    begin
    ##      raise
    ##    rescue Exception
    ##      # handle it
    ##    end
    ## 
    ##    def watch_out
    ##      raise
    ##    rescue Exception
    ##      # handle it
    ##    end
    ## 
    ##    Kernel.raise
    ## 
    ##    # good
    ##    begin
    ##      fail
    ##    rescue Exception
    ##      # handle it
    ##    end
    ## 
    ##    def watch_out
    ##      fail
    ##    rescue Exception
    ##      # handle it
    ##    end
    ## 
    ##    Kernel.fail
    ## 
    ##  @example EnforcedStyle: semantic
    ##    # The `semantic` style enforces the use of `fail` to signal an
    ##    # exception, then will use `raise` to trigger an offense after
    ##    # it has been rescued.
    ##    # bad
    ##    begin
    ##      raise
    ##    rescue Exception
    ##      # handle it
    ##    end
    ## 
    ##    def watch_out
    ##      # Error thrown
    ##    rescue Exception
    ##      fail
    ##    end
    ## 
    ##    Kernel.fail
    ##    Kernel.raise
    ## 
    ##    # good
    ##    begin
    ##      fail
    ##    rescue Exception
    ##      # handle it
    ##    end
    ## 
    ##    def watch_out
    ##      fail
    ##    rescue Exception
    ##      raise 'Preferably with descriptive message'
    ##    end
    ## 
    ##    explicit_receiver.fail
    ##    explicit_receiver.raise
  const
    FAILMSG = "Use `fail` instead of `raise` to signal exceptions."
  const
    RAISEMSG = """Use `raise` instead of `fail` to rethrow exceptions."""
  nodeMatcher isKernelCall, "(send (const nil? :Kernel) %1 ...)"
  method investigate*(self: SignalException; processedSource: ProcessedSource): void =
    var ast = processedSource.ast
    self.customFailDefined = ast and customFailMethods(ast).isAny()

  method onRescue*(self: SignalException; node: Node): void =
    if style == "semantic":
    checkScope("raise", beginNode)
    for rescueNode in rescueNodes:
      checkScope("fail", rescueNode)
      allow("raise", rescueNode)

  method onSend*(self: SignalException; node: Node): void =
    case style
    of "semantic":
      if isIgnoredNode(node):
      else:
        checkSend("raise", node)
    of "only_raise":
      if self.customFailDefined:
        return
      checkSend("fail", node)
    of "only_fail":
      checkSend("raise", node)
    else:

  method autocorrect*(self: SignalException; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var name = case style
      of "semantic":
        if isCommandOrKernelCall("raise", node):
          "fail"
      of "only_raise":
        "raise"
      of "only_fail":
        "fail"
      else:
      corrector.replace(node.loc.selector, name))

  method message*(self: SignalException; methodName: Symbol): void =
    case style
    of "semantic":
      if methodName == "fail":
        RAISEMSG
    of "only_raise":
      "Always use `raise` to signal exceptions."
    of "only_fail":
      "Always use `fail` to signal exceptions."
    else:

  method checkScope*(self: SignalException; methodName: Symbol; node: Node): void =
    if node:
    eachCommandOrKernelCall(methodName, node, proc (sendNode: Node): void =
      if isIgnoredNode(sendNode):
        continue
      addOffense(sendNode, location = "selector", message = message(methodName))
      ignoreNode(sendNode))

  method checkSend*(self: SignalException; methodName: Symbol; node: Node): void =
    if node and isCommandOrKernelCall(methodName, node):
    addOffense(node, location = "selector", message = message(methodName))

  method isCommandOrKernelCall*(self: SignalException; name: Symbol; node: Node): void =
    node.isCommand(name) or isKernelCall node, name

  method allow*(self: SignalException; methodName: Symbol; node: Node): void =
    eachCommandOrKernelCall(methodName, node, proc (sendNode: Node): void =
      ignoreNode(sendNode))

  iterator eachCommandOrKernelCall*(self: SignalException; methodName: Symbol;
                                   node: Node): void =
    onNode("send", node, "rescue", proc (sendNode: Node): void =
      if isCommandOrKernelCall(methodName, sendNode):
        yield sendNode
    )

  defNodeSearch("custom_fail_methods", "{(def :fail ...) (defs _ :fail ...)}")
