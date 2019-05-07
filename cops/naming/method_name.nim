
import
  types

import
  configurableNaming

cop :
  type
    MethodName* = ref object of Cop
    ##  This cop makes sure that all methods use the configured style,
    ##  snake_case or camelCase, for their names.
    ## 
    ##  @example EnforcedStyle: snake_case (default)
    ##    # bad
    ##    def fooBar; end
    ## 
    ##    # good
    ##    def foo_bar; end
    ## 
    ##  @example EnforcedStyle: camelCase
    ##    # bad
    ##    def foo_bar; end
    ## 
    ##    # good
    ##    def fooBar; end
  const
    MSG = "Use %<style>s for method names."
  method onDef*(self: MethodName; node: Node): void =
    if node.isOperatorMethod():
      return
    self.checkName(node, node.methodName, node.loc.name)

  method message*(self: MethodName; style: Symbol): string =
    format(MSG, style = style)

