
import
  types

cop ClassAndModuleCamelCase:
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
  method onClass*(self; node) =
    if not node.loc.name.source.=~():
      return
    addOffense(node, location = name)

