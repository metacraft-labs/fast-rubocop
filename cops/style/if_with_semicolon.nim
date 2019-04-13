
import
  types

import
  onNormalIfUnless

cop IfWithSemicolon:
  ##  Checks for uses of semicolon in if statements.
  ## 
  ##  @example
  ## 
  ##    # bad
  ##    result = if some_condition; something else another_thing end
  ## 
  ##    # good
  ##    result = some_condition ? something : another_thing
  ## 
  const
    MSG = "Do not use if x; Use the ternary operator instead."
  method onNormalIfUnless*(self; node) =
    var beginning = node.loc.begin
    if not (beginning and beginning.isIs(";")):
      return
    addOffense(node)

