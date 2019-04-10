
cop :
  type
    DefWithParentheses* = ref object of Cop
    ##  This cop checks for parentheses in the definition of a method,
    ##  that does not take any arguments. Both instance and
    ##  class/singleton methods are checked.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    def foo()
    ##      # does a thing
    ##    end
    ## 
    ##    # good
    ##    def foo
    ##      # does a thing
    ##    end
    ## 
    ##    # also good
    ##    def foo() does_a_thing end
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    def Baz.foo()
    ##      # does a thing
    ##    end
    ## 
    ##    # good
    ##    def Baz.foo
    ##      # does a thing
    ##    end
  const
    MSG = """Omit the parentheses in defs when the method doesn't accept any arguments."""
  method onDef*(self: DefWithParentheses; node: Node): void =
    if node.isSingleLine:
      return
    if node.isArguments.! and node.arguments.loc.begin:
    addOffense(node.arguments, location = "begin")

  method autocorrect*(self: DefWithParentheses; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.remove(node.loc.begin)
      corrector.remove(node.loc.end))

