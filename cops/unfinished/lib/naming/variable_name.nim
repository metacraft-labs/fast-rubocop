
import
  types

import
  configurableNaming

cop VariableName:
  ##  This cop makes sure that all variables use the configured style,
  ##  snake_case or camelCase, for their names.
  ## 
  ##  @example EnforcedStyle: snake_case (default)
  ##    # bad
  ##    fooBar = 1
  ## 
  ##    # good
  ##    foo_bar = 1
  ## 
  ##  @example EnforcedStyle: camelCase
  ##    # bad
  ##    foo_bar = 1
  ## 
  ##    # good
  ##    fooBar = 1
  const
    MSG = "Use %<style>s for variable names."
  method onLvasgn*(self; node) =
    var name = node[0]
    if not name:
      return
    self.checkName(node, name, node.loc.name)

  method message*(self; style: Symbol): string =
    format(MSG, style = style)

