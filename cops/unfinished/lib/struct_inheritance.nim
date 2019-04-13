
cop :
  type
    StructInheritance* = ref object of Cop
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
  method onClass*(self: StructInheritance; node: Node): void =
    if isStructConstructor superclass:
    addOffense(node, location = superclass.sourceRange)

