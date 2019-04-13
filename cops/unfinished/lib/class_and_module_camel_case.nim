
cop :
  type
    ClassAndModuleCamelCase* = ref object of Cop
    ##  This cop checks for class and module names with
    ##  an underscore in them.
    ## 
    ##  @example
    ##    # bad
    ##    class My_Class
    ##    end
    ##    module My_Module
    ##    end
    ## 
    ##    # good
    ##    class MyClass
    ##    end
    ##    module MyModule
    ##    end
  const
    MSG = "Use CamelCase for classes and modules."
  method onClass*(self: ClassAndModuleCamelCase; node: Node): void =
    if node.loc.name.source.=~():
    addOffense(node, location = "name")

