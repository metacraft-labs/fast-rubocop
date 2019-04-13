
import
  types

cop WhenThen:
  ##  This cop checks for *when;* uses in *case* expressions.
  ## 
  ##  @example
  ##    # bad
  ##    case foo
  ##    when 1; 'baz'
  ##    when 2; 'bar'
  ##    end
  ## 
  ##    # good
  ##    case foo
  ##    when 1 then 'baz'
  ##    when 2 then 'bar'
  ##    end
  const
    MSG = "Do not use `when x;`. Use `when x then` instead."
  method onWhen*(self; node) =
    if node.isMultiline and node.isThen and not node.body:
      return
    addOffense(node, location = RbBegin)

