
import
  configurableEnforcedStyle

cop :
  type
    PreferredHashMethods* = ref object of Cop
    ##  This cop (by default) checks for uses of methods Hash#has_key? and
    ##  Hash#has_value? where it enforces Hash#key? and Hash#value?
    ##  It is configurable to enforce the inverse, using `verbose` method
    ##  names also.
    ## 
    ##  @example EnforcedStyle: short (default)
    ##   # bad
    ##   Hash#has_key?
    ##   Hash#has_value?
    ## 
    ##   # good
    ##   Hash#key?
    ##   Hash#value?
    ## 
    ##  @example EnforcedStyle: verbose
    ##   # bad
    ##   Hash#key?
    ##   Hash#value?
    ## 
    ##   # good
    ##   Hash#has_key?
    ##   Hash#has_value?
  const
    MSG = "Use `Hash#%<prefer>s` instead of `Hash#%<current>s`."
  const
    OFFENDINGSELECTORS = {"short": @["has_key?", "has_value?"],
                        "verbose": @["key?", "value?"]}.newTable()
  method onSend*(self: PreferredHashMethods; node: Node): void =
    if node.arguments.isOne() and isOffendingSelector(node.methodName):
    addOffense(node, location = "selector")

  method autocorrect*(self: PreferredHashMethods; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.selector,
                        properMethodName(node.loc.selector.source)))

  method message*(self: PreferredHashMethods; node: Node): void =
    format(MSG, prefer = properMethodName(node.methodName),
           current = node.methodName)

  method properMethodName*(self: PreferredHashMethods; methodName: string): void =
    if style == "verbose":
      """has_(lvar :method_name)"""
    else:
      `$`().sub("")
  
  method isOffendingSelector*(self: PreferredHashMethods; methodName: Symbol): void =
    OFFENDINGSELECTORS[style].isInclude(methodName)

