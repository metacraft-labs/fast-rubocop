
cop :
  type
    OptionHash* = ref object of Cop
    ##  This cop checks for options hashes and discourages them if the
    ##  current Ruby version supports keyword arguments.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    def fry(options = {})
    ##      temperature = options.fetch(:temperature, 300)
    ##      # ...
    ##    end
    ## 
    ## 
    ##    # good
    ##    def fry(temperature: 300)
    ##      # ...
    ##    end
  const
    MSG = "Prefer keyword arguments to options hashes."
  nodeMatcher optionHash,
             "          (args ... $(optarg [#suspicious_name? _] (hash)))\n"
  method onArgs*(self: OptionHash; node: Node): void =
    if isSuperUsed(node):
      return
    optionHash node:
      addOffense(options)

  method isSuspiciousName*(self: OptionHash; argName: Symbol): void =
    copConfig.isKey("SuspiciousParamNames") and
        copConfig["SuspiciousParamNames"].isInclude(`$`())

  method isSuperUsed*(self: OptionHash; node: Node): void =
    node.parent.eachNode("zsuper").isAny()

