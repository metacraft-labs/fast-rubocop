
import
  configurableNumbering

cop :
  type
    VariableNumber* = ref object of Cop
    ##  This cop makes sure that all numbered variables use the
    ##  configured style, snake_case, normalcase, or non_integer,
    ##  for their numbering.
    ## 
    ##  @example EnforcedStyle: snake_case
    ##    # bad
    ## 
    ##    variable1 = 1
    ## 
    ##    # good
    ## 
    ##    variable_1 = 1
    ## 
    ##  @example EnforcedStyle: normalcase (default)
    ##    # bad
    ## 
    ##    variable_1 = 1
    ## 
    ##    # good
    ## 
    ##    variable1 = 1
    ## 
    ##  @example EnforcedStyle: non_integer
    ##    # bad
    ## 
    ##    variable1 = 1
    ## 
    ##    variable_1 = 1
    ## 
    ##    # good
    ## 
    ##    variableone = 1
    ## 
    ##    variable_one = 1
  const
    MSG = "Use %<style>s for variable numbers."
  method onArg*(self: VariableNumber; node: Node): void =
    var name = node[0]
    checkName(node, name, node.loc.name)

  method message*(self: VariableNumber; style: Symbol): void =
    format(MSG, style = style)

