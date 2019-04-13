
import
  types

cop StructInheritance:
  ##  This cop checks for inheritance from Struct.new.
  ## 
  ##  @example
  ##    # bad
  ##    class Person < Struct.new(:first_name, :last_name)
  ##    end
  ## 
  ##    # good
  ##    Person = Struct.new(:first_name, :last_name)
  const
    MSG = "Don\'t extend an instance initialized by `Struct.new`."
  nodeMatcher isStructConstructor, """           {(send (const nil? :Struct) :new ...)
            (block (send (const nil? :Struct) :new ...) ...)}
"""
  method onClass*(self; node) =
    if not isStructConstructor(superclass):
      return
    addOffense(node, location = superclass.sourceRange)

