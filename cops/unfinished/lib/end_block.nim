
cop :
  type
    EndBlock* = ref object of Cop
    ##  This cop checks for END blocks.
    ## 
    ##  @example
    ##    # bad
    ##    END { puts 'Goodbye!' }
    ## 
    ##    # good
    ##    at_exit { puts 'Goodbye!' }
    ## 
  const
    MSG = """Avoid the use of `END` blocks. Use `Kernel#at_exit` instead."""
  method onPostexe*(self: EndBlock; node: Node): void =
    addOffense(node, location = "keyword")

