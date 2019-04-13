
import
  percentLiteral

cop :
  type
    UnneededInterpolation* = ref object of Cop
    ##  This cop checks for strings that are just an interpolated expression.
    ## 
    ##  @example
    ## 
    ##    # bad
    ##    "#{@var}"
    ## 
    ##    # good
    ##    @var.to_s
    ## 
    ##    # good if @var is already a String
    ##    @var
  const
    MSG = "Prefer `to_s` over string interpolation."
  method autocorrectIncompatibleWith*(self: Class): void =
    @[LineEndConcatenation]

  method onDstr*(self: UnneededInterpolation; node: Node): void =
    if isSingleInterpolation(node):
      addOffense(node)
  
  method autocorrect*(self: UnneededInterpolation; node: Node): void =
    var embeddedNode = node.children[0]
    if isVariableInterpolation(embeddedNode):
      autocorrectVariableInterpolation(embeddedNode, node)
    elif isSingleVariableInterpolation(embeddedNode):
      autocorrectSingleVariableInterpolation(embeddedNode, node)
    else:
      autocorrectOther(embeddedNode, node)
  
  method isSingleInterpolation*(self: UnneededInterpolation; node: Node): void =
    node.children.isOne() and isInterpolation(node.children[0]) and
        isImplicitConcatenation(node).! and isEmbeddedInPercentArray(node).!

  method isSingleVariableInterpolation*(self: UnneededInterpolation; node: Node): void =
    node.children.isOne() and isVariableInterpolation(node.children[0])

  method isInterpolation*(self: UnneededInterpolation; node: Node): void =
    isVariableInterpolation(node) or node.isBeginType()

  method isVariableInterpolation*(self: UnneededInterpolation; node: Node): void =
    node.isVariable or node.isReference

  method isImplicitConcatenation*(self: UnneededInterpolation; node: Node): void =
    node.parent and node.parent.isDstrType()

  method isEmbeddedInPercentArray*(self: UnneededInterpolation; node: Node): void =
    node.parent and node.parent.isArrayType() and isPercentLiteral(node.parent)

  method autocorrectVariableInterpolation*(self: UnneededInterpolation;
      embeddedNode: Node; node: Node): void =
    var replacement = """(send
  (send
    (send
      (lvar :embedded_node) :loc) :expression) :source).to_s"""
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.expression, replacement))

  method autocorrectSingleVariableInterpolation*(self: UnneededInterpolation;
      embeddedNode: Node; node: Node): void =
    var
      variableLoc = embeddedNode.children[0].loc
      replacement = """(send
  (send
    (lvar :variable_loc) :expression) :source).to_s"""
    lambda(proc (corrector: Corrector): void =
      corrector.replace(node.loc.expression, replacement))

  method autocorrectOther*(self: UnneededInterpolation; embeddedNode: Node;
                          node: Node): void =
    var
      loc = node.loc
      embeddedLoc = embeddedNode.loc
    lambda(proc (corrector: Corrector): void =
      corrector.replace(loc.begin, "")
      corrector.replace(loc.end, "")
      corrector.replace(embeddedLoc.begin, "(")
      corrector.replace(embeddedLoc.end, ").to_s"))

