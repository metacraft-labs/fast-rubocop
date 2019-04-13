
cop :
  type
    DoubleNegation* = ref object of Cop
    ##  This cop checks for uses of double negation (!!) to convert something
    ##  to a boolean value. As this is both cryptic and usually redundant, it
    ##  should be avoided.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    !!something
    ## 
    ##    # good
    ##    !something.nil?
    ## 
    ##  Please, note that when something is a boolean value
    ##  !!something and !something.nil? are not the same thing.
    ##  As you're unlikely to write code that can accept values of any type
    ##  this is rarely a problem in practice.
  const
    MSG = "Avoid the use of double negation (`!!`)."
  nodeMatcher isDoubleNegative, "(send (send _ :!) :!)"
  method onSend*(self: DoubleNegation; node: Node): void =
    if isDoubleNegative node and node.isPrefixBang:
    addOffense(node, location = "selector")

