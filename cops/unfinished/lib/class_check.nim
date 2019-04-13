
import
  configurableEnforcedStyle

cop :
  type
    ClassCheck* = ref object of Cop
    ##  This cop enforces consistent use of `Object#is_a?` or `Object#kind_of?`.
    ## 
    ##  @example EnforcedStyle: is_a? (default)
    ##    # bad
    ##    var.kind_of?(Date)
    ##    var.kind_of?(Integer)
    ## 
    ##    # good
    ##    var.is_a?(Date)
    ##    var.is_a?(Integer)
    ## 
    ##  @example EnforcedStyle: kind_of?
    ##    # bad
    ##    var.is_a?(Time)
    ##    var.is_a?(String)
    ## 
    ##    # good
    ##    var.kind_of?(Time)
    ##    var.kind_of?(String)
    ## 
  const
    MSG = "Prefer `Object#%<prefer>s` over `Object#%<current>s`."
  nodeMatcher isClassCheck, "(send _ ${:is_a? :kind_of?} _)"
  method onSend*(self: ClassCheck; node: Node): void =
    isClassCheck node:
      if style == methodName:
        return
      addOffense(node, location = "selector")

  method autocorrect*(self: ClassCheck; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var replacement = if node.isMethod("is_a?"):
        "kind_of?"
      corrector.replace(node.loc.selector, replacement))

  method message*(self: ClassCheck; node: Node): void =
    if node.isMethod("is_a?"):
      format(MSG, prefer = "kind_of?", current = "is_a?")
    else:
      format(MSG, prefer = "is_a?", current = "kind_of?")
  
