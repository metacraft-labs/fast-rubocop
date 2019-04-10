
import
  onNormalIfUnless

cop :
  type
    IfWithSemicolon* = ref object of Cop
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
  method onNormalIfUnless*(self: IfWithSemicolon; node: Node): void =
    var beginning = node.loc.begin
    if beginning and beginning.isIs(";"):
    addOffense(node)

