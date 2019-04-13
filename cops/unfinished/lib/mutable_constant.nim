
import
  frozenStringLiteral

import
  configurableEnforcedStyle

cop :
  type
    MutableConstant* = ref object of Cop
    ##  This cop checks whether some constant value isn't a
    ##  mutable literal (e.g. array or hash).
    ## 
    ##  Strict mode can be used to freeze all constants, rather than
    ##  just literals.
    ##  Strict mode is considered an experimental feature. It has not been
    ##  updated with an exhaustive list of all methods that will produce
    ##  frozen objects so there is a decent chance of getting some false
    ##  positives. Luckily, there is no harm in freezing an already
    ##  frozen object.
    ## 
    ##  @example EnforcedStyle: literals (default)
    ##    # bad
    ##    CONST = [1, 2, 3]
    ## 
    ##    # good
    ##    CONST = [1, 2, 3].freeze
    ## 
    ##    # good
    ##    CONST = <<~TESTING.freeze
    ##      This is a heredoc
    ##    TESTING
    ## 
    ##    # good
    ##    CONST = Something.new
    ## 
    ## 
    ##  @example EnforcedStyle: strict
    ##    # bad
    ##    CONST = Something.new
    ## 
    ##    # bad
    ##    CONST = Struct.new do
    ##      def foo
    ##        puts 1
    ##      end
    ##    end
    ## 
    ##    # good
    ##    CONST = Something.new.freeze
    ## 
    ##    # good
    ##    CONST = Struct.new do
    ##      def foo
    ##        puts 1
    ##      end
    ##    end.freeze
  const
    MSG = "Freeze mutable objects assigned to constants."
  nodeMatcher splatValue, "          (array (splat $_))\n"
  nodeMatcher isOperationProducesImmutableObject, """          {
            (const _ _)
            (send (const nil? :Struct) :new ...)
            (block (send (const nil? :Struct) :new ...) ...)
            (send _ :freeze)
            (send {float int} {:+ :- :* :** :/ :% :<<} _)
            (send _ {:+ :- :* :** :/ :%} {float int})
            (send _ {:== :=== :!= :<= :>= :< :>} _)
            (send (const nil? :ENV) :[] _)
            (or (send (const nil? :ENV) :[] _) _)
            (send _ {:count :length :size} ...)
            (block (send _ {:count :length :size} ...) ...)
          }
"""
  nodeMatcher isRangeEnclosedInParentheses,
             "          (begin ({irange erange} _ _))\n"
  method onCasgn*(self: MutableConstant; node: Node): void =
    onAssignment(value)

  method onOrAsgn*(self: MutableConstant; node: Node): void =
    if lhs and lhs.isCasgnType():
    onAssignment(value)

  method autocorrect*(self: MutableConstant; node: Node): void =
    var expr = node.sourceRange
    lambda(proc (corrector: Corrector): void =
      var splatValue = splatValue node
      if splatValue:
        correctSplatExpansion(corrector, expr, splatValue)
      elif node.isArrayType() and node.isBracketed.!:
        corrector.insertBefore(expr, "[")
        corrector.insertAfter(expr, "]")
      elif isRequiresParentheses(node):
        corrector.insertBefore(expr, "(")
        corrector.insertAfter(expr, ")")
      corrector.insertAfter(expr, ".freeze"))

  method onAssignment*(self: MutableConstant; value: Node): void =
    if style == "strict":
      strictCheck(value)
    else:
      check(value)
  
  method strictCheck*(self: MutableConstant; value: NilClass): void =
    if isImmutableLiteral(value):
      return
    if isOperationProducesImmutableObject value:
      return
    if isFrozenStringLiteral(value):
      return
    addOffense(value)

  method check*(self: MutableConstant; value: Node): void =
    var rangeEnclosedInParentheses = isRangeEnclosedInParentheses value
    if isMutableLiteral(value) or rangeEnclosedInParentheses:
    if FROZENSTRINGLITERALTYPES.isInclude(value.type) and
        isFrozenStringLiteralsEnabled:
      return
    addOffense(value)

  method isMutableLiteral*(self: MutableConstant; value: Node): void =
    value and value.isMutableLiteral

  method isImmutableLiteral*(self: MutableConstant; node: NilClass): void =
    node.isNil() or node.isImmutableLiteral

  method isFrozenStringLiteral*(self: MutableConstant; node: Node): void =
    FROZENSTRINGLITERALTYPES.isInclude(node.type) and
        isFrozenStringLiteralsEnabled

  method isRequiresParentheses*(self: MutableConstant; node: Node): void =
    node.isRangeType or
      node.isSendType() and node.loc.dot.isNil()

  method correctSplatExpansion*(self: MutableConstant; corrector: Corrector;
                               expr: Range; splatValue: Node): void =
    if isRangeEnclosedInParentheses splatValue:
      corrector.replace(expr, """(send
  (lvar :splat_value) :source).to_a""")
    else:
      corrector.replace(expr, """((send
  (lvar :splat_value) :source)).to_a""")
  
