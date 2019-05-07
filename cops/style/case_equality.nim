
import
  types

cop CaseEquality:
  ##  This cop checks for uses of the case equality operator(===).
  ## 
  ##  @example
  ##    # bad
  ##    Array === something
  ##    (1..100) === 7
  ##    /something/ === some_string
  ## 
  ##    # good
  ##    something.is_a?(Array)
  ##    (1..100).include?(7)
  ##    some_string =~ /something/
  ## 
  
  const
    MSG = "Avoid the use of the case equality operator `===`."
  nodeMatcher isCaseEquality, "(send _ :=== _)"
  
  method onSend*(self; node) =
    isCaseEquality node:
      addOffense(node, location = selector)

