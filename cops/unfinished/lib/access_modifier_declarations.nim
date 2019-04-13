
import
  configurableEnforcedStyle

cop :
  type
    AccessModifierDeclarations* = ref object of Cop
    ##  Access modifiers should be declared to apply to a group of methods
    ##  or inline before each method, depending on configuration.
    ## 
    ##  @example EnforcedStyle: group (default)
    ## 
    ##    # bad
    ## 
    ##    class Foo
    ## 
    ##      private def bar; end
    ##      private def baz; end
    ## 
    ##    end
    ## 
    ##    # good
    ## 
    ##    class Foo
    ## 
    ##      private
    ## 
    ##      def bar; end
    ##      def baz; end
    ## 
    ##    end
    ##  @example EnforcedStyle: inline
    ## 
    ##    # bad
    ## 
    ##    class Foo
    ## 
    ##      private
    ## 
    ##      def bar; end
    ##      def baz; end
    ## 
    ##    end
    ## 
    ##    # good
    ## 
    ##    class Foo
    ## 
    ##      private def bar; end
    ##      private def baz; end
    ## 
    ##    end
  const
    GROUPSTYLEMESSAGE = @["`%<access_modifier>s` should not be",
                        "inlined in method definitions."].join(" ")
  const
    INLINESTYLEMESSAGE = @["`%<access_modifier>s` should be",
                         "inlined in method definitions."].join(" ")
  method onSend*(self: AccessModifierDeclarations; node: Node): void =
    if node.isAccessModifier:
    if isOffense(node):
      addOffense(node, location = "selector", proc (): void =
        oppositeStyleDetected)
  
  method isOffense*(self: AccessModifierDeclarations; node: Node): void =
      isGroupStyle and isAccessModifierIsInlined(node) or
      isInlineStyle and isAccessModifierIsNotInlined(node)

  method isGroupStyle*(self: AccessModifierDeclarations): void =
    style == "group"

  method isInlineStyle*(self: AccessModifierDeclarations): void =
    style == "inline"

  method isAccessModifierIsInlined*(self: AccessModifierDeclarations; node: Node): void =
    node.arguments.isAny()

  method isAccessModifierIsNotInlined*(self: AccessModifierDeclarations; node: Node): void =
    isAccessModifierIsInlined(node).!

  method message*(self: AccessModifierDeclarations; node: Node): void =
    var accessModifier = node.loc.selector.source
    if isGroupStyle:
      format(GROUPSTYLEMESSAGE, accessModifier = accessModifier)
    elif isInlineStyle:
      format(INLINESTYLEMESSAGE, accessModifier = accessModifier)
  
