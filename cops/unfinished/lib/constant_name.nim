
import
  types

import
  sequtils

cop :
  type
    ConstantName* = ref object of Cop
    ##  This cop checks whether constant names are written using
    ##  SCREAMING_SNAKE_CASE.
    ## 
    ##  To avoid false positives, it ignores cases in which we cannot know
    ##  for certain the type of value that would be assigned to a constant.
    ## 
    ##  @example
    ##    # bad
    ##    InchInCm = 2.54
    ##    INCHinCM = 2.54
    ##    Inch_In_Cm = 2.54
    ## 
    ##    # good
    ##    INCH_IN_CM = 2.54
  const
    MSG = "Use SCREAMING_SNAKE_CASE for constants."
  const
    SNAKECASE
  nodeMatcher isClassOrStructReturnMethod, """          (send
            (const _ {:Class :Struct}) :new
            ...)
"""
  method onCasgn*(self: ConstantName; node: Node): void =
    if node.parent and node.parent.isOrAsgnType():
    if self.isAllowedAssignment(value):
      return
    if constName.!~(SNAKECASE):
      addOffense(node, location = "name")
  
  method isAllowedAssignment*(self: ConstantName; value: Node): FalseClass =
    value and @["block", "const", "casgn"].isInclude(value.type) or
        self.isAllowedMethodCallOnRhs(value) or
        self.isClassOrStructReturnMethod(value) or
        self.isAllowedConditionalExpressionOnRhs(value)

  method isAllowedMethodCallOnRhs*(self: ConstantName; node: Node): FalseClass =
    node and node.isSendType and
      node.receiver().isNil or node.receiver().isLiteral.!

  method isAllowedConditionalExpressionOnRhs*(self: ConstantName; node: Node): TrueClass =
    node and node.isIfType and self.isContainsContant(node)

  method isContainsContant*(self: ConstantName; node: Node): TrueClass =
    node.branches.anyIt:
      it.isConstType

