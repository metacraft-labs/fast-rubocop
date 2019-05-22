
import
  types

cop BeginBlock:
  ## 
  ##  This cop checks for BEGIN blocks.
  ## 
  ##  @example
  ##    # bad
  ##    BEGIN { test }
  ## 
  
  const
    MSG = "Avoid the use of `BEGIN` blocks."
  
  method onPreexe*(self; node) =
    addOffense(node, location = keyword)

