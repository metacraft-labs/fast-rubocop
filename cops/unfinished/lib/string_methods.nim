
import
  methodPreference

cop :
  type
    StringMethods* = ref object of Cop
    ##  This cop enforces the use of consistent method names
    ##  from the String class.
    ## 
    ##  @example
    ##    # bad
    ##    'name'.intern
    ##    'var'.unfavored_method
    ## 
    ##    # good
    ##    'name'.to_sym
    ##    'var'.preferred_method
  const
    MSG = "Prefer `%<prefer>s` over `%<current>s`."
  method onSend*(self: StringMethods; node: Node): void =
    if preferredMethod(node.methodName):
    addOffense(node, location = "selector")

  method autocorrect*(self: StringMethods; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.selector, preferredMethod(node.methodName)))

  method message*(self: StringMethods; node: Node): void =
    format(MSG, prefer = preferredMethod(node.methodName), current = node.methodName)

