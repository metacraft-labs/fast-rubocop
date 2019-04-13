
import
  documentationComment

import
  defNode

cop :
  type
    DocumentationMethod* = ref object of Cop
    ##  This cop checks for missing documentation comment for public methods.
    ##  It can optionally be configured to also require documentation for
    ##  non-public methods.
    ## 
    ##  @example
    ## 
    ##    # bad
    ## 
    ##    class Foo
    ##      def bar
    ##        puts baz
    ##      end
    ##    end
    ## 
    ##    module Foo
    ##      def bar
    ##        puts baz
    ##      end
    ##    end
    ## 
    ##    def foo.bar
    ##      puts baz
    ##    end
    ## 
    ##    # good
    ## 
    ##    class Foo
    ##      # Documentation
    ##      def bar
    ##        puts baz
    ##      end
    ##    end
    ## 
    ##    module Foo
    ##      # Documentation
    ##      def bar
    ##        puts baz
    ##      end
    ##    end
    ## 
    ##    # Documentation
    ##    def foo.bar
    ##      puts baz
    ##    end
  const
    MSG = "Missing method documentation comment."
  nodeMatcher isModuleFunctionNode, "          (send nil? :module_function ...)\n"
  method onDef*(self: DocumentationMethod; node: Node): void =
    var parent = node.parent
    if isModuleFunctionNode parent:
      check(parent)
    else:
      check(node)
  
  method check*(self: DocumentationMethod; node: Node): void =
    if isNonPublic(node) and isRequireForNonPublicMethods.!:
      return
    if isDocumentationComment(node):
      return
    addOffense(node)

  method isRequireForNonPublicMethods*(self: DocumentationMethod): void =
    copConfig["RequireForNonPublicMethods"]

