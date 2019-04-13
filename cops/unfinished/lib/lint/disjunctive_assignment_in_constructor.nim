
import
  types

cop DisjunctiveAssignmentInConstructor:
  ##  This cop checks constructors for disjunctive assignments that should
  ##  be plain assignments.
  ## 
  ##  So far, this cop is only concerned with disjunctive assignment of
  ##  instance variables.
  ## 
  ##  In ruby, an instance variable is nil until a value is assigned, so the
  ##  disjunction is unnecessary. A plain assignment has the same effect.
  ## 
  ##  @example
  ##    # bad
  ##    def initialize
  ##      @x ||= 1
  ##    end
  ## 
  ##    # good
  ##    def initialize
  ##      @x = 1
  ##    end
  const
    MSG = "Unnecessary disjunctive assignment. Use plain assignment."
  method onDef*(self; node) =
    self.check(node)

  method check*(self; node) =
    ##  @param [DefNode] node a constructor definition
    if not (node.methodName == "initialize"):
      return
    self.checkBody(node.body)

  method checkBody*(self; body: Node) =
    if body.isNil:
      return
    case body.kind
    of RbBegin:
      self.checkBodyLines(body.childNodes)
    else:
      self.checkBodyLines(@[body])
  
  method checkBodyLines*(self; lines: seq[Node]) =
    ##  @param [Array] lines the logical lines of the constructor
    for line in lines:
      case line.kind
      of RbOrAsgn:
        self.checkDisjunctiveAssignment(line)
      else:
        break
  
  method checkDisjunctiveAssignment*(self; node) =
    ##  Add an offense if the LHS of the given disjunctive assignment is
    ##  an instance variable.
    ## 
    ##  For now, we only care about assignments to instance variables.
    ## 
    ##  @param [Node] node a disjunctive assignment
    var lhs = node.childNodes.first
    if lhs.isIvasgnType:
      addOffense(node, location = operator)
  
