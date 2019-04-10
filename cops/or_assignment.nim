
cop :
  type
    OrAssignment* = ref object of Cop
    ##  This cop checks for potential usage of the `||=` operator.
    ## 
    ##  @example
    ##    # bad
    ##    name = name ? name : 'Bozhidar'
    ## 
    ##    # bad
    ##    name = if name
    ##             name
    ##           else
    ##             'Bozhidar'
    ##           end
    ## 
    ##    # bad
    ##    unless name
    ##      name = 'Bozhidar'
    ##    end
    ## 
    ##    # bad
    ##    name = 'Bozhidar' unless name
    ## 
    ##    # good - set name to 'Bozhidar', only if it's nil or false
    ##    name ||= 'Bozhidar'
  const
    MSG = "Use the double pipe equals operator `||=` instead."
  nodeMatcher isTernaryAssignment, """          ({lvasgn ivasgn cvasgn gvasgn} _var
            (if
              ({lvar ivar cvar gvar} _var)
              ({lvar ivar cvar gvar} _var)
              _))
"""
  nodeMatcher isUnlessAssignment, """          (if
            ({lvar ivar cvar gvar} _var) nil?
            ({lvasgn ivasgn cvasgn gvasgn} _var
              _))
"""
  method onIf*(self: OrAssignment; node: Node): void =
    if isUnlessAssignment node:
    addOffense(node)

  method onLvasgn*(self: OrAssignment; node: Node): void =
    if isTernaryAssignment node:
    addOffense(node)

  method autocorrect*(self: OrAssignment; node: Node): void =
    if isTernaryAssignment node:
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.sourceRange, """(lvar :variable) ||= (send
  (lvar :default) :source)"""))

  method takeVariableAndDefaultFromTernary*(self: OrAssignment; node: Node): void =
    (variable, ifStatement.elseBranch)

  method takeVariableAndDefaultFromUnless*(self: OrAssignment; node: Node): void =
    @[variable, default]

