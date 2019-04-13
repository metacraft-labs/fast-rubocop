
import
  stringHelp

cop :
  type
    CharacterLiteral* = ref object of Cop
    ##  Checks for uses of the character literal ?x.
    ## 
    ##  @example
    ##    # bad
    ##    ?x
    ## 
    ##    # good
    ##    'x'
    ## 
    ##    # good
    ##    ?\C-\M-d
  const
    MSG = """Do not use the character literal - use string literal instead."""
  method isOffense*(self: CharacterLiteral; node: Node): void =
    node.loc.begin.isIs("?") and node.source.size.isBetween(2, 3)

  method autocorrect*(self: CharacterLiteral; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      var string = node.source[]
      if string.length == 2 or string == "\'":
        corrector.replace(node.sourceRange, """"(lvar :string)"""")
      elif string.length == 1:
        corrector.replace(node.sourceRange, """'(lvar :string)'""")
    )

  method oppositeStyleDetected*(self: CharacterLiteral): void =
    ##  Dummy implementation of method in ConfigurableEnforcedStyle that is
    ##  called from StringHelp.
  
  method correctStyleDetected*(self: CharacterLiteral): void =
    ##  Dummy implementation of method in ConfigurableEnforcedStyle that is
    ##  called from StringHelp.
  
