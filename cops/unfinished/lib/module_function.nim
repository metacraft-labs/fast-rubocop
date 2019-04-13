
import
  tables, sequtils

import
  configurableEnforcedStyle

cop :
  type
    ModuleFunction* = ref object of Cop
    ##  This cop checks for use of `extend self` or `module_function` in a
    ##  module.
    ## 
    ##  Supported styles are: module_function, extend_self.
    ## 
    ##  @example EnforcedStyle: module_function (default)
    ##    # bad
    ##    module Test
    ##      extend self
    ##      # ...
    ##    end
    ## 
    ##    # good
    ##    module Test
    ##      module_function
    ##      # ...
    ##    end
    ## 
    ##  In case there are private methods, the cop won't be activated.
    ##  Otherwise, it forces to change the flow of the default code.
    ## 
    ##  @example EnforcedStyle: module_function (default)
    ##    # good
    ##    module Test
    ##      extend self
    ##      # ...
    ##      private
    ##      # ...
    ##    end
    ## 
    ##  @example EnforcedStyle: extend_self
    ##    # bad
    ##    module Test
    ##      module_function
    ##      # ...
    ##    end
    ## 
    ##    # good
    ##    module Test
    ##      extend self
    ##      # ...
    ##    end
    ## 
    ##  These offenses are not safe to auto-correct since there are different
    ##  implications to each approach.
  const
    MODULEFUNCTIONMSG = "Use `module_function` instead of `extend self`."
  const
    EXTENDSELFMSG = "Use `extend self` instead of `module_function`."
  nodeMatcher isModuleFunctionNode, "(send nil? :module_function)"
  nodeMatcher isExtendSelfNode, "(send nil? :extend self)"
  nodeMatcher isPrivateDirective, "(send nil? :private ...)"
  method onModule*(self: ModuleFunction; node: Node): void =
    if body and body.isBeginType():
    eachWrongStyle(body.children, proc (childNode: Node): void =
      addOffense(childNode))

  method autocorrect*(self: ModuleFunction; node: Node): void =
    lambda(proc (corrector: Corrector): void =
      if isExtendSelfNode node:
        corrector.replace(node.sourceRange, "module_function")
      else:
        corrector.replace(node.sourceRange, "extend self")
    )

  iterator eachWrongStyle*(self: ModuleFunction; nodes: Array): void =
    case style
    of "module_function":
      var privateDirective = nodes.anyIt:
        isPrivateDirective it
      for node in nodes:
        if isExtendSelfNode node and privateDirective.!:
          yield node
    of "extend_self":
      for node in nodes:
        if isModuleFunctionNode node:
          yield node
    else:

  method message*(self: ModuleFunction; _node: Node): void =
    if style == "module_function":
      MODULEFUNCTIONMSG
  
