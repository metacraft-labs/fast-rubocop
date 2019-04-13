
import
  tables, sequtils

cop :
  type
    IdenticalConditionalBranches* = ref object of Cop
    ##  This cop checks for identical lines at the beginning or end of
    ##  each branch of a conditional statement.
    ## 
    ##  @example
    ##    # bad
    ##    if condition
    ##      do_x
    ##      do_z
    ##    else
    ##      do_y
    ##      do_z
    ##    end
    ## 
    ##    # good
    ##    if condition
    ##      do_x
    ##    else
    ##      do_y
    ##    end
    ##    do_z
    ## 
    ##    # bad
    ##    if condition
    ##      do_z
    ##      do_x
    ##    else
    ##      do_z
    ##      do_y
    ##    end
    ## 
    ##    # good
    ##    do_z
    ##    if condition
    ##      do_x
    ##    else
    ##      do_y
    ##    end
    ## 
    ##    # bad
    ##    case foo
    ##    when 1
    ##      do_x
    ##    when 2
    ##      do_x
    ##    else
    ##      do_x
    ##    end
    ## 
    ##    # good
    ##    case foo
    ##    when 1
    ##      do_x
    ##      do_y
    ##    when 2
    ##      # nothing
    ##    else
    ##      do_x
    ##      do_z
    ##    end
  const
    MSG = "Move `%<source>s` out of the conditional."
  method onIf*(self: IdenticalConditionalBranches; node: Node): void =
    if node.isElsif:
      return
    var branches = expandElses(node.elseBranch).unshift(node.ifBranch)
    if branches.anyIt:
      it.isIl:
      return
    checkBranches(branches)

  method onCase*(self: IdenticalConditionalBranches; node: Node): void =
    if node.isElse and node.elseBranch:
    var branches = node.whenBranches.mapIt:
      it.ody.add(node.elseBranch)
    if branches.anyIt:
      it.isIl:
      return
    checkBranches(branches)

  method checkBranches*(self: IdenticalConditionalBranches; branches: Array): void =
    var tails = branches.compact().mapIt:
      tail(it)
    checkExpressions(tails)
    var heads = branches.compact().mapIt:
      head(it)
    checkExpressions(heads)

  method checkExpressions*(self: IdenticalConditionalBranches; expressions: Array): void =
    if expressions.size > 1 and expressions.uniq().isOne():
    for expression in expressions:
      addOffense(expression)

  method message*(self: IdenticalConditionalBranches; node: Node): void =
    format(MSG, source = node.source)

  method expandElses*(self: IdenticalConditionalBranches; branch: NilClass): void =
    ##  `elsif` branches show up in the if node as nested `else` branches. We
    ##  need to recursively iterate over all `else` branches.
    if branch.isNil():
      @[]
    elif branch.isIfType():
      expandElses(elseBranch).unshift(elsifBranch)
    else:
      @[branch]
  
  method tail*(self: IdenticalConditionalBranches; node: Node): void =
    if node.isBeginType():
      node.children.last()
  
  method head*(self: IdenticalConditionalBranches; node: Node): void =
    if node.isBeginType():
      node.children[0]
  
