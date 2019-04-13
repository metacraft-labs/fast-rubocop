
cop :
  type
    ClassMethods* = ref object of Cop
    ##  This cop checks for uses of the class/module name instead of
    ##  self, when defining class/module methods.
    ## 
    ##  @example
    ##    # bad
    ##    class SomeClass
    ##      def SomeClass.class_method
    ##        # ...
    ##      end
    ##    end
    ## 
    ##    # good
    ##    class SomeClass
    ##      def self.class_method
    ##        # ...
    ##      end
    ##    end
  const
    MSG = "Use `self.%<method>s` instead of `%<class>s.%<method>s`."
  method onClass*(self: ClassMethods; node: Node): void =
    check(name, body)

  method onModule*(self: ClassMethods; node: Node): void =
    check(name, body)

  method autocorrect*(self: ClassMethods; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.name, "self"))

  method check*(self: ClassMethods; name: Node; node: Node): void =
    if node:
    if node.isDefsType():
      checkDefs(name, node)
    elif node.isBeginType():
      node.eachChildNode("defs", proc (n: Node): void =
        checkDefs(name, n))
  
  method checkDefs*(self: ClassMethods; name: Node; node: Node): void =
    if name == definee:
    addOffense(definee, location = "name", message = message(className, methodName))

  method message*(self: ClassMethods; className: Symbol; methodName: Symbol): void =
    format(MSG, method = methodName, class = className)

