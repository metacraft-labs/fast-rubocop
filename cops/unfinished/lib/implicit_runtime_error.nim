
cop :
  type
    ImplicitRuntimeError* = ref object of Cop
    ##  This cop checks for `raise` or `fail` statements which do not specify an
    ##  explicit exception class. (This raises a `RuntimeError`. Some projects
    ##  might prefer to use exception classes which more precisely identify the
    ##  nature of the error.)
    ## 
    ##  @example
    ##    # bad
    ##    raise 'Error message here'
    ## 
    ##    # good
    ##    raise ArgumentError, 'Error message here'
  const
    MSG = """Use `%<method>s` with an explicit exception class and message, rather than just a message."""
  nodeMatcher implicitRuntimeErrorRaiseOrFail,
             "(send nil? ${:raise :fail} {str dstr})"
  method onSend*(self: ImplicitRuntimeError; node: Node): void =
    implicitRuntimeErrorRaiseOrFail node:
      addOffense(node, message = format(MSG, method = method))

